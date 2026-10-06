# frozen_string_literal: true

require "base64"
require_relative "benchmark-cadence"

# Publication uses reviewed harness code only. Candidate workloads run in jobs
# with read-only repository access; this module never executes their code.
module SourcePromotion
  class Error < StandardError; end

  def self.changes(item, proposal, root: BenchmarkCases::ROOT)
    raise Error, "Expected a changed source proposal for this case" unless proposal["state"] == "proposal" && proposal["case_id"] == item.fetch("id")
    if !!proposal["requires_verified_build"] != (item.dig("execution", "sync") == "verified-pair")
      raise Error, "Source proposal changes the case's build-before-promotion requirement"
    end
    base, head = proposal.values_at("base_sha", "head_sha")
    raise Error, "Source promotion requires distinct exact revisions" unless [base, head].all? { |sha| sha.is_a?(String) && sha.match?(/\A[0-9a-f]{40}\z/) } && base != head
    candidate = Marshal.load(Marshal.dump(item))
    prefix = item.dig("execution", "source_prefix")
    id = item.fetch("id")
    paths = {}
    if prefix
      path = "cases/#{id}/payload/benchmark-source.env"
      original = File.read(File.join(root, path))
      settings = BenchmarkPlan.settings(File.join(root, path))
      previous = proposal.fetch("previous_sha", base)
      raise Error, "Candidate does not follow the declared parent" unless settings.fetch("#{prefix}_HEAD_SHA") == previous
      raise Error, "An adjacent sequence must retain the previous head as its base" if item.dig("execution", "sync") == "adjacent-pair" && base != previous
      expected = original.sub(/^#{prefix}_BASE_SHA=.*$/, "#{prefix}_BASE_SHA=#{base}").sub(/^#{prefix}_HEAD_SHA=.*$/, "#{prefix}_HEAD_SHA=#{head}")
      raise Error, "Source proposal changes settings other than the source pair" unless proposal.fetch("candidate_source_env") == expected
      paths[path] = expected
      candidate.fetch("source")["pins"] = candidate.dig("source", "pins").reject { |pin| pin["kind"] == "env" && pin["path"] == "payload/benchmark-source.env" } +
        [base, head].map { |sha| {"path" => "payload/benchmark-source.env", "revision" => sha, "kind" => "env"} }
      candidate.dig("source", "pins").select { |pin| pin["kind"] == "gitlink" }.each { |pin| pin["revision"] = head }
    elsif item.dig("source", "revision")
      raise Error, "Candidate does not follow the declared snapshot" unless item.dig("source", "revision") == base
      candidate.fetch("source")["revision"] = head
      candidate.dig("source", "pins").each do |pin|
        raise Error, "Snapshot contains an independently pinned source" unless pin.fetch("revision") == base
        pin["revision"] = head
      end
      reference = "github:#{item.dig('source', 'repository')}/#{base}#default"
      replacement = "github:#{item.dig('source', 'repository')}/#{head}#default"
      %w[.boringcache.toml recipe-contract.json].each do |name|
        path = "cases/#{id}/payload/#{name}"
        next unless File.file?(File.join(root, path))
        original = File.read(File.join(root, path))
        paths[path] = original.gsub(reference, replacement) if original.include?(reference)
      end
    else
      pins = candidate.dig("source", "pins").select { |pin| pin["kind"] == "gitlink" }
      raise Error, "Candidate does not follow the declared gitlink" if pins.empty? || pins.any? { |pin| pin.fetch("revision") != base }
      pins.each { |pin| pin["revision"] = head }
    end
    paths["cases/#{id}/case.json"] = JSON.pretty_generate(candidate) + "\n"
    [candidate, paths]
  end

  def self.targets(item, proposal, version:, root: BenchmarkCases::ROOT)
    candidate, = changes(item, proposal, root: root)
    inputs = {"cli_version" => version}
    case item.dig("execution", "sync")
    when "adjacent-pair", "build-relevant-pair"
      inputs.merge!("base_sha" => proposal.fetch("base_sha"), "head_sha" => proposal.fetch("head_sha"), "cache_scope" => "rolling-main")
    when "verified-pair"
      inputs.merge!("base_sha" => proposal.fetch("base_sha"), "head_sha" => proposal.fetch("head_sha"), "source_distance" => proposal.fetch("source_distance").to_s)
    end
    BenchmarkCadence.rolling_targets(case_id: item.fetch("id"), item: candidate, inputs: inputs, root: root)
  end

  class Publisher
    attr_reader :root, :repository, :branch

    def initialize(root: BenchmarkCases::ROOT, runner: NightlyCanaries::Runner.new, branch: "main")
      raise Error, "Use main or an isolated cadence rehearsal branch" unless branch == "main" || branch.match?(/\Acadence-rehearsal-[a-z0-9-]+\z/)
      @root, @runner = root, runner
      @branch = branch
      @repository = BenchmarkCases::REPOSITORY
    end

    def api(path, body: nil)
      if path == "graphql"
        output, error, status = Open3.capture3("gh", "api", "graphql", "--method", "POST", "--input", "-", stdin_data: JSON.generate(body))
        result = JSON.parse(output) unless output.empty?
        return result if result && (status.success? || result.key?("errors"))
        raise Error, "GitHub publication request failed: #{error.strip}"
      end
      @runner.api(path, body: body)
    end

    def file(path, ref: branch)
      result = api("repos/#{repository}/contents/#{path}?ref=#{CGI.escape(ref)}")
      raise Error, "Expected a repository file" unless result["type"] == "file"
      Base64.decode64(result.fetch("content"))
    end

    def optional_file(path, ref: branch)
      file(path, ref: ref)
    rescue NightlyCanaries::Error => error
      raise unless error.message.include?("HTTP 404")
      nil
    end

    # Every update is conditional on both the branch head and the previous
    # contents of the files this case owns. Another case may advance meanwhile.
    def commit(changes, expected:, message:)
      20.times do
        head = api("repos/#{repository}/git/ref/heads/#{branch}").dig("object", "sha")
        protect_harness(head, except: expected.keys) if @case_id
        expected.each do |path, contents|
          raise Error, "#{path} changed while this source was being checked" unless optional_file(path, ref: head) == contents
        end
        input = {"branch" => {"repositoryNameWithOwner" => repository, "branchName" => branch},
          "expectedHeadOid" => head, "message" => {"headline" => message},
          "fileChanges" => {"additions" => changes.map { |path, contents| {"path" => path, "contents" => Base64.strict_encode64(contents)} }}}
        result = api("graphql", body: {"query" => 'mutation($input: CreateCommitOnBranchInput!) { createCommitOnBranch(input: $input) { commit { oid } } }', "variables" => {"input" => input}})
        oid = result.dig("data", "createCommitOnBranch", "commit", "oid")
        if oid&.match?(/\A[0-9a-f]{40}\z/)
          @baseline_ref = oid
          return oid
        end
        errors = result.fetch("errors", [])
        # Only an optimistic-concurrency conflict is safe to retry. Other API
        # failures may have an uncertain outcome and need their receipt inspected.
        retryable = errors.any? && errors.all? do |error|
          # A ref-lock race after GraphQL's initial check is reported as
          # FORBIDDEN. Retry only its exact old/new SHA response, not permission
          # failures or an uncertain request outcome.
          race = error["message"].to_s.match(/\Ais at ([0-9a-f]{40}) but expected #{Regexp.escape(head)}\z/)
          error["type"] == "STALE_DATA" ||
            (error["type"] == "FORBIDDEN" && error["path"] == ["createCommitOnBranch"] && race && race[1] != head)
        end
        raise Error, "Source publication failed: #{errors.map { |error| error['message'] }.join('; ')}" unless retryable
      end
      raise Error, "Source publication could not acquire the current branch head"
    end

    def protect_harness(head, except:)
      @baseline_ref ||= BenchmarkCases.command("git", "rev-parse", "HEAD", chdir: root).strip
      snapshots = [@baseline_ref, head].map do |ref|
        tree = api("repos/#{repository}/git/trees/#{ref}?recursive=1")
        raise Error, "Cannot verify a truncated harness tree" if tree["truncated"]
        tree.fetch("tree").select do |entry|
          path = entry.fetch("path")
          entry["type"] == "blob" && !except.include?(path) &&
            (path.start_with?(".github/", "scripts/", "bin/", "cases/#{@case_id}/") || %w[Gemfile Gemfile.lock .tool-versions suites/scheduled.json config/cli.json].include?(path))
        end.to_h { |entry| [entry.fetch("path"), entry.fetch("sha")] }
      end
      raise Error, "The case or shared harness changed during source inspection" unless snapshots.first == snapshots.last
    end

    def state_path(id)
      "migration/rolling/#{id}.json"
    end

    def save(record, expected:, changes: {})
      contents = JSON.pretty_generate(record) + "\n"
      path = state_path(record.fetch("case_id"))
      history = "migration/rolling/#{record.fetch('case_id')}/#{record.fetch('proposal').fetch('head_sha')}.json"
      commit(changes.merge(path => contents, history => contents), expected: expected,
        message: "Record #{record.fetch('case_id')} rolling #{record.fetch('state')}")
      contents
    end

    def reconcile(item, output:)
      @case_id = item.fetch("id")
      path = state_path(item.fetch("id"))
      previous = optional_file(path)
      return nil unless previous
      record = JSON.parse(previous)
      raise Error, "Rolling receipt belongs to another case" unless record.fetch("case_id") == item.fetch("id")
      if %w[dispatching dispatch-failed].include?(record.fetch("state"))
        BenchmarkCases.write_json(output, record)
        raise Error, "Inspect the retained dispatch before advancing this case; a request may have been accepted"
      end
      return record unless record["state"] == "requested"
      if record.fetch("runs").empty? || record.fetch("runs").any? { |run| !run["id"].is_a?(Integer) || !run["id"].positive? }
        raise Error, "A requested rolling receipt must retain every GitHub run ID"
      end
      record.fetch("runs").each do |run|
        current = api("repos/#{repository}/actions/runs/#{run.fetch('id')}")
        run["outcome"] = current["status"] == "completed" ? current.fetch("conclusion") : current.fetch("status")
      end
      if record.fetch("runs").any? { |run| %w[queued requested pending waiting in_progress].include?(run["outcome"]) }
        BenchmarkCases.write_json(output, record)
        return record
      end
      require_relative "rolling-monitor"
      record["runs"] = record.fetch("runs").map do |run|
        RollingMonitor.check_run(item, run, proposal: record.fetch("proposal"), runner: @runner)
      end
      success = record.fetch("runs").all? { |run| run["state"] == "success" }
      record["state"] = success ? "completed" : "failed"
      changes = {}
      expected = {path => previous}
      if success && record.fetch("proposal")["requires_verified_build"]
        _, changes = SourcePromotion.changes(item, record.fetch("proposal"), root: root)
        changes.each_key { |name| expected[name] = File.read(File.join(root, name)) }
        record["state"] = "promoted"
      end
      save(record, expected: expected, changes: changes)
      BenchmarkCases.write_json(output, record)
      record
    end

    def publish(item, proposal, version:, output:, dry_run: false)
      @case_id = item.fetch("id")
      candidate, changes = SourcePromotion.changes(item, proposal, root: root)
      plans = SourcePromotion.targets(item, proposal, version: version, root: root)
      BenchmarkCadence.verify_cli(version, plans)
      path = state_path(item.fetch("id"))
      previous = optional_file(path)
      if previous
        prior = JSON.parse(previous)
        raise Error, "This case has an unfinished or uncertain rolling request" if %w[dispatching dispatch-failed requested].include?(prior.fetch("state"))
        raise Error, "This source already has a retained rolling observation" if prior.dig("proposal", "head_sha") == proposal.fetch("head_sha")
      end
      runs = plans.map { |plan| plan.slice("repository", "workflow", "inputs").merge("state" => "requesting") }
      runs = ProjectRuns.group(runs, lane: "rolling", case_id: item.fetch("id"))
      record = {"schema_version" => 1, "case_id" => item.fetch("id"), "state" => "dispatching", "cli_version" => version, "ref" => branch,
        "proposal" => proposal, "created_at" => Time.now.utc.iso8601, "runs" => runs}
      if dry_run
        record["state"] = "planned"
        runs.each { |run| run["state"] = "planned" }
        BenchmarkCases.write_json(output, record)
        return record
      end
      # Zed advances only after the build succeeds. The other controllers retain
      # their historical promote-then-build ordering.
      changes = {} if proposal["requires_verified_build"]
      expected = {path => previous, "cases/#{item.fetch('id')}/case.json" => File.read(File.join(root, "cases", item.fetch("id"), "case.json"))}
      changes.each_key { |name| expected[name] = File.read(File.join(root, name)) }
      BenchmarkCases.write_json(output, record)
      pending = save(record, expected: expected, changes: changes)
      runs.each do |run|
        begin
          result = api("repos/#{repository}/actions/workflows/#{run.fetch('workflow')}/dispatches",
            body: {"ref" => branch, "inputs" => run.fetch("inputs").merge("cli_version" => version), "return_run_details" => true})
          id = result["workflow_run_id"]
          raise Error, "Dispatch returned no run ID" unless id.is_a?(Integer) && id.positive?
          run.merge!("id" => id, "url" => "https://github.com/#{repository}/actions/runs/#{id}", "state" => "requested")
        rescue StandardError => error
          run.merge!("state" => "request-unknown", "error" => error.message)
        ensure
          BenchmarkCases.write_json(output, record)
        end
      end
      record["state"] = runs.all? { |run| run["state"] == "requested" } ? "requested" : "dispatch-failed"
      save(record, expected: {path => pending})
      BenchmarkCases.write_json(output, record)
      raise Error, "At least one rolling request has an uncertain outcome; inspect its receipt before retrying" unless record["state"] == "requested"
      record
    end
  end
end

if $PROGRAM_NAME == __FILE__
  selection = BenchmarkCLI.selection
  options = {channel: selection.fetch("channel"), version: selection.fetch("version")}
  OptionParser.new do |parser|
    parser.on("--case ID") { |value| options[:case_id] = value }
    parser.on("--proposal PATH") { |value| options[:proposal] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--channel CHANNEL") { |value| options[:channel] = value }
    parser.on("--version TAG") { |value| options[:version] = value }
    parser.on("--publish") { options[:publish] = true }
    parser.on("--reconcile") { options[:reconcile] = true }
  end.parse!
  begin
    item = BenchmarkCadence.source_cases(case_id: options.fetch(:case_id)).fetch(0)
    if options[:publish] || options[:reconcile]
      unless ENV["BENCHMARK_CADENCE_ACTIVE"] == "true" && ENV["GITHUB_REF_NAME"] == "main" && ENV["GITHUB_REPOSITORY"] == BenchmarkCases::REPOSITORY
        raise SourcePromotion::Error, "Source publication requires active central ownership on main"
      end
    end
    publisher = SourcePromotion::Publisher.new
    output = options.fetch(:output)
    if options[:reconcile]
      record = publisher.reconcile(item, output: output)
      proceed = !record || !%w[requested dispatching dispatch-failed].include?(record.fetch("state"))
      if ENV["GITHUB_OUTPUT"]
        head = publisher.api("repos/#{BenchmarkCases::REPOSITORY}/git/ref/heads/main").dig("object", "sha")
        File.open(ENV.fetch("GITHUB_OUTPUT"), "a") { |file| file.puts("proceed=#{proceed}\nref=#{head}") }
      end
    else
      inventory = JSON.parse(File.read(options.fetch(:proposal)))
      proposal = inventory.fetch("records").find { |record| record.fetch("case_id") == item.fetch("id") }
      raise SourcePromotion::Error, "No changed source proposal" unless proposal && proposal["state"] == "proposal"
      runner = NightlyCanaries::Runner.new
      raise SourcePromotion::Error, "Use stable or canary" unless %w[stable canary].include?(options[:channel])
      version = if options[:version]
        release = runner.api("repos/boringcache/cli/releases/tags/#{options.fetch(:version)}")
        options[:channel] == "stable" ? runner.published_stable(release) : runner.published_canary(release)
      else
        options[:channel] == "stable" ? runner.latest_stable : runner.latest_canary
      end
      publisher.publish(item, proposal, version: version, output: output, dry_run: !options[:publish])
    end
  rescue SourcePromotion::Error, BenchmarkCases::Error, BenchmarkCadence::Error, NightlyCanaries::Error, KeyError, JSON::ParserError => error
    if options[:output] && !File.exist?(options[:output])
      BenchmarkCases.write_json(options[:output], {"case_id" => options[:case_id], "state" => "blocked", "error" => error.message})
    end
    abort error.message
  end
end
