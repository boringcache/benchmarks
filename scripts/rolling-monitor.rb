# frozen_string_literal: true

require_relative "benchmark-cadence"

module RollingMonitor
  def self.collect(root: BenchmarkCases::ROOT, runner: NightlyCanaries::Runner.new, now: Time.now.utc)
    repository = BenchmarkCases::REPOSITORY
    baseline = BenchmarkBaseline.selection(root: root)
    result = {"schema_version" => 1, "baseline_id" => baseline&.fetch("id"), "collected_at" => now.iso8601, "passed" => true, "sources" => [], "cases" => []}
    checks = runner.api("repos/#{repository}/actions/workflows/source-sync.yml/runs?branch=main&per_page=20").fetch("workflow_runs")
    latest = checks.reject { |run| run["event"] == "push" || run["conclusion"] == "skipped" }
      .select { |run| BenchmarkBaseline.current?(run.fetch("created_at"), baseline) }.max_by { |run| run.fetch("created_at") }
    result["source_check"] = latest&.slice("id", "status", "conclusion", "created_at", "html_url")
    result["passed"] = false unless latest && now - Time.iso8601(latest.fetch("created_at")) <= 4 * 3600
    if latest && latest["status"] == "completed"
      result["passed"] = false unless latest["conclusion"] == "success"
      Dir.mktmpdir("source-observations-") do |directory|
        _, error, status = Open3.capture3("gh", "run", "download", latest.fetch("id").to_s,
          "--repo", repository, "--pattern", "source-proposals-*", "--dir", directory)
        result["source_error"] = error.strip unless status.success?
        result["sources"] = Dir[File.join(directory, "**", "source-proposals.json")].flat_map { |path| JSON.parse(File.read(path)).fetch("records") }
        result["passed"] = false unless status.success?
      end
    end
    BenchmarkCadence.source_cases(root: root).each do |item|
      path = File.join(root, "migration/rolling", "#{item.fetch('id')}.json")
      unless File.file?(path)
        result["cases"] << {"case_id" => item.fetch("id"), "state" => "unobserved"}
        next
      end
      receipt = JSON.parse(File.read(path))
      next unless BenchmarkBaseline.current?(receipt.fetch("created_at"), baseline)
      value = receipt.merge("runs" => Marshal.load(Marshal.dump(receipt.fetch("runs"))))
      result["cases"] << value
      result["passed"] = false if %w[dispatching dispatch-failed failed blocked].include?(receipt.fetch("state"))
      value["runs"] = value.fetch("runs").map { |run| check_run(item, run, proposal: receipt.fetch("proposal"), runner: runner) }
      result["passed"] = false unless value.fetch("runs").all? { |run| %w[success queued pending waiting in_progress].include?(run.fetch("state")) }

    end
    result
  end

  def self.check_run(item, run, proposal:, runner:)
    if run["selections"]
      run["selections"] = ProjectRuns.expand(run).select { |child| ProjectRuns.selection_case(child) == item.fetch("id") }
        .map { |child| check_run(item, child, proposal: proposal, runner: runner) }
      run["canonical_records"] = run.fetch("selections").flat_map { |child| Array(child["canonical_records"]) }
      run["state"] = run.fetch("selections").map { |child| child.fetch("state") }.find { |state| state != "success" } || "success"
      return run
    end
    unless run["id"].is_a?(Integer) && run["id"].positive?
      return run.merge("state" => "request-unknown")
    end
    current = runner.api("repos/#{run.fetch('repository')}/actions/runs/#{run.fetch('id')}")
    run["state"] = current["status"] == "completed" ? current.fetch("conclusion") : current.fetch("status")
    return run unless current["status"] == "completed"
    variant = run.dig("inputs", "variant") || run.dig("inputs", "cache_tool")
    variant = nil if variant == "all"
    records = runner.phase_evidence(run, attempt: current.fetch("run_attempt")).select do |record|
      record["benchmark"] && record["phase"] && record.dig("case", "case_id") == item.fetch("id") &&
        (!variant || record["variant"] == variant)
    end
    run["canonical_records"] = records
    observation = run.dig("inputs", "observation") || "changed-source"
    observation_verified = records.all? do |record|
      next true if observation == "changed-source"
      next false unless record["observation"] == observation
      if observation == "seed"
        record.dig("cache", "hit") != true
      elsif %w[docker buildkit].include?(record["mode"])
        record.dig("cache", "import_ready") == true && record.dig("cache", "import_refs").to_i.positive?
      else
        record.dig("cache", "hit") == true
      end
    end
    workflow = item.dig("execution", "workflows").find { |entry| File.basename(entry.fetch("path")) == run.fetch("workflow") }
    raise BenchmarkCadence::Error, "Unregistered rolling workflow" unless workflow
    phases = BenchmarkSeries.phases_for(workflow.fetch("lane"), workflow["phases"])
    providers = item.dig("comparison", "providers")
    expected = providers.product(phases)
    observed = records.map { |record| record.values_at("strategy", "phase") }
    verified = records.all? do |record|
      record.dig("verification", "passed") == true && record.dig("source", "sha") == proposal.fetch("head_sha") &&
        record.dig("case", "comparison", "timed_scope") == item.dig("comparison", "timed_scope") &&
        (!record["series"] || record.dig("timing", "comparison_scope") == item.dig("comparison", "timed_scope"))
    end
    paired = records.group_by { |record| record.fetch("phase") }.values.all? do |group|
      group.map { |record| [record.fetch("source"), record["environment"] || record.fetch("github").slice("runner_os", "runner_arch"), record.dig("case", "definition_sha256")] }.uniq.length == 1
    end
    run["comparison_plan"] = records.all? { |record| record["series"] } ? "declared-series" : "diagnostic"
    if run["state"] == "success" && !(verified && paired && observation_verified && observed.sort == expected.sort)
      run["state"] = "evidence-missing-or-invalid"
    end
    run
  end

  def self.markdown(result)
    source = result["source_check"]
    lines = ["## Rolling benchmarks", "", "Upstream check: #{source ? "[run #{source['id']}](#{source['html_url']}) — #{source['conclusion'] || source['status']}" : 'unobserved'}.", ""]
    result.fetch("sources").each { |value| lines << "- #{value['case_id']}: #{value['state']}#{value['error'] ? "; #{value['error']}" : ''}" }
    result.fetch("cases").each do |item|
      lines << "- #{item['case_id']}: #{item['state']}"
      Array(item["runs"]).each { |run| lines << "  - [#{run['workflow']}](#{run['url']}): #{run['state']}" }
    end
    lines << ""
    lines.join("\n")
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  OptionParser.new do |parser|
    parser.on("--summary PATH") { |value| options[:summary] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
  end.parse!
  result = RollingMonitor.collect
  BenchmarkCases.write_json(options.fetch(:output), result)
  File.write(options.fetch(:summary), RollingMonitor.markdown(result))
  exit(result.fetch("passed") ? 0 : 1)
end
