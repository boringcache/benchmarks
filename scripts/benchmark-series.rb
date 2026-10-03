# frozen_string_literal: true

require "json"
require "digest"
require "fileutils"
require "time"
require "open3"

module BenchmarkSeries
  class Error < StandardError; end
  PHASES = {"fresh" => %w[cold warm], "rolling" => %w[commit]}.freeze
  PHASE_LANES = {"cold" => "fresh", "warm" => "fresh", "commit" => "rolling"}.freeze
  ENVIRONMENT_FIELDS = %w[os arch image image_version machine].freeze

  def self.phases_for(lane, phases = nil)
    defaults = PHASES.fetch(lane) { raise Error, "Use fresh or rolling" }
    phases ||= defaults
    allowed = lane == "fresh" ? [defaults, %w[cold commit]] : [defaults]
    raise Error, "Unsupported phase sequence for #{lane}" unless allowed.include?(phases)
    phases
  end

  def self.create(item, directory:, series:, lane:, samples: nil, variant: nil, definition_sha256: nil, workflow_inputs: {}, phases: nil)
    raise Error, "Series already exists: #{directory}" if File.exist?(directory)
    raise Error, "Invalid series ID" unless series.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    phases = phases_for(lane, phases)
    comparison = item.fetch("comparison")
    count = samples || comparison.fetch("sample_count")
    raise Error, "Sample count must be between 1 and 100" unless count.is_a?(Integer) && (1..100).cover?(count)
    plan = {"schema_version" => 1, "case_id" => item.fetch("id"), "series_id" => series,
      "created_at" => Time.now.utc.iso8601, "lane" => lane, "phases" => phases, "sample_count" => count,
      "definition_sha256" => definition_sha256 || Digest::SHA256.hexdigest(JSON.generate(item)), "variant" => variant, "workflow_inputs" => workflow_inputs,
      "comparison" => comparison, "source" => item.fetch("source"), "verification" => item.fetch("verification")}
    plan["plan_sha256"] = digest(plan)
    FileUtils.mkdir_p(File.join(directory, "runs"))
    write_json(File.join(directory, "series.json"), plan)
    plan
  end

  def self.digest(plan)
    Digest::SHA256.hexdigest(JSON.generate(plan.reject { |key, _| key == "plan_sha256" }))
  end

  def self.load(directory)
    plan = JSON.parse(File.read(File.join(directory, "series.json")))
    raise Error, "Series plan changed after creation" unless plan.fetch("plan_sha256") == digest(plan)
    plan
  end

  def self.record(directory, path)
    plan = load(directory)
    value = JSON.parse(File.read(path))
    validate_record(plan, value)
    sample = value.fetch("series").fetch("sample")
    target = File.join(directory, "runs", "#{sample}-#{value.fetch('strategy')}-#{value.fetch('phase')}.json")
    raise Error, "This sample, provider, and phase already has a record" if File.exist?(target)
    write_json(target, value)
    target
  end

  def self.validate_record(plan, value)
    series = value.fetch("series")
    raise Error, "Record belongs to a different series" unless series["id"] == plan.fetch("series_id")
    sample = series.fetch("sample")
    raise Error, "Sample is outside the declared series" unless sample.is_a?(Integer) && (1..plan.fetch("sample_count")).cover?(sample)
    raise Error, "Record belongs to a different case" unless value.dig("case", "case_id") == plan.fetch("case_id")
    raise Error, "Case changed after series creation" unless value.dig("case", "definition_sha256") == plan.fetch("definition_sha256")
    raise Error, "Record belongs to a different variant" unless value["variant"] == plan["variant"]
    raise Error, "Provider is not in the declared comparison" unless plan.dig("comparison", "providers").include?(value.fetch("strategy"))
    raise Error, "Phase is not in the declared series" unless plan.fetch("phases").include?(value.fetch("phase")) && value["lane"] == PHASE_LANES[value["phase"]]
    source = value.fetch("source")
    revisions = plan.fetch("source").fetch("pins").map { |pin| pin.fetch("revision") }
    revisions << plan.dig("source", "revision")
    raise Error, "Source is not a declared pin" unless source["repository"] == plan.dig("source", "repository") && revisions.include?(source["sha"])
    raise Error, "Record has no evidence links" unless Array(value["evidence_links"]).any? { |link| link.is_a?(String) && link.match?(%r{\Ahttps://}) }
    if value["status"] == "failed"
      raise Error, "Failed record has no failure reason" unless value["error"].is_a?(String) && !value["error"].empty?
      return value
    end
    raise Error, "Record has no successful output verification" unless value.dig("verification", "passed") == true && !Array(value.dig("verification", "checks")).empty?
    environment = value.fetch("environment")
    raise Error, "Record has incomplete runner environment" unless ENVIRONMENT_FIELDS.all? { |key| environment[key].is_a?(String) && !environment[key].empty? }
    if value.fetch("strategy").start_with?("boringcache")
      refs = value.fetch("product_refs")
      raise Error, "BoringCache record has no CLI version" unless refs["cli_version"].is_a?(String) && !refs["cli_version"].empty?
      expected = plan.fetch("workflow_inputs")["cli_version"]
      if !expected.to_s.empty? && refs.fetch("cli_version").delete_prefix("v") != expected.delete_prefix("v")
        raise Error, "CLI version differs from the declared series"
      end
    end
    metric = plan.dig("comparison", "primary_metric")
    storage = value.dig("cache", "storage_bytes")
    unless storage.nil?
      raise Error, "Storage must be finite and nonnegative" unless storage.is_a?(Numeric) && storage.finite? && storage >= 0
      raise Error, "Measured storage has no provider source" unless value.dig("cache", "storage_source").is_a?(String) && !value.dig("cache", "storage_source").empty?
    end
    unless metric == "correctness"
      raise Error, "Comparison timing scope differs from the plan" unless value.dig("timing", "comparison_scope") == plan.dig("comparison", "timed_scope")
      measurement = metric == "storage_bytes" ? value.dig("cache", "storage_bytes") : value.dig("timing", metric)
      raise Error, "Record has no measured #{metric}" unless measurement.is_a?(Numeric) && measurement.finite? && measurement >= 0
    end
    value
  rescue KeyError => error
    raise Error, "Incomplete run record: #{error.message}"
  end

  def self.finish(directory, evidence_directory:, sample:)
    require_relative "benchmark-evidence"
    plan = load(directory)
    verified = BenchmarkEvidence.verify(evidence_directory)
    raise Error, "Completion requires a complete verified evidence export" unless verified["state"] == "complete"
    run = JSON.parse(File.read(File.join(evidence_directory, "run.json")))
    manifest = JSON.parse(File.read(File.join(evidence_directory, "manifest.json")))
    raise Error, "Completion requires a finished workflow run" unless run["status"] == "completed"
    raise Error, "Completion belongs to another repository" unless manifest["repository"] == BenchmarkCases::REPOSITORY
    raise Error, "Sample is outside the declared series" unless sample.is_a?(Integer) && (1..plan.fetch("sample_count")).cover?(sample)
    run_id = run.fetch("id").to_s
    records = Dir[File.join(directory, "runs", "*.json")].map { |path| JSON.parse(File.read(path)) }
    matching = records.select { |record| record.dig("github", "run_id").to_s == run_id }
    raise Error, "Run records belong to another sample" if matching.any? { |record| record.dig("series", "sample") != sample }
    errors = []
    errors << "Workflow concluded #{run['conclusion']}" unless run["conclusion"] == "success"
    manifest.fetch("attempts").each do |attempt|
      prefix = File.join(evidence_directory, "attempts", attempt.fetch("attempt").to_s)
      jobs = JSON.parse(File.read(File.join(prefix, "jobs.json"))).fetch("jobs")
      jobs.reject { |job| %w[success skipped].include?(job["conclusion"]) }.each do |job|
        errors << "#{job.fetch('name')}: #{job['conclusion'] || job['status']}"
      end
      Open3.popen2e("unzip", "-p", File.join(prefix, "logs.zip")) do |input, output, process|
        input.close
        output.each_line do |line|
          if errors.length < 100 && line.match?(%r{boringcache/one save failed|Machine connection (?:failed|cleanup failed)})
            errors << line.gsub(/\e\[[\d;]*m/, "").strip[0, 2000]
          end
        end
        raise Error, "Cannot inspect preserved logs in #{prefix}" unless process.value.success?
      end
    end
    raise Error, "Successful completion requires phase records from this run" if errors.empty? && matching.empty?
    result = {"schema_version" => 1, "case_id" => plan.fetch("case_id"), "series_id" => plan.fetch("series_id"),
      "sample" => sample, "run_id" => run_id, "run_url" => manifest.fetch("run_url"), "source_sha" => manifest.fetch("source_sha"),
      "github_conclusion" => run["conclusion"], "status" => errors.empty? ? "success" : "failed", "errors" => errors.uniq,
      "evidence_manifest_sha256" => Digest::SHA256.file(File.join(evidence_directory, "manifest.json")).hexdigest}
    target = File.join(directory, "completions", "#{run_id}.json")
    raise Error, "This run already has a completion record" if File.exist?(target)
    FileUtils.mkdir_p(File.dirname(target))
    write_json(target, result)
    result
  end

  def self.report(directory, write: true)
    plan = load(directory)
    records = Dir[File.join(directory, "runs", "*.json")].sort.map { |path| JSON.parse(File.read(path)) }
    records.each { |value| validate_record(plan, value) }
    failures, measured = records.partition { |value| value["status"] == "failed" }
    product_versions = measured.select { |value| value.fetch("strategy").start_with?("boringcache") }
      .map { |value| value.fetch("product_refs").slice("cli_version", "action_sha") }
    raise Error, "BoringCache observations used different CLI or Action versions" unless product_versions.uniq.length <= 1
    providers = plan.dig("comparison", "providers")
    groups = records.group_by { |value| [value.dig("series", "sample"), value.fetch("phase")] }
    raise Error, "Duplicate provider observations" if groups.values.any? { |rows| rows.map { |row| row.fetch("strategy") }.uniq.length != rows.length }
    measured.group_by { |value| [value.dig("series", "sample"), value.fetch("phase")] }.each_value do |rows|
      identities = rows.map { |row| [row.fetch("source"), row.fetch("environment").slice(*ENVIRONMENT_FIELDS), row.dig("case", "definition_sha256"), row["variant"]] }
      raise Error, "Paired observations have different source, case, variant, or runner environments" unless identities.uniq.length == 1
    end
    measured.group_by { |value| [value.dig("series", "sample"), value.fetch("strategy")] }.each_value do |rows|
      sources = rows.to_h { |row| [row.fetch("phase"), row.fetch("source")] }
      if sources["cold"] && sources["warm"] && sources["cold"] != sources["warm"]
        raise Error, "An identical-source replay used different source revisions"
      end
      if sources["cold"] && sources["commit"] && sources["cold"] == sources["commit"]
        raise Error, "A changed-source observation reused the seed revision"
      end
    end
    expected = (1..plan.fetch("sample_count")).flat_map { |sample| plan.fetch("phases").product(providers).map { |phase, provider| [sample, phase, provider] } }
    observed = records.map { |row| [row.dig("series", "sample"), row.fetch("phase"), row.fetch("strategy")] }
    missing = expected - observed
    completions = Dir[File.join(directory, "completions", "*.json")].map { |path| JSON.parse(File.read(path)) }
    completions.each do |completion|
      unless completion["case_id"] == plan["case_id"] && completion["series_id"] == plan["series_id"] &&
          %w[success failed].include?(completion["status"]) && completion["errors"].is_a?(Array)
        raise Error, "Completion record belongs to another case or series, or has an invalid status"
      end
      raise Error, "Completion status conflicts with its errors" unless (completion["status"] == "success") == completion["errors"].empty?
    end
    run_ids = records.map { |record| record.dig("github", "run_id").to_s }.uniq
    missing_completions = run_ids - completions.map { |completion| completion.fetch("run_id") }
    failed_completions = completions.reject { |completion| completion["status"] == "success" }
    execution_verified = !run_ids.empty? && !run_ids.include?("") && missing_completions.empty? && failed_completions.empty?
    methodology_issues = []
    if plan.fetch("lane") == "rolling"
      methodology_issues << "Rolling observations have no verified seed and changed-source sequence; retain them as diagnostic."
    end
    metric = plan.dig("comparison", "primary_metric")
    if metric == "correctness" || providers.length < 2
      methodology_issues << "This series does not declare a comparison of provider performance."
    end
    summaries = measured.group_by { |row| [row.fetch("phase"), row.fetch("strategy")] }.map do |(phase, provider), rows|
      measurements = rows.filter_map do |row|
        metric == "storage_bytes" ? row.dig("cache", "storage_bytes") : row.dig("timing", metric)
      end
      storage = rows.filter_map { |row| row.dig("cache", "storage_bytes") }
      {"phase" => phase, "provider" => provider, "count" => rows.length, "measurement" => metric == "correctness" ? nil : statistics(measurements),
        "storage" => statistics(storage), "storage_measured_count" => storage.length}
    end
    result = {"schema_version" => 1, "plan_sha256" => plan.fetch("plan_sha256"), "complete" => missing.empty?,
      "valid_for_comparison" => missing.empty? && failures.empty? && execution_verified && methodology_issues.empty?, "failures" => failures,
      "methodology_issues" => methodology_issues,
      "execution_verified" => execution_verified, "missing_completions" => missing_completions,
      "failed_completions" => failed_completions, "completions" => completions,
      "publication" => "unreviewed", "evidence_preservation" => "requires-review", "primary_metric" => metric, "missing" => missing, "summaries" => summaries,
      "records" => records, "exclusions" => []}
    return result unless write
    write_json(File.join(directory, "report.json"), result)
    lines = ["# #{plan.fetch('case_id')}: #{plan.fetch('series_id')}", "",
      "Question: #{plan.dig('comparison', 'question')}", "", "Measured scope: #{plan.dig('comparison', 'timed_scope')}", "",
      "Status: #{missing.empty? ? 'all declared observations collected' : "#{missing.length} declared observations missing"}; #{failures.length} failed. Publication requires review.", "",
      "Execution: #{execution_verified ? 'preserved job completion and post-step logs verified' : 'unqualified; missing or failed job completion checks'}. Timings alone do not qualify the series.", "",
      "Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.", ""]
    columns = ["Phase", "Provider", "Successful observations"]
    alignment = ["---", "---", "---:"]
    unless metric == "correctness"
      columns.concat(["Median #{metric}", "Range"])
      alignment.concat(["---:", "---"])
    end
    unless metric == "storage_bytes"
      columns << "Storage median (bytes)"
      alignment << "---:"
    end
    columns << "Storage observations"
    alignment << "---:"
    lines.concat(["| #{columns.join(' | ')} |", "| #{alignment.join(' | ')} |"])
    summaries.each do |row|
      values = row["measurement"]
      cells = [row["phase"], row["provider"], row["count"]]
      cells.concat([values ? values.fetch("median") : "unmeasured", values ? "#{values['min']}–#{values['max']}" : "unmeasured"]) unless metric == "correctness"
      cells << (row.dig("storage", "median") || "unmeasured") unless metric == "storage_bytes"
      cells << row["storage_measured_count"]
      lines << "| #{cells.join(' | ')} |"
    end
    unless methodology_issues.empty?
      lines.concat(["", "Methodology prevents a comparative claim:", ""])
      methodology_issues.each { |issue| lines << "- #{issue}" }
    end
    unless failures.empty?
      lines.concat(["", "Failed observations do not contribute timings. They remain in the report and prevent a complete performance comparison.", ""])
      failures.each { |value| lines << "- Sample #{value.dig('series', 'sample')}, #{value.fetch('strategy')}, #{value.fetch('phase')}: #{value.fetch('error')}" }
    end
    failed_completions.each do |completion|
      lines.concat(["", "Run #{completion.fetch('run_id')} failed completion checks:", ""])
      completion.fetch("errors").each { |error| lines << "- #{error}" }
    end
    lines.concat(["", "Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.", ""])
    File.write(File.join(directory, "report.md"), lines.join("\n"))
    result
  end

  def self.statistics(values)
    return nil if values.empty?
    sorted = values.sort
    center = sorted.length / 2
    median = sorted.length.odd? ? sorted[center] : (sorted[center - 1] + sorted[center]) / 2.0
    {"median" => median, "min" => sorted.first, "max" => sorted.last}
  end

  def self.write_json(path, value)
    File.write(path, JSON.pretty_generate(value) + "\n")
  end
end
