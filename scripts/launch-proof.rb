#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"

repo_root = Pathname.new(__dir__).join("..").expand_path

options = {
  artifacts: [repo_root.join("data/latest/benchmarks").to_s],
  diagnostics: [],
  evidence: [],
  matrix: nil,
  expected_action_ref: "boringcache/one@v1",
  require_diagnostics: true,
  require_evidence_product_refs: true,
  require_fresh_cache_import: true,
  require_docker_oci: true,
  verbose: false
}

parser = OptionParser.new do |opts|
  opts.banner = "usage: launch-proof.rb [options]"

  opts.on("--artifacts PATH", "Benchmark artifact file or directory. Can be passed more than once.") do |path|
    options[:artifacts] = [] if options[:artifacts] == [repo_root.join("data/latest/benchmarks").to_s]
    options[:artifacts] << path
  end

  opts.on("--diagnostics PATH", "Diagnostics file or directory containing request metrics/status output.") do |path|
    options[:diagnostics] << path
  end

  opts.on("--evidence PATH", "Launch proof evidence manifest JSON. Can be passed more than once.") do |path|
    options[:evidence] << path
  end

  opts.on("--matrix PATH", "Launch proof matrix JSON requiring tool/surface/scenario coverage.") do |path|
    options[:matrix] = path
  end

  opts.on("--action-ref REF", "Expected released action ref. Default: boringcache/one@v1") do |ref|
    options[:expected_action_ref] = ref
  end

  opts.on("--cli-version VERSION", "Require an exact CLI version in product_refs.cli_version.") do |version|
    options[:cli_version] = version
  end

  opts.on("--action-sha SHA", "Require an exact action SHA in product_refs.action_sha.") do |sha|
    options[:action_sha] = sha
  end

  opts.on("--web-revision REV", "Require an exact deployed web revision in product_refs.web_revision.") do |revision|
    options[:web_revision] = revision
  end

  opts.on("--allow-missing-diagnostics", "Do not require cache_session_summary evidence in diagnostics.") do
    options[:require_diagnostics] = false
  end

  opts.on("--allow-evidence-without-product-refs", "Do not require every matrix evidence item to carry released product refs.") do
    options[:require_evidence_product_refs] = false
  end

  opts.on("--allow-missing-cache-import", "Do not require fresh warm BoringCache artifacts to report cache_import_status=ok.") do
    options[:require_fresh_cache_import] = false
  end

  opts.on("--allow-missing-docker-oci", "Do not require Docker-looking artifacts to include OCI proof counters.") do
    options[:require_docker_oci] = false
  end

  opts.on("--verbose", "Print checked artifact paths.") do
    options[:verbose] = true
  end
end

parser.parse!(ARGV)

def present?(value)
  !value.nil? && !value.to_s.strip.empty?
end

def compact_hash(hash)
  hash.reject { |_, value| value.nil? }
end

def normalized_product_refs(payload)
  refs = payload["product_refs"].is_a?(Hash) ? payload["product_refs"].dup : {}
  %w[cli_version action_ref action_sha web_revision api_url].each do |key|
    refs[key] = payload[key] if !present?(refs[key]) && present?(payload[key])
  end
  refs
end

def field_value(payload, field_path)
  field_path.to_s.split(".").reduce(payload) do |value, key|
    value.is_a?(Hash) ? value[key] : nil
  end
end

def field_present?(payload, field_spec)
  case field_spec
  when Array
    field_spec.any? { |item| field_present?(payload, item) }
  when Hash
    if field_spec["any"].is_a?(Array)
      field_spec["any"].any? { |item| field_present?(payload, item) }
    else
      false
    end
  else
    field_spec.to_s.split("|").any? do |candidate|
      present?(field_value(payload, candidate.strip))
    end
  end
end

def field_label(field_spec)
  case field_spec
  when Array
    field_spec.join("|")
  when Hash
    Array(field_spec["any"]).join("|")
  else
    field_spec.to_s
  end
end

def missing_required_fields(payload, field_specs)
  field_specs.reject { |field_spec| field_present?(payload, field_spec) }.map { |field_spec| field_label(field_spec) }
end

def parse_json_file(path)
  JSON.parse(path.read)
rescue JSON::ParserError, Errno::ENOENT, Errno::EISDIR
  nil
end

def files_under(paths, pattern)
  paths.flat_map do |raw_path|
    path = Pathname.new(raw_path)
    if path.file?
      [path]
    elsif path.directory?
      path.glob(pattern).select(&:file?)
    else
      []
    end
  end.uniq
end

def benchmark_artifact?(payload)
  payload.is_a?(Hash) &&
    payload["strategy"] == "boringcache" &&
    present?(payload["benchmark"]) &&
    present?(payload["lane"])
end

