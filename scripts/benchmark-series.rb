# frozen_string_literal: true

require "json"
require "digest"
require "fileutils"
require "time"

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

  def self.report(directory)
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
    metric = plan.dig("comparison", "primary_metric")
    summaries = measured.group_by { |row| [row.fetch("phase"), row.fetch("strategy")] }.map do |(phase, provider), rows|
      timings = rows.filter_map { |row| row.dig("timing", metric) if metric.end_with?("seconds") }
      storage = rows.filter_map { |row| row.dig("cache", "storage_bytes") }
      {"phase" => phase, "provider" => provider, "count" => rows.length, "measurement" => statistics(timings),
        "storage" => statistics(storage), "storage_measured_count" => storage.length}
    end
    result = {"schema_version" => 1, "plan_sha256" => plan.fetch("plan_sha256"), "complete" => missing.empty?,
      "valid_for_comparison" => missing.empty? && failures.empty?, "failures" => failures,
      "publication" => "unreviewed", "evidence_preservation" => "requires-review", "primary_metric" => metric, "missing" => missing, "summaries" => summaries,
      "records" => records, "exclusions" => []}
    write_json(File.join(directory, "report.json"), result)
    lines = ["# #{plan.fetch('case_id')}: #{plan.fetch('series_id')}", "",
      "Question: #{plan.dig('comparison', 'question')}", "", "Measured scope: #{plan.dig('comparison', 'timed_scope')}", "",
      "Status: #{missing.empty? ? 'all declared observations collected' : "#{missing.length} declared observations missing"}; #{failures.length} failed. Publication requires review.", "",
      "Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.", "",
      "| Phase | Provider | Successful observations | Median #{metric} | Range | Storage median (bytes) | Storage observations |",
      "| --- | --- | ---: | ---: | --- | ---: | ---: |"]
    summaries.each do |row|
      values = row["measurement"]
      lines << "| #{row['phase']} | #{row['provider']} | #{row['count']} | #{values && values['median']} | #{values && "#{values['min']}–#{values['max']}"} | #{row.dig('storage', 'median') || 'unmeasured'} | #{row['storage_measured_count']} |"
    end
    unless failures.empty?
      lines.concat(["", "Failed observations do not contribute timings. They remain in the report and prevent a complete performance comparison.", ""])
      failures.each { |value| lines << "- Sample #{value.dig('series', 'sample')}, #{value.fetch('strategy')}, #{value.fetch('phase')}: #{value.fetch('error')}" }
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
