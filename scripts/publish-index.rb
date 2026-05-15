#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "time"
require "tmpdir"
require_relative "benchmark-reporting"

OUTPUT_DIR = File.join("data", "latest")
OUTPUT_PATH = File.join(OUTPUT_DIR, "index.json")
DETAIL_OUTPUT_DIR = File.join(OUTPUT_DIR, "benchmarks")
REPORT_PATH = File.join(OUTPUT_DIR, "report.md")
README_PATH = "README.md"
MAX_CMD_RETRIES = ENV.fetch("BENCHMARKS_GH_RETRIES", "3").to_i
RUN_HISTORY_LIMIT = ENV.fetch("BENCHMARKS_GH_RUN_LIMIT", "100").to_i
PAIR_COUNT = ENV.fetch("BENCHMARKS_PAIR_COUNT", "3").to_i
CMD_TIMEOUT_SECONDS = ENV.fetch("BENCHMARKS_CMD_TIMEOUT", "120").to_i
PRESERVE_STALE_ENTRIES = ENV.fetch("BENCHMARKS_PRESERVE_STALE", "false") == "true"
LANE_IDS = %w[fresh rolling].freeze
README_REPORT_START = "<!-- benchmark-report:start -->"
README_REPORT_END = "<!-- benchmark-report:end -->"
PRODUCT_REF_KEYS = %w[cli_version action_ref action_sha web_revision api_url].freeze

BENCHMARKS = [
  {
    "benchmark" => "hugo",
    "name" => "Hugo",
    "logo" => "hugo",
    "repo" => "gohugoio/hugo",
    "source_repo" => "boringcache/benchmark-hugo",
    "public" => true,
    "category" => "docker",
    "step" => "Docker build (Go)",
    "actions_workflow" => "Hugo - Actions Cache",
    "boringcache_workflow" => "Hugo - BoringCache"
  },
  {
    "benchmark" => "hugo-go",
    "name" => "Hugo Go",
    "logo" => "hugo",
    "repo" => "gohugoio/hugo",
    "source_repo" => "boringcache/benchmark-hugo-go",
    "public" => true,
    "category" => "go",
    "step" => "Go build (native build cache)",
    "actions_workflow" => "Hugo Go - Actions Cache",
    "boringcache_workflow" => "Hugo Go - BoringCache"
  },
  {
    "benchmark" => "immich",
    "name" => "Immich",
    "logo" => "immich",
    "repo" => "immich-app/immich",
    "source_repo" => "boringcache/benchmark-immich",
    "public" => true,
    "category" => "docker",
    "step" => "Docker build (server)",
    "actions_workflow" => "Immich - Actions Cache",
    "boringcache_workflow" => "Immich - BoringCache"
  },
  {
    "benchmark" => "mastodon-docker",
    "aliases" => ["mastodon"],
    "name" => "Mastodon",
    "logo" => "mastodon",
    "repo" => "mastodon/mastodon",
    "source_repo" => "boringcache/benchmark-mastodon",
    "public" => true,
    "category" => "docker",
    "step" => "Docker build (Ruby+Node)",
    "actions_workflow" => "Mastodon Docker - Actions Cache",
    "boringcache_workflow" => "Mastodon Docker - BoringCache"
  },
  {
    "benchmark" => "posthog",
    "name" => "PostHog",
    "logo" => "posthog",
    "repo" => "PostHog/posthog",
    "source_repo" => "boringcache/benchmark-posthog",
    "public" => true,
    "category" => "docker",
    "step" => "Docker build (full stack)",
    "actions_workflow" => "PostHog - Actions Cache",
    "boringcache_workflow" => "PostHog - BoringCache"
  },
  {
    "benchmark" => "storybook",
    "name" => "Storybook",
    "logo" => "storybook",
    "repo" => "storybookjs/storybook",
    "source_repo" => "boringcache/benchmark-storybook",
    "public" => true,
    "category" => "nodejs",
    "step" => "Nx build (Yarn monorepo)",
    "actions_workflow" => "Storybook - Actions Cache",
    "boringcache_workflow" => "Storybook - BoringCache"
  },
  {
    "benchmark" => "otel-gradle",
    "name" => "OpenTelemetry Java",
    "logo" => "docker",
    "repo" => "open-telemetry/opentelemetry-java",
    "source_repo" => "boringcache/benchmark-opentelemetry-java",
    "public" => false,
    "category" => "gradle",
    "step" => "Gradle build (native HTTP cache)",
    "actions_workflow" => "OpenTelemetry Java Gradle - Actions Cache",
    "boringcache_workflow" => "OpenTelemetry Java Gradle - BoringCache"
  },
  {
    "benchmark" => "spring-ai-maven",
    "name" => "Spring AI",
    "logo" => "docker",
    "repo" => "spring-projects/spring-ai",
    "source_repo" => "boringcache/benchmark-spring-ai",
    "public" => false,
    "category" => "maven",
    "step" => "Maven build (build-cache extension)",
    "actions_workflow" => "Spring AI Maven - Actions Cache",
    "boringcache_workflow" => "Spring AI Maven - BoringCache"
  },
  {
    "benchmark" => "grpc-bazel",
    "name" => "gRPC",
    "logo" => "grpc",
    "repo" => "grpc/grpc",
    "source_repo" => "boringcache/benchmark-grpc",
    "public" => false,
    "category" => "bazel",
    "step" => "Bazel build (remote cache)",
    "actions_workflow" => "gRPC Bazel - Actions Cache",
    "boringcache_workflow" => "gRPC Bazel - BoringCache"
  },
  {
    "benchmark" => "zed-sccache",
    "name" => "Zed",
    "logo" => "zed",
    "repo" => "zed-industries/zed",
    "source_repo" => "boringcache/benchmark-zed",
    "public" => false,
    "category" => "rust",
    "step" => "Rust build (sccache)",
    "actions_workflow" => "Zed sccache - Actions Cache",
    "boringcache_workflow" => "Zed sccache - BoringCache"
  },
  {
    "benchmark" => "n8n",
    "name" => "n8n",
    "logo" => "n8n",
    "repo" => "n8n-io/n8n",
    "source_repo" => "boringcache/benchmark-n8n",
    "public" => true,
    "category" => "nodejs",
    "step" => "Turbo build (pnpm monorepo)",
    "actions_workflow" => "n8n - Actions Cache",
    "boringcache_workflow" => "n8n - BoringCache"
  }
].freeze

def run_cmd(*args)
  attempts = 0

  begin
    stdout, stderr, status = capture_cmd(*args)
    raise "Command failed: #{args.join(' ')}\n#{stderr}" unless status.success?

    stdout
  rescue StandardError => e
    attempts += 1
    if args.first == "gh" && attempts < [MAX_CMD_RETRIES, 1].max
      sleep(attempts * 2)
      retry
    end
    raise e
  end
end

def require_gh!
  return if system("gh", "--version", out: File::NULL, err: File::NULL)

  raise "GitHub CLI `gh` is required on PATH to publish fresh benchmark data; refusing to reuse stale aggregate entries"
end

def capture_cmd(*args)
  Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
    stdin.close
    stdout_reader = Thread.new { stdout.read rescue "" }
    stderr_reader = Thread.new { stderr.read rescue "" }
    unless wait_thread.join(CMD_TIMEOUT_SECONDS)
      begin
        Process.kill("TERM", wait_thread.pid)
        sleep(1)
        Process.kill("KILL", wait_thread.pid) if wait_thread.alive?
      rescue Errno::ESRCH
      end
      raise "Command timed out after #{CMD_TIMEOUT_SECONDS}s: #{args.join(' ')}"
    end

    [stdout_reader.value, stderr_reader.value, wait_thread.value]
  end
end

def parse_timestamp(value)
  return nil if value.nil? || value.to_s.empty?

  Time.parse(value.to_s)