def aggregate_entries(payload)
  return [] unless payload.is_a?(Hash)

  entries = []
  entries << payload["entry"] if payload["entry"].is_a?(Hash)
  entries.concat(payload["entries"]) if payload["entries"].is_a?(Array)
  entries.select { |entry| entry.is_a?(Hash) }
end

def aggregate_boringcache_artifacts(payload)
  aggregate_entries(payload).map do |entry|
    boringcache = entry.dig("comparison", "boringcache")
    next unless boringcache.is_a?(Hash)

    {
      "benchmark" => entry["benchmark"],
      "strategy" => "boringcache",
      "lane" => entry["lane"],
      "category" => entry["category"],
      "cache_mode" => entry["category"],
      "product_refs" => boringcache["product_refs"],
      "product_refs_consistent" => boringcache["product_refs_consistent"],
      "classification" => boringcache["classification"],
      "oci" => boringcache["oci"],
      "docker_cache" => {
        "import_seconds" => boringcache["docker_cache_import_seconds"],
        "export_seconds" => boringcache["docker_cache_export_seconds"]
      },
      "launch_proof_paths" => boringcache["launch_proof_paths"],
      "workspace" => boringcache["workspace"],
      "cache_tag" => boringcache["cache_tag"],
      "run_uid" => boringcache["run_uid"],
      "mode" => boringcache["mode"],
      "adapter" => boringcache["adapter"],
      "docker_cache_from_refs" => boringcache["docker_cache_from_refs"],
      "docker_cache_import_ready" => boringcache["docker_cache_import_ready"],
      "restore_result" => boringcache["restore_result"],
      "save_result" => boringcache["save_result"],
      "publish_status" => boringcache["publish_status"],
      "session_summary" => boringcache["session_summary"],
      "summary_schema" => boringcache["summary_schema"],
      "reporting_url" => boringcache["reporting_url"],
      "runs" => {
        "cold_seconds" => boringcache["cold_seconds"],
        "warm1_seconds" => boringcache["warm1_seconds"]
      }
    }
  end.compact
end

def docker_artifact?(payload)
  return true if payload["category"].to_s == "docker"

  benchmark = payload["benchmark"].to_s
  return true if benchmark.include?("docker")

  oci = payload["oci"]
  return false unless oci.is_a?(Hash)

  oci.any? { |_, value| present?(value) }
end

def cache_mode(payload)
  payload["cache_mode"] ||
    payload.dig("cache", "mode") ||
    payload["mode"] ||
    payload["strategy"]
end

def warm_artifact?(payload)
  present?(payload.dig("runs", "warm1_seconds"))
end

def embedded_session_summary?(payload)
  return true if payload.key?("cache_session_summary")
  return true if payload.key?("summary_json")

  diagnostics = payload["diagnostics"]
  diagnostics.is_a?(Hash) && (
    diagnostics.key?("cache_session_summary") ||
      diagnostics.key?("summary_json") ||
      diagnostics.key?("request_metrics_cache_session_summaries")
  )
end

def proof_paths(payload)
  raw_paths = []
  raw_paths.concat(Array(payload["proof_paths"]))
  raw_paths.concat(Array(payload["launch_proof_paths"]))
  raw_paths << payload["proof_path"] if payload["proof_path"].is_a?(Hash)

  launch_proof = payload["launch_proof"]
  if launch_proof.is_a?(Hash)
    raw_paths << launch_proof
    raw_paths.concat(Array(launch_proof["paths"]))
  end

  raw_paths.map do |raw_path|
    next raw_path if raw_path.is_a?(Hash)
    next unless raw_path.is_a?(String)

    parts = raw_path.split("/")
    next unless parts.length == 3

    { "tool" => parts[0], "surface" => parts[1], "scenario" => parts[2] }
  end.compact
end

def load_evidence_entries(paths)
  paths.flat_map do |raw_path|
    path = Pathname.new(raw_path)
    payload = parse_json_file(path)
    next [] unless payload.is_a?(Hash)

    entries = payload["evidence"] || payload["paths"] || []
    unless entries.is_a?(Array)
      warn "#{path}: evidence manifest has no evidence array"
      next []
    end

    entries.map do |entry|
      next unless entry.is_a?(Hash)

      enriched = entry.merge("_source" => path.to_s)
      enriched["product_refs"] = normalized_product_refs(enriched)
      enriched
    end.compact
  end
end

