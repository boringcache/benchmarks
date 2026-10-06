# frozen_string_literal: true

require_relative "source-promotion"

module RollingSeed
  def self.plan(root: BenchmarkCases::ROOT, observation: "seed")
    raise "Use seed or replay" unless %w[seed replay].include?(observation)
    version = BenchmarkCLI.selection(root: root).fetch("version")
    cases = BenchmarkCadence.source_cases(root: root)
    selections = cases.flat_map do |item|
      source = item.fetch("source")
      prefix = item.dig("execution", "source_prefix")
      sha = if prefix
        BenchmarkPlan.settings(File.join(root, "cases", item.fetch("id"), "payload/benchmark-source.env")).fetch("#{prefix}_HEAD_SHA")
      else
        source["revision"] || source.fetch("pins").find { |pin| pin["kind"] == "gitlink" }.fetch("revision")
      end
      inputs = {"cli_version" => version, "observation" => observation}
      case item.dig("execution", "sync")
      when "adjacent-pair", "build-relevant-pair"
        inputs.merge!("base_sha" => sha, "head_sha" => sha,
          "cache_scope" => "rolling-#{BenchmarkBaseline.selection(root: root).fetch('rolling_scope')}")
      when "verified-pair"
        inputs.merge!("base_sha" => sha, "head_sha" => sha, "source_distance" => "0")
      end
      BenchmarkCadence.rolling_targets(case_id: item.fetch("id"), inputs: inputs, root: root).map do |target|
        target.merge("case_id" => item.fetch("id"), "source_sha" => sha, "state" => "planned")
      end
    end
    BenchmarkCadence.verify_cli(version, selections)
    {"schema_version" => 1, "baseline_id" => BenchmarkBaseline.selection(root: root).fetch("id"),
      "observation" => observation, "cli_version" => version,
      "harness_sha" => BenchmarkCases.command("git", "rev-parse", "HEAD", chdir: root).strip,
      "created_at" => Time.now.utc.iso8601,
      "runs" => selections.group_by { |selection| ProjectRuns.project(selection.fetch("case_id")) }.flat_map do |project, members|
        ProjectRuns.group(members, lane: "rolling", case_id: project)
      end}
  end

  def self.dispatch(plan, publisher: SourcePromotion::Publisher.new)
    root = publisher.root
    version = plan.fetch("cli_version")
    resets = publisher.api("repos/#{publisher.repository}/actions/workflows/reset-benchmark-cache.yml/runs?branch=main&status=completed&per_page=20").fetch("workflow_runs")
    baseline = BenchmarkBaseline.selection(root: root)
    reset = resets.select { |run| BenchmarkBaseline.current?(run.fetch("created_at"), baseline) }.max_by { |run| run.fetch("created_at") }
    raise "Complete the benchmark cache reset before seeding" unless reset && reset["conclusion"] == "success"
    if plan.fetch("observation") == "replay"
      BenchmarkCadence.source_cases(root: root).each do |item|
        Dir.mktmpdir("rolling-seed-check-") do |directory|
          publisher.reconcile(item, output: File.join(directory, "result.json"))
        end
      end
    end
    changes, expected = {}, {}
    receipts = {}
    plan.fetch("runs").each do |run|
      workflow = publisher.api("repos/#{publisher.repository}/actions/workflows/#{run.fetch('workflow')}")
      raise "Rolling workflow is inactive" unless workflow.fetch("state") == "active"
      ProjectRuns.expand(run).each do |selection|
        id = selection.fetch("case_id")
        path = publisher.state_path(id)
        previous = publisher.optional_file(path)
        if plan.fetch("observation") == "seed"
          raise "Rolling seed already exists; inspect its state before retrying" if previous
        else
          prior = JSON.parse(previous || raise("Rolling replay has no seed"))
          raise "Rolling seed is not verified" unless prior["state"] == "completed" && prior["observation"] == "seed"
        end
        expected[path] = previous
        sha = selection.fetch("source_sha")
        receipts[id] ||= {"schema_version" => 1, "baseline_id" => plan.fetch("baseline_id"),
          "observation" => plan.fetch("observation"), "case_id" => id, "state" => "dispatching",
          "cli_version" => version, "created_at" => plan.fetch("created_at"),
          "proposal" => {"case_id" => id, "base_sha" => sha, "head_sha" => sha}, "runs" => []}
        receipts.fetch(id).fetch("runs") << run
      end
    end
    receipts.each_value { |value| value["runs"].uniq! }
    receipts.each { |id, value| changes[publisher.state_path(id)] = JSON.pretty_generate(value) + "\n" }
    # Commit every request intent before the first dispatch. An uncertain request
    # remains blocking and cannot be retried as another cold observation.
    publisher.commit(changes, expected: expected, message: "Record rolling #{plan.fetch('observation')} requests")
    ref = "benchmark-#{plan.fetch('baseline_id')}-#{plan.fetch('observation')}"
    publisher.api("repos/#{publisher.repository}/git/refs", body: {"ref" => "refs/tags/#{ref}", "sha" => plan.fetch("harness_sha")})
    plan.fetch("runs").each do |run|
      begin
        result = publisher.api("repos/#{publisher.repository}/actions/workflows/#{run.fetch('workflow')}/dispatches",
          body: {"ref" => ref, "inputs" => run.fetch("inputs").merge("cli_version" => version), "return_run_details" => true})
        id = result["workflow_run_id"]
        raise "Dispatch returned no run ID" unless id.is_a?(Integer) && id.positive?
        run.merge!("id" => id, "url" => "https://github.com/#{publisher.repository}/actions/runs/#{id}", "state" => "requested")
      rescue StandardError => error
        run.merge!("state" => "request-unknown", "error" => error.message)
      end
    end
    receipts.each do |id, value|
      path = publisher.state_path(id)
      value["state"] = value.fetch("runs").all? { |run| run["state"] == "requested" } ? "requested" : "dispatch-failed"
      publisher.commit({path => JSON.pretty_generate(value) + "\n"}, expected: {path => changes.fetch(path)},
        message: "Record #{id} rolling #{plan.fetch('observation')} run")
    end
    raise "A rolling request has an uncertain outcome; inspect it before retrying" unless plan.fetch("runs").all? { |run| run["state"] == "requested" }
    plan
  end
end

if $PROGRAM_NAME == __FILE__
  options = {observation: "seed"}
  OptionParser.new do |parser|
    parser.on("--replay") { options[:observation] = "replay" }
    parser.on("--dispatch") { options[:dispatch] = true }
    parser.on("--output PATH") { |path| options[:output] = path }
  end.parse!
  plan = RollingSeed.plan(observation: options.fetch(:observation))
  BenchmarkCases.write_json(options.fetch(:output), plan)
  RollingSeed.dispatch(plan) if options[:dispatch]
  BenchmarkCases.write_json(options.fetch(:output), plan)
end