rescue ArgumentError
  nil
end

def parse_number(value)
  return nil if value.nil? || value.to_s == ""

  Float(value)
rescue ArgumentError, TypeError
  nil
end

def load_existing_entries
  return {} unless File.exist?(OUTPUT_PATH)

  payload = JSON.parse(File.read(OUTPUT_PATH))
  Array(payload["entries"]).each_with_object({}) do |entry, acc|
    benchmark = entry["benchmark"].to_s
    next if benchmark.empty?

    acc[benchmark] = entry
  end
rescue StandardError => e
  warn "Ignoring existing index at #{OUTPUT_PATH}: #{e.message}"
  {}
end

def seconds_to_text(value)
  total = value.round
  minutes = total / 60
  seconds = total % 60
  "#{minutes}m #{seconds}s"
end

def markdown_escape(value)
  value.to_s.gsub(/[|\r\n]/, "|" => "\\|", "\r" => " ", "\n" => "<br>")
end

def bytes_to_text(value)
  return "—" if value.nil?

  units = ["B", "KB", "MB", "GB", "TB"].freeze
  size = value.to_f.abs
  unit_index = 0

  while size >= 1024 && unit_index < units.length - 1
    size /= 1024.0
    unit_index += 1
  end

  format("%<size>.2f %<unit>s", size: size, unit: units[unit_index])
end

def storage_summary_text(comparison)
  saved_bytes = comparison["storage_saved_bytes"]
  improvement_pct = comparison["storage_improvement_pct"]
  return "—" if saved_bytes.nil?

  if saved_bytes.to_f >= 0
    "#{bytes_to_text(saved_bytes)} (#{improvement_pct}%)"
  else
    "#{bytes_to_text(saved_bytes)} more (#{improvement_pct}%)"
  end
end

def normalize_storage_sample(bytes, source)
  normalized_bytes = bytes&.round&.to_i
  normalized_source = source.to_s.strip
  normalized_source = nil if normalized_source.empty? || normalized_source == "unspecified"
  return [nil, nil] if normalized_source.nil?
  return [nil, nil] if normalized_bytes.nil? || normalized_bytes <= 0

  [normalized_bytes, normalized_source]
end

def compact_hash(hash)
  hash.each_with_object({}) do |(key, value), acc|
    next if value.nil?
    next if value.respond_to?(:empty?) && value.empty?

    acc[key] = value
  end
end

def normalized_product_refs(payload)
  raw_refs = payload["product_refs"].is_a?(Hash) ? payload["product_refs"] : {}

  PRODUCT_REF_KEYS.each_with_object({}) do |key, acc|
    value = raw_refs[key]
    value = payload[key] if value.nil? || value.to_s.empty?
    next if value.nil? || value.to_s.empty?

    acc[key] = value
  end
end

def session_summary_from(payload)
  payload["cache_session_summary"] ||
    payload["session_summary"] ||
    payload["summary_json"] ||
    payload.dig("diagnostics", "cache_session_summary") ||
    payload.dig("diagnostics", "summary_json")
end

def startup_prefetch_from(payload, session_summary)
  summary = session_summary.is_a?(Hash) && session_summary["startup_prefetch"].is_a?(Hash) ? session_summary["startup_prefetch"] : {}
  direct = payload["startup_prefetch"].is_a?(Hash) ? payload["startup_prefetch"] : {}
  raw = summary.merge(compact_hash(direct))

  compact_hash(
    "duration_ms" => parse_number(raw["duration_ms"] || raw["startup_prefetch_duration_ms"]),
    "target_blobs" => parse_number(raw["target_blobs"] || raw["startup_prefetch_target_blobs"]),
    "target_bytes" => parse_number(raw["target_bytes"] || raw["startup_prefetch_target_bytes"]),
    "concurrency" => parse_number(raw["concurrency"] || raw["startup_prefetch_concurrency"]),
    "initial_concurrency" => parse_number(raw["initial_concurrency"] || raw["startup_prefetch_initial_concurrency"]),
    "final_concurrency" => parse_number(raw["final_concurrency"] || raw["startup_prefetch_final_concurrency"]),
    "max_observed_concurrency" => parse_number(raw["max_observed_concurrency"] || raw["startup_prefetch_max_observed_concurrency"]),
    "concurrency_reason" => raw["concurrency_reason"] || raw["startup_prefetch_concurrency_reason"],
    "retries" => parse_number(raw["retries"] || raw["startup_prefetch_retries"]),
    "failures" => parse_number(raw["failures"] || raw["startup_prefetch_failures"])
  )
end

def launch_proof_paths_from(payload)
  paths = []
  paths.concat(Array(payload["proof_paths"]))
  paths.concat(Array(payload["launch_proof_paths"]))
  paths << payload["proof_path"] if payload["proof_path"].is_a?(Hash)

  launch_proof = payload["launch_proof"]
  if launch_proof.is_a?(Hash)
    paths << launch_proof
    paths.concat(Array(launch_proof["paths"]))
  end

  paths.compact
end

def percent_delta(baseline, candidate)
  return nil if baseline.nil? || candidate.nil? || baseline <= 0

  ((baseline.to_f - candidate.to_f) / baseline.to_f) * 100.0
end

def average(values)
  values = values.compact
  return nil if values.empty?

  values.sum.to_f / values.length
end

def timing_result_bucket(before_value, after_value)
  delta_pct = percent_delta(before_value, after_value)
  return nil if delta_pct.nil?

  delta_seconds = (before_value.to_f - after_value.to_f).abs
  longest = [before_value.to_f, after_value.to_f].max
  return :tie if delta_seconds <= 5 && longest <= 60
  return :tie if delta_pct.abs < 3.0

  delta_pct.positive? ? :faster : :slower
end

def timing_result_text(before_value, after_value)
  delta_pct = percent_delta(before_value, after_value)
  return "—" if delta_pct.nil?

  case timing_result_bucket(before_value, after_value)
  when :faster
    "#{delta_pct.round}% faster"
  when :slower
    "#{delta_pct.abs.round}% slower"
  else
    "near tie"
  end
end

def latest_successful_runs(repo:, workflow_name:, limit: RUN_HISTORY_LIMIT)
  output = run_cmd(
    "gh", "run", "list",
    "--repo", repo,
    "--workflow", workflow_name,
    "--status", "completed",
    "--limit", limit.to_s,
    "--json", "databaseId,conclusion,createdAt,url,headSha"
  )

  JSON.parse(output)
    .select { |item| item["conclusion"] == "success" }
    .sort_by { |item| parse_timestamp(item["createdAt"]) || Time.at(0) }
    .reverse
end

def benchmark_artifact_name(repo:, run_id:, benchmark_id:, strategy:)
  output = run_cmd("gh", "api", "repos/#{repo}/actions/runs/#{run_id}/artifacts")
  artifacts = JSON.parse(output).fetch("artifacts", [])
  benchmark_ids = Array(benchmark_id)

  artifact = artifacts.find do |item|
    name = item["name"].to_s
    !item["expired"] && benchmark_ids.any? { |id| name.start_with?("benchmark-#{id}-#{strategy}") }
  end

  artifact && artifact["name"]
end

def lane_artifact_names(benchmark_id:, strategy:, lane:)
  Array(benchmark_id).flat_map do |id|
    names = ["benchmark-#{id}-#{strategy}-#{lane}"]
    names << "benchmark-#{id}-#{strategy}" if lane == "fresh"
    names
  end
end

def benchmark_artifact_ids(benchmark)
  [benchmark.fetch("benchmark"), *Array(benchmark["aliases"])].uniq
end