def artifact_evidence_entries(artifacts)
  artifacts.flat_map do |path, payload|
    proof_paths(payload).map do |proof_path|
      inferred = compact_hash(
        "product_refs" => normalized_product_refs(payload),
        "workspace" => payload["workspace"] || payload.dig("cache", "workspace"),
        "cache_tag" => payload["cache_tag"] || payload.dig("cache", "tag"),
        "run_uid" => payload["run_uid"] || payload["run_id"] || payload.dig("run", "uid"),
        "mode" => cache_mode(payload),
        "adapter" => payload["adapter"] || payload["tool"] || payload["category"],
        "new_blob_count" => payload.dig("oci", "new_blob_count"),
        "remote_fetches" => payload.dig("oci", "remote_fetches") || payload.dig("diagnostics", "remote_fetches"),
        "publish_status" => payload["publish_status"] || payload.dig("classification", "publish_status"),
        "session_summary" => payload["cache_session_summary"] || payload["summary_json"] || payload.dig("diagnostics", "cache_session_summary"),
        "reporting_url" => payload["reporting_url"] || payload.dig("diagnostics", "reporting_url")
      )

      inferred.merge(proof_path).merge(
        "status" => proof_path["status"] || "pass",
        "artifact" => proof_path["artifact"] || path.to_s,
        "_source" => path.to_s
      )
    end
  end
end

def successful_evidence?(entry)
  status = entry["status"].to_s
  status.empty? || %w[pass passed ok success valid].include?(status)
end

def evidence_matches?(entry, requirement, scenario)
  return false unless successful_evidence?(entry)
  return false unless entry["tool"].to_s == requirement["tool"].to_s
  return false unless entry["surface"].to_s == requirement["surface"].to_s
  return false unless entry["scenario"].to_s == scenario.to_s

  true
end

def required_fields_for(matrix_payload, requirement, scenario)
  fields = []
  fields.concat(Array(matrix_payload["default_required_fields"]))
  fields.concat(Array(requirement["required_fields"]))

  fields_by_scenario = requirement["required_fields_by_scenario"]
  fields.concat(Array(fields_by_scenario[scenario])) if fields_by_scenario.is_a?(Hash)

  fields
end

def validate_matrix(path, evidence_entries, errors)
  payload = parse_json_file(Pathname.new(path))
  unless payload.is_a?(Hash)
    errors << "launch proof matrix #{path} is missing or invalid JSON"
    return
  end

  requirements = payload["paths"]
  unless requirements.is_a?(Array)
    errors << "launch proof matrix #{path} has no paths array"
    return
  end

  requirements.each do |requirement|
    unless requirement.is_a?(Hash)
      errors << "launch proof matrix #{path} contains a non-object path"
      next
    end
    next if requirement["required"] == false

    tool = requirement["tool"]
    surface = requirement["surface"]
    if !present?(tool) || !present?(surface)
      errors << "launch proof matrix #{path} has a path missing tool or surface"
      next
    end

    scenarios = requirement["required_scenarios"]
    if !scenarios.is_a?(Array) || scenarios.empty?
      errors << "launch proof matrix #{path}: #{tool}/#{surface} has no required_scenarios"
      next
    end

    scenarios.each do |scenario|
      required_fields = required_fields_for(payload, requirement, scenario)
      path_matches = evidence_entries.select { |entry| evidence_matches?(entry, requirement, scenario) }
      matches = path_matches.select { |entry| missing_required_fields(entry, required_fields).empty? }
      min_count = requirement.fetch("min_counts", {})[scenario].to_i
      min_count = 1 if min_count <= 0
      next if matches.length >= min_count

      if path_matches.any? && required_fields.any?
        missing_examples = path_matches.first(3).map do |entry|
          source = entry["_source"] || entry["artifact"] || "evidence"
          missing = missing_required_fields(entry, required_fields)
          "#{source} missing #{missing.join(", ")}"
        end.join("; ")
        errors << "missing launch proof path #{tool}/#{surface}/#{scenario} with required fields (need #{min_count}, found #{matches.length}; #{missing_examples})"
      else
        errors << "missing launch proof path #{tool}/#{surface}/#{scenario} (need #{min_count}, found #{matches.length})"
      end
    end
  end
end

def validate_product_refs(payload, path, options, errors)
  refs = normalized_product_refs(payload)
  unless refs.any?
    errors << "#{path}: missing product_refs or release ref fields"
    return
  end

  if payload["product_refs_consistent"] == false
    errors << "#{path}: product_refs are not consistent across rolled-up samples"
  end

  %w[cli_version action_ref action_sha web_revision api_url].each do |key|
    errors << "#{path}: missing product_refs.#{key}" unless present?(refs[key])
  end

  expected_action_ref = options[:expected_action_ref]
  if present?(expected_action_ref) && present?(refs["action_ref"]) && refs["action_ref"] != expected_action_ref
    errors << "#{path}: product_refs.action_ref=#{refs["action_ref"]}, expected #{expected_action_ref}"
  end

  {
    cli_version: "cli_version",
    action_sha: "action_sha",
    web_revision: "web_revision"
  }.each do |option_key, ref_key|
    expected = options[option_key]
    next unless present?(expected)
    next if refs[ref_key] == expected

    errors << "#{path}: product_refs.#{ref_key}=#{refs[ref_key].inspect}, expected #{expected}"
  end