def benchmark_artifact_name_for_lane(repo:, run_id:, benchmark_id:, strategy:, lane:)
  output = run_cmd("gh", "api", "repos/#{repo}/actions/runs/#{run_id}/artifacts")
  artifacts = JSON.parse(output).fetch("artifacts", [])
  candidate_names = lane_artifact_names(benchmark_id: benchmark_id, strategy: strategy, lane: lane)

  artifact = artifacts.find do |item|
    name = item["name"].to_s
    !item["expired"] && candidate_names.include?(name)
  end

  artifact && artifact["name"]
end

def list_run_artifacts(repo:, run_id:, cache:)
  key = [repo, run_id]
  return cache[key] if cache.key?(key)

  output = run_cmd("gh", "api", "repos/#{repo}/actions/runs/#{run_id}/artifacts")
  cache[key] = JSON.parse(output).fetch("artifacts", []).reject { |item| item["expired"] }
rescue StandardError
  cache[key] = []
end

def runs_by_head_grouped(runs)
  runs.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |run, acc|
    head = run["headSha"].to_s
    next if head.empty?

    acc[head] << run
  end
end

def latest_run_with_artifact(runs_for_head:, repo:, benchmark_id:, strategy:, lane:, artifacts_cache:)
  return nil if runs_for_head.nil? || runs_for_head.empty?

  candidate_names = lane_artifact_names(benchmark_id: benchmark_id, strategy: strategy, lane: lane)
  sorted = runs_for_head.sort_by { |run| parse_timestamp(run["createdAt"]) || Time.at(0) }.reverse
  sorted.find do |run|
    artifacts = list_run_artifacts(repo: repo, run_id: run["databaseId"], cache: artifacts_cache)
    artifacts.any? { |item| candidate_names.include?(item["name"].to_s) }
  end
end

def fetch_run_jobs(repo:, run_id:)
  output = run_cmd(
    "gh", "api",
    "repos/#{repo}/actions/runs/#{run_id}/jobs?per_page=100"
  )
  JSON.parse(output).fetch("jobs", [])
end

def duration_seconds(started_at:, completed_at:)
  started = parse_timestamp(started_at)
  completed = parse_timestamp(completed_at)
  return nil unless started && completed && completed >= started

  completed - started
end

def job_duration_seconds(job)
  duration_seconds(
    started_at: job["startedAt"] || job["started_at"],
    completed_at: job["completedAt"] || job["completed_at"]
  )
end

def run_total_seconds(repo:, run_id:)
  jobs = fetch_run_jobs(repo: repo, run_id: run_id)
  return nil if jobs.empty?

  jobs.map { |job| job_duration_seconds(job) }.compact.max
rescue StandardError
  nil
end

def download_artifact_json(repo:, run_id:, artifact_name:, temp_dir:)
  run_cmd(
    "gh", "run", "download", run_id.to_s,
    "--repo", repo,
    "-n", artifact_name,
    "--dir", temp_dir
  )

  json_files = Dir.glob(File.join(temp_dir, "**", "*.json")).sort
  expected_summary = "#{artifact_name.sub(/\Abenchmark-/, "")}.json"
  json_file = json_files.find { |path| File.basename(path) == expected_summary }
  json_file ||= json_files.find { |path| !File.basename(path).include?("phase-breakdown") }
  json_file ||= json_files.first
  return nil unless json_file

  JSON.parse(File.read(json_file))
end

def extract_strategy_metrics(payload)
  runs = payload.fetch("runs", {})
  speed = payload.fetch("speed", {})
  cache = payload.fetch("cache", {})
  docker_cache = payload.fetch("docker_cache", {})
  oci = payload.fetch("oci", {})
  classification = payload.fetch("classification", {})
  product_refs = normalized_product_refs(payload)
  session_summary = session_summary_from(payload)
  startup_prefetch = startup_prefetch_from(payload, session_summary)
  summary_proxy = session_summary.is_a?(Hash) && session_summary["proxy"].is_a?(Hash) ? session_summary["proxy"] : {}
  proxy = payload["proxy"].is_a?(Hash) ? payload["proxy"] : {}

  warm1 = parse_number(runs["warm1_seconds"])
  warm2 = parse_number(runs["warm2_seconds"])
  warm_avg = parse_number(speed["warm_average_seconds"])
  if warm_avg.nil?
    warm_values = [warm1, warm2].compact
    warm_avg = warm_values.sum / warm_values.length if warm_values.any?
  end

  storage_bytes, storage_source = normalize_storage_sample(
    parse_number(cache["storage_bytes"]),
    cache["storage_source"]
  )
  raw_mode = payload["mode"] || cache["mode"]
  mode = raw_mode.nil? || raw_mode == payload["strategy"] ? inferred_mode(payload) : raw_mode
  raw_adapter = payload["adapter"] || payload["tool"]
  adapter = raw_adapter.nil? || raw_adapter == payload["strategy"] ? inferred_adapter(payload.merge("mode" => mode)) : raw_adapter

  {
    cold_seconds: parse_number(runs["cold_seconds"]),
    cold_build_seconds: parse_number(runs["cold_build_seconds"]),
    cold_restore_or_setup_seconds: parse_number(runs["cold_restore_or_setup_seconds"]),
    warm1_seconds: warm1,
    warm1_build_seconds: parse_number(runs["warm1_build_seconds"]),
    warm1_restore_or_setup_seconds: parse_number(runs["warm1_restore_or_setup_seconds"]),
    warm2_seconds: warm2,
    warm_average_seconds: warm_avg,
    rolling_first_build_seconds: parse_number(runs["rolling_first_build_seconds"]),
    rolling_warm_seconds: parse_number(runs["rolling_warm_seconds"]),
    storage_bytes: storage_bytes,
    storage_source: storage_source,
    docker_cache_import_seconds: parse_number(docker_cache["import_seconds"]),
    docker_cache_export_seconds: parse_number(docker_cache["export_seconds"]),
    startup_prefetch: startup_prefetch,
    oci: oci,
    classification: classification,
    product_refs: product_refs,
    product_refs_consistent: product_refs.any? ? true : nil,
    launch_proof_paths: launch_proof_paths_from(payload),
    workspace: payload["workspace"] || cache["workspace"],
    cache_tag: payload["cache_tag"] || cache["tag"],
    run_uid: payload["run_uid"] || payload["run_id"] || payload.dig("run", "uid"),
    mode: mode,
    adapter: adapter,
    docker_cache_from_refs: payload["docker_cache_from_refs"] || docker_cache["from_refs"],
    docker_cache_import_ready: payload["docker_cache_import_ready"] || docker_cache["import_ready"],
    http_transport: payload["http_transport"] || proxy["http_transport"] || summary_proxy["http_transport"],
    http2_enabled: payload["http2_enabled"] || proxy["http2_enabled"] || summary_proxy["http2_enabled"],
    oci_stream_through_min_bytes: payload["oci_stream_through_min_bytes"] || oci["stream_through_min_bytes"] || summary_proxy["oci_stream_through_min_bytes"],
    restore_result: payload["restore_result"],
    save_result: payload["save_result"],
    publish_status: payload["publish_status"] || classification["publish_status"],
    session_summary: session_summary,
    summary_schema: payload["summary_schema"] || payload["summary_schema_label"],
    reporting_url: payload["reporting_url"] || payload.dig("diagnostics", "reporting_url")
  }
end

def inferred_mode(payload)
  return payload["strategy"] unless payload["strategy"] == "boringcache"

  benchmark = payload["benchmark"].to_s
  case benchmark
  when /hugo|immich|mastodon|posthog/
    "docker"
  when /grpc|bazel/
    "bazel"
  when /zed|sccache/
    "sccache"
  when /gradle|otel/
    "gradle"
  when /maven|spring/
    "maven"
  when /storybook|nx/
    "nx"
  when /n8n|turbo/
    "turbo"
  when /go/
    "go"
  else
    payload["category"] || payload["strategy"]
  end
end

def inferred_adapter(payload)
  mode = payload["mode"] || inferred_mode(payload)
  case mode
  when "docker"
    "oci"
  when "go"
    "gocache"
  when "turbo"
    "turborepo"
  else
    mode
  end
end

def payload_lane(payload)
  lane = payload["lane"].to_s.strip
  lane.empty? ? "fresh" : lane
end

def lane_label(lane)
  case lane.to_s
  when "rolling"
    "Rolling"
  else
    "Fresh"
  end
end

def first_build_label(lane)
  case lane.to_s
  when "rolling"
    "Commit build"
  else
    "Cold build"
  end
end

def warm_steady_seconds(metrics)
  metrics[:warm2_seconds] || metrics[:warm_average_seconds] || metrics[:warm1_seconds]
end

def headline_candidates(actions_metrics:, boringcache_metrics:, actions_run_total:, boringcache_run_total:)
  [
    ["warm", warm_steady_seconds(actions_metrics), warm_steady_seconds(boringcache_metrics)],
    ["cold", actions_metrics[:cold_seconds], boringcache_metrics[:cold_seconds]],
    ["run_total", actions_run_total, boringcache_run_total]
  ].select { |_, before_value, after_value| before_value && after_value }
end

def load_strategy_data(temp_root:, repo:, run:, benchmark_id:, strategy:, lane:, cache:)
  run_id = run.fetch("databaseId")
  cache_key = [repo, run_id, benchmark_id, strategy, lane]
  return cache[cache_key] if cache.key?(cache_key)

  artifact_name = benchmark_artifact_name_for_lane(
    repo: repo,
    run_id: run_id,
    benchmark_id: benchmark_id,
    strategy: strategy,
    lane: lane
  )
  run_total = run_total_seconds(repo: repo, run_id: run_id)

  if artifact_name.nil?
    cache[cache_key] = { run: run, run_total_seconds: run_total, metrics: nil }
    return cache[cache_key]
  end

  run_tmp = File.join(temp_root, "#{Array(benchmark_id).first}-#{strategy}-#{run_id}")
  FileUtils.mkdir_p(run_tmp)
  payload = download_artifact_json(repo: repo, run_id: run_id, artifact_name: artifact_name, temp_dir: run_tmp)

  if payload.nil? || payload_lane(payload) != lane
    cache[cache_key] = { run: run, run_total_seconds: run_total, metrics: nil }
    return cache[cache_key]
  end

  cache[cache_key] = {
    run: run,
    run_total_seconds: run_total,
    metrics: extract_strategy_metrics(payload)
  }
end

def strategy_snapshot(data)
  metrics = data.fetch(:metrics)
  run = data.fetch(:run)

  {
    "run_id" => run["databaseId"],
    "run_url" => run["url"],
    "head_sha" => run["headSha"],
    "created_at" => run["createdAt"],
    "cold_seconds" => metrics[:cold_seconds],
    "cold_build_seconds" => metrics[:cold_build_seconds],
    "cold_restore_or_setup_seconds" => metrics[:cold_restore_or_setup_seconds],
    "warm1_seconds" => metrics[:warm1_seconds],
    "warm1_build_seconds" => metrics[:warm1_build_seconds],
    "warm1_restore_or_setup_seconds" => metrics[:warm1_restore_or_setup_seconds],
    "warm2_seconds" => metrics[:warm2_seconds],
    "warm_average_seconds" => metrics[:warm_average_seconds],
    "warm_steady_seconds" => warm_steady_seconds(metrics),
    "rolling_first_build_seconds" => metrics[:rolling_first_build_seconds],
    "rolling_warm_seconds" => metrics[:rolling_warm_seconds],
    "run_total_seconds" => data[:run_total_seconds],
    "storage_bytes" => metrics[:storage_bytes],
    "storage_source" => metrics[:storage_source],
    "docker_cache_import_seconds" => metrics[:docker_cache_import_seconds],
    "docker_cache_export_seconds" => metrics[:docker_cache_export_seconds],
    "startup_prefetch" => metrics[:startup_prefetch],
    "oci" => metrics[:oci],
    "classification" => metrics[:classification],
    "product_refs" => metrics[:product_refs],
    "product_refs_consistent" => metrics[:product_refs_consistent],
    "launch_proof_paths" => metrics[:launch_proof_paths],
    "workspace" => metrics[:workspace],
    "cache_tag" => metrics[:cache_tag],
    "run_uid" => metrics[:run_uid],
    "mode" => metrics[:mode],
    "adapter" => metrics[:adapter],
    "docker_cache_from_refs" => metrics[:docker_cache_from_refs],
    "docker_cache_import_ready" => metrics[:docker_cache_import_ready],
    "http_transport" => metrics[:http_transport],
    "http2_enabled" => metrics[:http2_enabled],
    "oci_stream_through_min_bytes" => metrics[:oci_stream_through_min_bytes],
    "restore_result" => metrics[:restore_result],
    "save_result" => metrics[:save_result],
    "publish_status" => metrics[:publish_status],
    "session_summary" => metrics[:session_summary],
    "summary_schema" => metrics[:summary_schema],
    "reporting_url" => metrics[:reporting_url]
  }
end

def headline_metric_for(actions_metrics:, boringcache_metrics:, actions_run_total:, boringcache_run_total:)
  candidates = headline_candidates(
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics,
    actions_run_total: actions_run_total,
    boringcache_run_total: boringcache_run_total
  )
  return nil if candidates.empty?

  winning_candidates = candidates.each_with_object([]) do |(scenario, before_value, after_value), acc|
    improvement = percent_delta(before_value, after_value)
    next unless improvement&.positive?

    acc << [scenario, before_value, after_value, improvement]
  end

  if winning_candidates.any?
    scenario, before_value, after_value, = winning_candidates.max_by { |(_, _, _, improvement)| improvement }
    return [scenario, before_value, after_value]
  end

  cold_candidate = candidates.find { |scenario, _, _| scenario == "cold" }
  return cold_candidate if cold_candidate

  candidates.first
end

def headline_for_scenario(scenario:, actions_metrics:, boringcache_metrics:, actions_run_total:, boringcache_run_total:)
  before_value, after_value = BenchmarkReporting.scenario_pair(
    scenario: scenario,
    actions_cold: actions_metrics[:cold_seconds],
    boringcache_cold: boringcache_metrics[:cold_seconds],
    actions_warm: warm_steady_seconds(actions_metrics),
    boringcache_warm: warm_steady_seconds(boringcache_metrics),
    actions_run_total: actions_run_total,
    boringcache_run_total: boringcache_run_total
  )
  return nil unless before_value && after_value

  [scenario, before_value, after_value]
end

def reporting_summary(lane:, benchmark:, classification:, sample_count:)
  BenchmarkReporting.reporting_summary(
    lane: lane,
    category: benchmark["category"],
    classification: classification,
    sample_count: sample_count
  )
end