end

def validate_evidence_product_refs(evidence_entries, options, errors)
  return unless options[:require_evidence_product_refs]

  evidence_entries.each do |entry|
    next unless successful_evidence?(entry)
    next unless present?(entry["tool"]) && present?(entry["surface"]) && present?(entry["scenario"])

    source = entry["_source"] || entry["artifact"] || "evidence"
    label = "#{source}: #{entry["tool"]}/#{entry["surface"]}/#{entry["scenario"]}"
    validate_product_refs(entry, label, options, errors)
  end
end

def validate_classification(payload, path, options, errors)
  classification = payload["classification"]
  unless classification.is_a?(Hash)
    errors << "#{path}: missing classification"
    return
  end

  errors << "#{path}: classification.sample_valid=false" if classification["sample_valid"] == false
  errors << "#{path}: classification.reporting_mode=invalid" if classification["reporting_mode"].to_s == "invalid"

  return unless options[:require_fresh_cache_import]
  return unless payload["lane"].to_s == "fresh"
  return unless warm_artifact?(payload)
  return unless docker_artifact?(payload) || present?(classification["cache_import_status"])

  status = classification["cache_import_status"].to_s
  errors << "#{path}: fresh warm cache_import_status=#{status.empty? ? "<missing>" : status}, expected ok" unless status == "ok"
end

def validate_cache_mode(payload, path, errors)
  errors << "#{path}: missing cache mode/strategy" unless present?(cache_mode(payload))
  errors << "#{path}: missing lane" unless present?(payload["lane"])
end

def validate_docker_oci(payload, path, options, errors)
  return unless options[:require_docker_oci]
  return unless docker_artifact?(payload)

  oci = payload["oci"]
  unless oci.is_a?(Hash)
    errors << "#{path}: Docker artifact missing oci diagnostics"
    return
  end

  %w[hydration_policy new_blob_count upload_requested_blobs upload_already_present].each do |key|
    errors << "#{path}: missing oci.#{key}" unless present?(oci[key])
  end
end

def diagnostics_summary_count(paths)
  files_under(paths, "**/*").sum do |path|
    next 0 unless path.file?
    next 0 if path.size > 20 * 1024 * 1024

    text = path.read
    count = 0
    count += text.scan(/"operation"\s*:\s*"cache_session_summary"/).length
    count += text.scan(/operation=cache_session_summary/).length
    count += text.scan(/"session_summary"\s*:/).length
    text.scan(/request_metrics_cache_session_summaries=(\d+)/).each do |match|
      count += 1 if match.first.to_i.positive?
    end
    count
  rescue ArgumentError, Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
    0
  end
end

artifact_paths = files_under(options[:artifacts], "**/*.json")
artifacts = artifact_paths.flat_map do |path|
  payload = parse_json_file(path)
  if benchmark_artifact?(payload)
    [[path, payload]]
  else
    aggregate_boringcache_artifacts(payload).map.with_index do |artifact, index|
      ["#{path}#boringcache-#{index + 1}", artifact]
    end
  end
end.compact

errors = []
errors << "no BoringCache benchmark artifact JSON files found under #{options[:artifacts].join(", ")}" if artifacts.empty?

artifacts.each do |path, payload|
  puts "checking #{path}" if options[:verbose]
  validate_product_refs(payload, path, options, errors)
  validate_cache_mode(payload, path, errors)
  validate_classification(payload, path, options, errors)
  validate_docker_oci(payload, path, options, errors)
end

embedded_summary_count = artifacts.count { |_, payload| embedded_session_summary?(payload) }
diagnostic_summary_count = diagnostics_summary_count(options[:diagnostics])
summary_count = embedded_summary_count + diagnostic_summary_count
evidence_entries = load_evidence_entries(options[:evidence]) + artifact_evidence_entries(artifacts)
validate_evidence_product_refs(evidence_entries, options, errors)

if options[:require_diagnostics] && summary_count.zero?
  errors << "missing cache_session_summary evidence; pass --diagnostics with request metrics/status artifacts or embed cache_session_summary in benchmark JSON"
end

validate_matrix(options[:matrix], evidence_entries, errors) if options[:matrix]

if errors.any?
  warn "launch proof failed:"
  errors.each { |error| warn "  - #{error}" }
  exit 1
end

coverage_suffix = options[:matrix] ? ", #{evidence_entries.length} matrix evidence item(s)" : ""
puts "launch proof passed: #{artifacts.length} BoringCache artifact(s), #{summary_count} cache_session_summary evidence item(s)#{coverage_suffix}"