def build_entry(benchmark:, pair:, actions_data:, boringcache_data:, lane:)
  actions_metrics = actions_data[:metrics]
  boringcache_metrics = boringcache_data[:metrics]
  return nil if actions_metrics.nil? || boringcache_metrics.nil?
  reporting = reporting_summary(
    lane: lane,
    benchmark: benchmark,
    classification: boringcache_metrics[:classification] || {},
    sample_count: 1
  )
  headline = headline_for_scenario(
    scenario: reporting["headline_scenario"],
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics,
    actions_run_total: actions_data[:run_total_seconds],
    boringcache_run_total: boringcache_data[:run_total_seconds]
  )
  headline ||= headline_metric_for(
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics,
    actions_run_total: actions_data[:run_total_seconds],
    boringcache_run_total: boringcache_data[:run_total_seconds]
  )
  return nil if headline.nil?

  headline_scenario, before_value, after_value = headline
  faster_pct = percent_delta(before_value, after_value)
  return nil if faster_pct.nil?
  faster_pct = [faster_pct, 0].max

  {
    "lane" => lane,
    "lane_label" => lane_label(lane),
    "first_build_label" => first_build_label(lane),
    "benchmark" => benchmark["benchmark"],
    "name" => benchmark["name"],
    "logo" => benchmark["logo"],
    "repo" => benchmark["repo"],
    "source_repo" => benchmark["source_repo"],
    "public" => benchmark.fetch("public"),
    "category" => benchmark["category"],
    "step" => benchmark["step"],
    "headline_scenario" => reporting["headline_scenario"] || headline_scenario,
    "headline_label" => reporting["headline_label"] || BenchmarkReporting.headline_label(lane: lane, scenario: reporting["headline_scenario"] || headline_scenario),
    "before" => seconds_to_text(before_value),
    "after" => seconds_to_text(after_value),
    "before_seconds" => before_value.round(2),
    "after_seconds" => after_value.round(2),
    "faster" => reporting["comparative"] ? faster_pct.round.to_s : nil,
    "comparison" => {
      "paired_on_head_sha" => pair[:paired_on_head_sha],
      "pairing_head_sha" => pair[:pairing_head_sha],
      "actions_cache" => strategy_snapshot(actions_data),
      "boringcache" => strategy_snapshot(boringcache_data),
      "reporting" => reporting,
      "warm_improvement_pct" => percent_delta(
        warm_steady_seconds(actions_metrics),
        warm_steady_seconds(boringcache_metrics)
      )&.round(2),
      "warm_build_improvement_pct" => percent_delta(
        actions_metrics[:warm1_build_seconds],
        boringcache_metrics[:warm1_build_seconds]
      )&.round(2),
      "cold_improvement_pct" => percent_delta(actions_metrics[:cold_seconds], boringcache_metrics[:cold_seconds])&.round(2),
      "cold_build_improvement_pct" => percent_delta(actions_metrics[:cold_build_seconds], boringcache_metrics[:cold_build_seconds])&.round(2),
      "run_total_improvement_pct" => percent_delta(actions_data[:run_total_seconds], boringcache_data[:run_total_seconds])&.round(2),
      "storage_improvement_pct" => percent_delta(actions_metrics[:storage_bytes], boringcache_metrics[:storage_bytes])&.round(2),
      "storage_saved_bytes" => if actions_metrics[:storage_bytes] && boringcache_metrics[:storage_bytes]
        actions_metrics[:storage_bytes] - boringcache_metrics[:storage_bytes]
      end
    }
  }
end

def average_oci_payload(snapshots)
  payloads = snapshots.map { |snapshot| snapshot["oci"] || {} }
  keys = payloads.flat_map(&:keys).uniq
  return {} if keys.empty?

  keys.each_with_object({}) do |key, acc|
    values = payloads.map { |payload| parse_number(payload[key]) }.compact
    next if values.empty?

    acc[key] = average(values)
  end
end

def average_startup_prefetch_payload(snapshots)
  payloads = snapshots.map { |snapshot| snapshot["startup_prefetch"] || {} }
  keys = payloads.flat_map(&:keys).uniq
  return {} if keys.empty?

  keys.each_with_object({}) do |key, acc|
    if key == "concurrency_reason"
      value = most_common(payloads.map { |payload| payload[key] })
      acc[key] = value if value
      next
    end

    values = payloads.map { |payload| parse_number(payload[key]) }.compact
    next if values.empty?

    acc[key] = average(values)
  end
end

def most_common(values)
  values = values.compact.reject { |value| value.to_s.empty? }
  return nil if values.empty?

  values.group_by(&:itself).max_by { |_, grouped| grouped.length }&.first
end

def stable_hash_signature(hash)
  return nil unless hash.is_a?(Hash) && hash.any?

  JSON.generate(hash.sort.to_h)
end

def product_ref_signature(snapshot)
  stable_hash_signature(snapshot && snapshot["product_refs"])
end

def latest_product_ref_signature(snapshots)
  snapshots
    .compact
    .sort_by { |snapshot| parse_timestamp(snapshot["created_at"]) || Time.at(0) }
    .reverse_each do |snapshot|
      signature = product_ref_signature(snapshot)
      return signature if signature
    end

  nil
end

def latest_boringcache_product_cohort(entries)
  snapshots = entries.map { |entry| entry.dig("comparison", "boringcache") }.compact
  signature = latest_product_ref_signature(snapshots)
  return [entries, nil] if signature.nil?

  filtered = entries.select do |entry|
    product_ref_signature(entry.dig("comparison", "boringcache")) == signature
  end
  return [entries, nil] if filtered.empty?

  metadata = nil
  if filtered.length < entries.length
    metadata = {
      "basis" => "latest_boringcache_product_refs",
      "source_sample_count" => entries.length,
      "excluded_sample_count" => entries.length - filtered.length,
      "product_refs" => JSON.parse(signature)
    }
  end

  [filtered, metadata]
end

def most_common_hash(values)
  signatures = values.map { |value| stable_hash_signature(value) }.compact
  return nil if signatures.empty?

  JSON.parse(most_common(signatures))
end

def product_refs_consistent?(snapshots)
  signatures = snapshots.map { |snapshot| stable_hash_signature(snapshot["product_refs"]) }.compact.uniq
  signatures.length <= 1
end

def average_snapshot(snapshots)
  snapshots = snapshots.compact
  return {} if snapshots.empty?

  latest = snapshots.max_by { |snapshot| parse_timestamp(snapshot["created_at"]) || Time.at(0) } || snapshots.first
  averaged = {
    "run_id" => latest["run_id"],
    "run_url" => latest["run_url"],
    "head_sha" => latest["head_sha"],
    "created_at" => latest["created_at"],
    "sample_count" => snapshots.length,
    "sample_run_ids" => snapshots.map { |snapshot| snapshot["run_id"] }.compact,
    "sample_run_urls" => snapshots.map { |snapshot| snapshot["run_url"] }.compact,
    "head_shas" => snapshots.map { |snapshot| snapshot["head_sha"] }.compact.uniq
  }

  numeric_keys = %w[
    cold_seconds cold_build_seconds cold_restore_or_setup_seconds
    warm1_seconds warm1_build_seconds warm1_restore_or_setup_seconds
    warm2_seconds warm_average_seconds warm_steady_seconds
    rolling_first_build_seconds rolling_warm_seconds
    run_total_seconds storage_bytes docker_cache_import_seconds docker_cache_export_seconds
  ]

  numeric_keys.each do |key|
    value = average(snapshots.map { |snapshot| parse_number(snapshot[key]) })
    value = value.round if value && (key == "storage_bytes" || key.end_with?("_bytes"))
    averaged[key] = value
  end

  oci_payload = average_oci_payload(snapshots)
  hydration_policy = most_common(snapshots.map { |snapshot| snapshot.dig("oci", "hydration_policy") })
  oci_payload["hydration_policy"] = hydration_policy if hydration_policy
  averaged["oci"] = oci_payload if oci_payload.any?
  startup_prefetch_payload = average_startup_prefetch_payload(snapshots)
  averaged["startup_prefetch"] = startup_prefetch_payload if startup_prefetch_payload.any?
  storage_source = most_common(snapshots.map { |snapshot| snapshot["storage_source"] })
  averaged["storage_source"] = storage_source if storage_source

  product_refs = most_common_hash(snapshots.map { |snapshot| snapshot["product_refs"] })
  averaged["product_refs"] = product_refs if product_refs
  averaged["product_refs_consistent"] = product_refs_consistent?(snapshots) if product_refs

  launch_proof_paths = snapshots.flat_map { |snapshot| Array(snapshot["launch_proof_paths"]) }.compact
  averaged["launch_proof_paths"] = launch_proof_paths.uniq if launch_proof_paths.any?

  %w[
    workspace cache_tag run_uid mode adapter docker_cache_from_refs docker_cache_import_ready
    http_transport http2_enabled oci_stream_through_min_bytes restore_result save_result
    publish_status session_summary summary_schema reporting_url
  ].each do |key|
    value = latest[key] || most_common(snapshots.map { |snapshot| snapshot[key] })
    averaged[key] = value if value
  end

  averaged
end

def metrics_from_snapshot(snapshot)
  {
    cold_seconds: snapshot["cold_seconds"],
    cold_build_seconds: snapshot["cold_build_seconds"],
    cold_restore_or_setup_seconds: snapshot["cold_restore_or_setup_seconds"],
    warm1_seconds: snapshot["warm1_seconds"],
    warm1_build_seconds: snapshot["warm1_build_seconds"],
    warm1_restore_or_setup_seconds: snapshot["warm1_restore_or_setup_seconds"],
    warm2_seconds: snapshot["warm2_seconds"],
    warm_average_seconds: snapshot["warm_average_seconds"],
    storage_bytes: snapshot["storage_bytes"]
  }
end

def average_lane_entries(entries, benchmark:, lane:)
  return nil if entries.empty?

  cohort_entries, product_cohort = latest_boringcache_product_cohort(entries)
  classifications = cohort_entries.map { |entry| pair_classification(entry, lane: lane, category: benchmark["category"]) }
  all_classification = BenchmarkReporting.rollup_classification(
    lane: lane,
    category: benchmark["category"],
    classifications: classifications
  )

  steady_entries = comparative_entries(cohort_entries, lane: lane, category: benchmark["category"])
  measured_entries = steady_entries.empty? ? cohort_entries : steady_entries
  investigation_excluded_count = steady_entries.empty? ? 0 : cohort_entries.length - steady_entries.length
  measured_classifications = measured_entries.map { |entry| pair_classification(entry, lane: lane, category: benchmark["category"]) }
  measured_classification = BenchmarkReporting.rollup_classification(
    lane: lane,
    category: benchmark["category"],
    classifications: measured_classifications
  )

  if investigation_excluded_count.positive? && measured_classification && all_classification
    measured_classification["source_sample_count"] = cohort_entries.length
    measured_classification["excluded_sample_count"] = investigation_excluded_count
    measured_classification["excluded_investigation_only_count"] = investigation_excluded_count
    measured_classification["rolling_bootstrap_count"] = all_classification["rolling_bootstrap_count"]
    measured_classification["rolling_reseed_count"] = all_classification["rolling_reseed_count"]
    measured_classification["reporting_note"] = "#{investigation_excluded_count}/#{cohort_entries.length} cache-bootstrap samples were excluded from this comparative row."
  end

  if product_cohort && measured_classification
    measured_classification["product_cohort"] = product_cohort
  end

  actions_snapshot = average_snapshot(measured_entries.map { |entry| entry.dig("comparison", "actions_cache") })
  boringcache_snapshot = average_snapshot(measured_entries.map { |entry| entry.dig("comparison", "boringcache") })
  boringcache_snapshot["classification"] = measured_classification if measured_classification
  actions_metrics = metrics_from_snapshot(actions_snapshot)
  boringcache_metrics = metrics_from_snapshot(boringcache_snapshot)
  head_shas = measured_entries.flat_map { |entry| Array(entry.dig("comparison", "pairing_head_shas") || entry.dig("comparison", "pairing_head_sha")) }.compact.uniq
  reporting = reporting_summary(
    lane: lane,
    benchmark: benchmark,
    classification: boringcache_snapshot["classification"] || {},
    sample_count: measured_entries.length
  )
  headline = headline_for_scenario(
    scenario: reporting["headline_scenario"],
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics,
    actions_run_total: actions_snapshot["run_total_seconds"],
    boringcache_run_total: boringcache_snapshot["run_total_seconds"]
  )
  headline ||= headline_metric_for(
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics,
    actions_run_total: actions_snapshot["run_total_seconds"],
    boringcache_run_total: boringcache_snapshot["run_total_seconds"]
  )
  return nil unless headline

  headline_scenario, before_value, after_value = headline
  faster_pct = percent_delta(before_value, after_value)
  return nil if faster_pct.nil?
  faster_pct = [faster_pct, 0].max

  lane_entry = {
    "lane" => lane,
    "lane_label" => lane_label(lane),
    "first_build_label" => first_build_label(lane),
    "sample_count" => measured_entries.length,
    "benchmark" => benchmark["benchmark"],
    "name" => benchmark["name"],
    "logo" => benchmark["logo"],
    "repo" => benchmark["repo"],
    "source_repo" => benchmark["source_repo"],
    "public" => benchmark.fetch("public"),
    "category" => benchmark["category"],
    "step" => benchmark["step"],
    "headline_scenario" => reporting["headline_scenario"] || headline_scenario,
    "headline_label" => reporting["headline_label"] || BenchmarkReporting.headline_label(lane: lane, scenario: reporting["headline_scenario"] || headline_scenario),
    "before" => seconds_to_text(before_value),
    "after" => seconds_to_text(after_value),
    "before_seconds" => before_value.round(2),
    "after_seconds" => after_value.round(2),
    "faster" => reporting["comparative"] ? faster_pct.round.to_s : nil,
    "comparison" => {
      "paired_on_head_sha" => true,
      "pairing_head_sha" => head_shas.one? ? head_shas.first : nil,
      "pairing_head_shas" => head_shas,
      "sample_count" => measured_entries.length,
      "actions_cache" => actions_snapshot,
      "boringcache" => boringcache_snapshot,
      "reporting" => reporting,
      "warm_improvement_pct" => percent_delta(
        warm_steady_seconds(actions_metrics),
        warm_steady_seconds(boringcache_metrics)
      )&.round(2),
      "warm_build_improvement_pct" => percent_delta(
        actions_metrics[:warm1_build_seconds],
        boringcache_metrics[:warm1_build_seconds]
      )&.round(2),
      "cold_improvement_pct" => percent_delta(actions_metrics[:cold_seconds], boringcache_metrics[:cold_seconds])&.round(2),
      "cold_build_improvement_pct" => percent_delta(actions_metrics[:cold_build_seconds], boringcache_metrics[:cold_build_seconds])&.round(2),
      "run_total_improvement_pct" => percent_delta(actions_snapshot["run_total_seconds"], boringcache_snapshot["run_total_seconds"])&.round(2),
      "storage_improvement_pct" => percent_delta(actions_metrics[:storage_bytes], boringcache_metrics[:storage_bytes])&.round(2),
      "storage_saved_bytes" => if actions_metrics[:storage_bytes] && boringcache_metrics[:storage_bytes]
        actions_metrics[:storage_bytes] - boringcache_metrics[:storage_bytes]
      end
    }
  }
  lane_entry["comparison"]["product_cohort"] = product_cohort if product_cohort
  lane_entry
end

def comparative_entries(entries, lane:, category:)
  entries.select do |entry|
    BenchmarkReporting.reporting_mode(
      lane: lane,
      category: category,
      classification: pair_classification(entry, lane: lane, category: category)
    ) == "comparative"
  end
end

def pair_classification(entry, lane:, category:)
  classifications = [
    entry.dig("comparison", "actions_cache", "classification"),
    entry.dig("comparison", "boringcache", "classification")
  ].compact

  classifications.find do |classification|
    BenchmarkReporting.reporting_mode(lane: lane, category: category, classification: classification) != "comparative"
  end || entry.dig("comparison", "boringcache", "classification") || entry.dig("comparison", "actions_cache", "classification") || {}
end

def merge_lane_entries(entries_by_lane)
  return nil if entries_by_lane.empty?

  default_lane = entries_by_lane.key?("fresh") ? "fresh" : entries_by_lane.keys.first
  default_entry = JSON.parse(JSON.generate(entries_by_lane.fetch(default_lane)))
  default_entry["default_lane"] = default_lane
  default_entry["available_lanes"] = entries_by_lane.keys
  default_entry["lanes"] = entries_by_lane.transform_values do |entry|
    JSON.parse(JSON.generate(entry))
  end
  default_entry
end

def lane_report_row(entry, lane)
  lane_entry = entry.dig("lanes", lane) || (entry["lane"] == lane ? entry : nil)
  return nil if lane_entry.nil?

  comparison = lane_entry.fetch("comparison", {})
  actions = comparison.fetch("actions_cache", {})
  boringcache = comparison.fetch("boringcache", {})
  bc_classification = boringcache["classification"] || {}
  sample_count = comparison["sample_count"].to_i
  reporting = BenchmarkReporting.normalize_summary(
    lane: lane,
    category: entry["category"],
    reporting: comparison.fetch("reporting", {}),
    classification: bc_classification,
    sample_count: sample_count
  )
  scenarios = [
    ["cold", note_metric_label(lane, "cold"), actions["cold_seconds"], boringcache["cold_seconds"]],
    ["warm", note_metric_label(lane, "warm"), actions["warm1_seconds"], boringcache["warm1_seconds"]],
    ["run_total", note_metric_label(lane, "run_total"), actions["run_total_seconds"], boringcache["run_total_seconds"]]
  ]
  headline_scenario = lane_entry["headline_scenario"].to_s
  tiny_run = scenarios.all? { |_scenario, _label, before_value, after_value| before_value.nil? || after_value.nil? || [before_value, after_value].max <= 60 }
  faster_notes = []
  slower_notes = []

  if reporting.fetch("comparative", true)
    scenarios.each do |scenario, label, before_value, after_value|
      next if before_value.nil? || after_value.nil?
      next if scenario == headline_scenario

      case timing_result_bucket(before_value, after_value)
      when :faster
        faster_notes << label
      when :slower
        slower_notes << label
      end
    end
  end

  notes = []
  if faster_notes.any? && slower_notes.any?
    notes << "mixed: #{slower_notes.join(', ')} slower; #{faster_notes.join(', ')} faster"
  elsif slower_notes.any?
    notes << "#{slower_notes.join(', ')} slower"
  elsif faster_notes.any?
    notes << "#{faster_notes.join(', ')} faster"
  end
  notes << "tiny run; setup dominates" if tiny_run
  notes << "storage unavailable" if comparison["storage_saved_bytes"].nil?
  notes << "BC used more storage" if comparison["storage_saved_bytes"].to_f < 0
  invalid_count = bc_classification["invalid_count"].to_i
  bootstrap_count = (bc_classification["rolling_bootstrap_count"] || bc_classification["rolling_reseed_count"]).to_i
  source_sample_count = bc_classification["source_sample_count"].to_i
  excluded_sample_count = bc_classification["excluded_sample_count"].to_i
  cache_import_status = bc_classification["cache_import_status"].to_s

  if source_sample_count.positive? && excluded_sample_count.positive?
    notes << "#{sample_count} steady samples; #{excluded_sample_count}/#{source_sample_count} bootstrap samples excluded"
  else
    notes << "#{sample_count} paired samples" if sample_count > 1
    notes << "cache bootstrap #{bootstrap_count}/#{sample_count}" if sample_count > 1 && bootstrap_count.positive?
  end

  notes << "invalid #{invalid_count}/#{sample_count}" if sample_count > 1 && invalid_count.positive?
  notes << "cache import #{cache_import_status}" if !cache_import_status.empty? && cache_import_status != "ok"
  notes << reporting["note"] if reporting["note"]

  {
    benchmark: entry.fetch("name"),
    scenario: lane_entry["headline_label"] || reporting["headline_label"] || BenchmarkReporting.headline_label(lane: lane, scenario: lane_entry["headline_scenario"]),
    actions: lane_entry["before"],
    boringcache: lane_entry["after"],
    result: reporting.fetch("comparative", true) ? timing_result_text(lane_entry["before_seconds"], lane_entry["after_seconds"]) : reporting["result_text"],
    storage: storage_summary_text(comparison),
    notes: notes.empty? ? "—" : notes.join("; ")
  }
end

def note_metric_label(lane, scenario)
  return "commit build" if lane.to_s == "rolling" && scenario.to_s == "cold"
  return "workflow total" if scenario.to_s == "run_total"

  scenario.to_s.tr("_", " ")
end

def coverage_cell(entry, lane)
  return "yes" if entry.dig("lanes", lane)
  return "yes" if entry["lane"] == lane

  "—"
end

def markdown_table(headers, rows)
  lines = []
  lines << "| #{headers.map { |h| markdown_escape(h) }.join(' | ')} |"
  lines << "| #{headers.map { '---' }.join(' | ')} |"
  rows.each do |row|
    lines << "| #{row.map { |cell| markdown_escape(cell) }.join(' | ')} |"
  end
  lines.join("\n")
end

def build_report(entries, generated_at:)
  generated_label = Time.parse(generated_at).utc.strftime("%Y-%m-%d %H:%M UTC")
  coverage_rows = entries.map do |entry|
    [
      entry.fetch("name"),
      coverage_cell(entry, "fresh"),
      coverage_cell(entry, "rolling")
    ]
  end

  fresh_rows = entries.each_with_object([]) do |entry, rows|
    row = lane_report_row(entry, "fresh")
    next unless row

    rows << [row[:benchmark], row[:scenario], row[:actions], row[:boringcache], row[:result], row[:storage], row[:notes]]
  end

  rolling_rows = entries.map do |entry|
    row = lane_report_row(entry, "rolling")
    if row
      [row[:benchmark], row[:scenario], row[:actions], row[:boringcache], row[:result], row[:storage], row[:notes]]
    else
      [entry.fetch("name"), "—", "—", "—", "—", "—", "not published yet"]
    end
  end

  [
    "## Latest Benchmark Report",
    "",
    "Generated: #{generated_label}",
    "",
    "### Lane Coverage",
    "",
    markdown_table(["Benchmark", "Fresh", "Rolling"], coverage_rows),
    "",
    "### Fresh",
    "",
    markdown_table(["Benchmark", "Metric", "actions/cache", "BoringCache", "Result", "Storage Delta", "Notes"], fresh_rows),
    "",
    "### Rolling",
    "",
    markdown_table(["Benchmark", "Metric", "actions/cache", "BoringCache", "Result", "Storage Delta", "Notes"], rolling_rows),
    "",
    "Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.",
    "",
    "Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to #{PAIR_COUNT} steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.",
    ""
  ].join("\n")
end

def write_report(entries, generated_at:)
  report = build_report(entries, generated_at: generated_at)
  File.write(REPORT_PATH, report)
  puts "Wrote #{REPORT_PATH}"
  report
end

def update_readme(report)
  readme = File.read(README_PATH)
  replacement = [
    README_REPORT_START,
    "",
    report.rstrip,
    "",
    README_REPORT_END
  ].join("\n")

  updated = if readme.include?(README_REPORT_START) && readme.include?(README_REPORT_END)
    readme.sub(/#{Regexp.escape(README_REPORT_START)}.*?#{Regexp.escape(README_REPORT_END)}/m, replacement)
  else
    [
      readme.rstrip,
      "",
      replacement,
      ""
    ].join("\n")
  end

  File.write(README_PATH, updated)
  puts "Updated #{README_PATH}"
end

def latest_run_by_head(runs)
  runs.each_with_object({}) do |run, acc|
    head = run["headSha"].to_s
    next if head.empty?

    existing = acc[head]
    acc[head] = run if existing.nil? || (parse_timestamp(run["createdAt"]) || Time.at(0)) > (parse_timestamp(existing["createdAt"]) || Time.at(0))
  end
end

def paired_heads(actions_by_head, boringcache_by_head)
  (actions_by_head.keys & boringcache_by_head.keys).sort_by do |head|
    [
      parse_timestamp(actions_by_head.fetch(head)["createdAt"]) || Time.at(0),
      parse_timestamp(boringcache_by_head.fetch(head)["createdAt"]) || Time.at(0)
    ].max
  end.reverse
end

def load_lane_entry(temp_root:, benchmark:, lane:, actions_runs:, boringcache_runs:, cache:, artifacts_cache:)
  return nil if actions_runs.empty? || boringcache_runs.empty?

  ac_runs_by_head = runs_by_head_grouped(actions_runs)
  bc_runs_by_head = runs_by_head_grouped(boringcache_runs)
  paired = (ac_runs_by_head.keys & bc_runs_by_head.keys).sort_by do |head|
    [
      ac_runs_by_head[head].map { |run| parse_timestamp(run["createdAt"]) || Time.at(0) }.max,
      bc_runs_by_head[head].map { |run| parse_timestamp(run["createdAt"]) || Time.at(0) }.max
    ].max
  end.reverse
  entries = []
  artifact_ids = benchmark_artifact_ids(benchmark)

  paired.each do |head|
    ac_run = latest_run_with_artifact(
      runs_for_head: ac_runs_by_head[head],
      repo: benchmark.fetch("source_repo"),
      benchmark_id: artifact_ids,
      strategy: "actions-cache",
      lane: lane,
      artifacts_cache: artifacts_cache
    )
    bc_run = latest_run_with_artifact(
      runs_for_head: bc_runs_by_head[head],
      repo: benchmark.fetch("source_repo"),
      benchmark_id: artifact_ids,
      strategy: "boringcache",
      lane: lane,
      artifacts_cache: artifacts_cache
    )
    next if ac_run.nil? || bc_run.nil?

    boringcache_data = load_strategy_data(
      temp_root: temp_root,
      repo: benchmark.fetch("source_repo"),
      run: bc_run,
      benchmark_id: artifact_ids,
      strategy: "boringcache",
      lane: lane,
      cache: cache
    )
    next if boringcache_data[:metrics].nil?

    actions_data = load_strategy_data(
      temp_root: temp_root,
      repo: benchmark.fetch("source_repo"),
      run: ac_run,
      benchmark_id: artifact_ids,
      strategy: "actions-cache",
      lane: lane,
      cache: cache
    )
    next if actions_data[:metrics].nil?

    pair = {
      actions: ac_run,
      boringcache: bc_run,
      paired_on_head_sha: true,
      pairing_head_sha: head
    }

    entry = build_entry(
      benchmark: benchmark,
      pair: pair,
      actions_data: actions_data,
      boringcache_data: boringcache_data,
      lane: lane
    )
    entries << entry if entry
    break if entries.length >= PAIR_COUNT
  end

  average_lane_entries(entries, benchmark: benchmark, lane: lane)
end

def write_index(entries, generated_at:)
  FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
  payload = {
    "generated_at" => generated_at,
    "entries" => entries
  }
  File.write(OUTPUT_PATH, JSON.pretty_generate(payload) + "\n")
  puts "Wrote #{OUTPUT_PATH} with #{entries.length} entries"
end

def write_detail_files(entries, generated_at:)
  FileUtils.mkdir_p(DETAIL_OUTPUT_DIR)
  Dir.glob(File.join(DETAIL_OUTPUT_DIR, "*.json")).each do |path|
    FileUtils.rm_f(path)
  end

  entries.each do |entry|
    benchmark_id = entry.fetch("benchmark")
    detail_path = File.join(DETAIL_OUTPUT_DIR, "#{benchmark_id}.json")
    payload = {
      "generated_at" => generated_at,
      "entry" => entry
    }
    File.write(detail_path, JSON.pretty_generate(payload) + "\n")
    puts "Wrote #{detail_path}"
  end
end

def normalize_lane_reporting!(lane_entry, category:)
  comparison = lane_entry["comparison"]
  return unless comparison.is_a?(Hash)

  boringcache = comparison["boringcache"].is_a?(Hash) ? comparison["boringcache"] : {}
  classification = boringcache["classification"].is_a?(Hash) ? boringcache["classification"] : {}
  sample_count = comparison["sample_count"].to_i
  reporting = BenchmarkReporting.normalize_summary(
    lane: lane_entry["lane"],
    category: category,
    reporting: comparison["reporting"].is_a?(Hash) ? comparison["reporting"] : {},
    classification: classification,
    sample_count: sample_count
  )

  comparison["reporting"] = reporting
  lane_entry["headline_scenario"] = reporting["headline_scenario"] || lane_entry["headline_scenario"]
  lane_entry["headline_label"] = reporting["headline_label"] ||
    BenchmarkReporting.headline_label(lane: lane_entry["lane"], scenario: lane_entry["headline_scenario"])
end

def normalize_entry_reporting(entry)
  normalized = JSON.parse(JSON.generate(entry))
  category = normalized["category"]
  normalize_lane_reporting!(normalized, category: category)
  normalized.fetch("lanes", {}).each_value do |lane_entry|
    normalize_lane_reporting!(lane_entry, category: category)
  end
  normalized
end

def main
  require_gh!

  existing_entries = load_existing_entries
  entries = []
  strategy_data_cache = {}
  raise "BENCHMARKS_PAIR_COUNT must be >= 1" if PAIR_COUNT < 1

  Dir.mktmpdir("benchmark-index-") do |tmp|
    BENCHMARKS.each do |benchmark|
      benchmark_id = benchmark.fetch("benchmark")
      preserved_entry = existing_entries[benchmark_id]
      preserved_entry = preserved_entry.merge("public" => benchmark.fetch("public")) if preserved_entry

      begin
        repo = benchmark.fetch("source_repo")
        actions_runs = latest_successful_runs(repo: repo, workflow_name: benchmark.fetch("actions_workflow"))
        boringcache_runs = latest_successful_runs(repo: repo, workflow_name: benchmark.fetch("boringcache_workflow"))
        artifacts_cache = {}
        lane_entries = LANE_IDS.each_with_object({}) do |lane, acc|
          lane_entry = load_lane_entry(
            temp_root: tmp,
            benchmark: benchmark,
            lane: lane,
            actions_runs: actions_runs,
            boringcache_runs: boringcache_runs,
            cache: strategy_data_cache,
            artifacts_cache: artifacts_cache
          )
          acc[lane] = lane_entry if lane_entry
        end

        entry = merge_lane_entries(lane_entries)
        if entry.nil?
          if PRESERVE_STALE_ENTRIES && preserved_entry
            warn "Preserving #{benchmark['name']} from existing index: no successful run pair found"
            entries << preserved_entry
          else
            warn "Skipping #{benchmark['name']}: no successful run pair found"
          end
          next
        end

        entries << entry
      rescue StandardError => e
        if PRESERVE_STALE_ENTRIES && preserved_entry
          warn "Preserving #{benchmark['name']} from existing index: #{e.message}"
          entries << preserved_entry
        else
          raise "Failed to refresh #{benchmark['name']}: #{e.message}"
        end
      end
    end
  end

  generated_at = Time.now.utc.iso8601
  entries = entries.map { |entry| normalize_entry_reporting(entry) }
  write_index(entries, generated_at: generated_at)
  write_detail_files(entries, generated_at: generated_at)
  report = write_report(entries, generated_at: generated_at)
  update_readme(report)
end

main if __FILE__ == $PROGRAM_NAME
