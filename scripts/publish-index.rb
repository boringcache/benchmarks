#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "time"
require "timeout"
require "tmpdir"
require_relative "benchmark-reporting"

OUTPUT_DIR = File.join("data", "latest")
OUTPUT_PATH = File.join(OUTPUT_DIR, "index.json")
PAIR_POINTS_PATH = File.join(OUTPUT_DIR, "pairs.json")
WINDOWS_PATH = File.join(OUTPUT_DIR, "windows.json")
HEALTH_PATH = File.join(OUTPUT_DIR, "health.json")
PROVIDERS_PATH = File.join(OUTPUT_DIR, "providers.json")
DETAIL_OUTPUT_DIR = File.join(OUTPUT_DIR, "benchmarks")
REPORT_PATH = File.join(OUTPUT_DIR, "report.md")
MAX_CMD_RETRIES = ENV.fetch("BENCHMARKS_GH_RETRIES", "3").to_i
RUN_HISTORY_LIMIT = ENV.fetch("BENCHMARKS_GH_RUN_LIMIT", "100").to_i
PAIR_COUNT = ENV.fetch("BENCHMARKS_PAIR_COUNT", "3").to_i
CMD_TIMEOUT_SECONDS = ENV.fetch("BENCHMARKS_CMD_TIMEOUT", "120").to_i
CMD_OUTPUT_DRAIN_TIMEOUT_SECONDS = ENV.fetch("BENCHMARKS_OUTPUT_DRAIN_TIMEOUT", "5").to_f
BENCHMARK_REFRESH_TIMEOUT_SECONDS = ENV.fetch("BENCHMARKS_BENCHMARK_TIMEOUT", "600").to_f
PRESERVE_STALE_ENTRIES = ENV.fetch("BENCHMARKS_PRESERVE_STALE", "false") == "true"
LANE_IDS = %w[fresh rolling].freeze
PRODUCT_REF_KEYS = %w[cli_version action_ref action_sha web_revision api_url].freeze
PROVIDER_LABELS = {
  "actions-cache" => "GitHub Actions Cache",
  "boringcache" => "BoringCache",
  "boringcache-native" => "BoringCache Native BuildKit",
  "depot-cache" => "Depot Cache",
  "buildbuddy-cache" => "BuildBuddy Cache"
}.freeze
PROVIDER_STORAGE_STRATEGIES = %w[actions-cache boringcache].freeze
SLOW_REASON_NUMERIC_KEYS = %w[
  build_seconds setup_seconds post_cleanup_seconds cache_restore_seconds cache_save_export_seconds
  hit_count miss_count hit_rate new_blob_bytes
].freeze
RUNNER_VARIANCE_MIN_PROVIDER_SAMPLES = 3
RUNNER_VARIANCE_MAX_CACHE_COUNT_DELTA = 2
RUNNER_VARIANCE_MAX_HIT_RATE_DELTA = 0.2
RUNNER_VARIANCE_MAX_CACHE_TIMEOUT_DELTA = 1
RUNNER_VARIANCE_MAX_CACHE_TIMEOUTS = 1
RUNNER_VARIANCE_MAX_PEER_SPREAD_RATIO = 0.10
RUNNER_VARIANCE_MIN_TOOL_ELAPSED_DEVIATION_RATIO = 0.05
RUNNER_VARIANCE_MIN_TOOL_ELAPSED_DEVIATION_SECONDS = 60.0
RUNNER_VARIANCE_MIN_COMPILER_DEVIATION_RATIO = 0.20
RUNNER_VARIANCE_MIN_COMPILER_DEVIATION_SECONDS = 5.0
RUNNER_VARIANCE_CACHE_ERROR_KEYS = %w[cache_errors cache_read_errors cache_write_errors].freeze

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
    "actions_workflow" => "hugo-actions-cache.yml",
    "boringcache_workflow" => "hugo-boringcache.yml"
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
    "actions_workflow" => "hugo-go-actions-cache.yml",
    "boringcache_workflow" => "hugo-go-boringcache.yml",
    "provider_workflows" => {
      "depot-cache" => "hugo-go-depot-cache.yml"
    }
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
    "actions_workflow" => "immich-actions-cache.yml",
    "boringcache_workflow" => "immich-boringcache.yml"
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
    "actions_workflow" => "mastodon-docker-actions-cache.yml",
    "boringcache_workflow" => "mastodon-docker-boringcache.yml",
    "workflow_benchmark_ids" => ["mastodon-deps"]
  },
  {
    "benchmark" => "mastodon-streaming",
    "name" => "Mastodon Streaming",
    "logo" => "mastodon",
    "repo" => "mastodon/mastodon",
    "source_repo" => "boringcache/benchmark-mastodon",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (streaming service)",
    "actions_workflow" => "mastodon-streaming-docker-actions-cache.yml",
    "boringcache_workflow" => "mastodon-streaming-docker-boringcache.yml"
  },
  {
    "benchmark" => "discourse-docker",
    "aliases" => ["discourse"],
    "name" => "Discourse",
    "logo" => "docker",
    "repo" => "discourse/discourse",
    "source_repo" => "boringcache/benchmark-discourse",
    "public" => true,
    "category" => "docker",
    "step" => "Docker build (Ruby+Node dev image)",
    "actions_workflow" => "discourse-docker-actions-cache.yml",
    "boringcache_workflow" => "discourse-docker-boringcache.yml",
    "workflow_benchmark_ids" => ["discourse-deps"]
  },
  {
    "benchmark" => "discourse-base-deps",
    "name" => "Discourse Base Deps",
    "logo" => "docker",
    "repo" => "discourse/discourse_docker",
    "source_repo" => "boringcache/benchmark-discourse",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (base dependencies image)",
    "actions_workflow" => "discourse-image-factory-actions-cache.yml",
    "boringcache_workflow" => "discourse-image-factory-boringcache.yml"
  },
  {
    "benchmark" => "discourse-base-web-only",
    "name" => "Discourse Web-Only Image",
    "logo" => "docker",
    "repo" => "discourse/discourse_docker",
    "source_repo" => "boringcache/benchmark-discourse",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (web-only base image)",
    "actions_workflow" => "discourse-image-factory-actions-cache.yml",
    "boringcache_workflow" => "discourse-image-factory-boringcache.yml"
  },
  {
    "benchmark" => "discourse-base-release",
    "name" => "Discourse Release Image",
    "logo" => "docker",
    "repo" => "discourse/discourse_docker",
    "source_repo" => "boringcache/benchmark-discourse",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (release base image)",
    "actions_workflow" => "discourse-image-factory-actions-cache.yml",
    "boringcache_workflow" => "discourse-image-factory-boringcache.yml"
  },
  {
    "benchmark" => "discourse-test-release",
    "name" => "Discourse Test Image",
    "logo" => "docker",
    "repo" => "discourse/discourse_docker",
    "source_repo" => "boringcache/benchmark-discourse",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (discourse_test release image)",
    "actions_workflow" => "discourse-image-factory-actions-cache.yml",
    "boringcache_workflow" => "discourse-image-factory-boringcache.yml"
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
    "actions_workflow" => "posthog-actions-cache.yml",
    "boringcache_workflow" => "posthog-boringcache.yml"
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
    "actions_workflow" => "storybook-actions-cache.yml",
    "boringcache_workflow" => "storybook-boringcache.yml"
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
    "actions_workflow" => "opentelemetry-java-gradle-actions-cache.yml",
    "boringcache_workflow" => "opentelemetry-java-gradle-boringcache.yml"
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
    "actions_workflow" => "spring-ai-maven-actions-cache.yml",
    "boringcache_workflow" => "spring-ai-maven-boringcache.yml"
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
    "actions_workflow" => "grpc-bazel-actions-cache.yml",
    "boringcache_workflow" => "grpc-bazel-boringcache.yml",
    "provider_workflows" => {
      "depot-cache" => "grpc-bazel-depot-cache.yml",
      "buildbuddy-cache" => "grpc-bazel-buildbuddy-cache.yml"
    }
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
    "actions_workflow" => "zed-sccache-actions-cache.yml",
    "boringcache_workflow" => "zed-sccache-boringcache.yml",
    "provider_workflows" => {
      "depot-cache" => "zed-sccache-depot-cache.yml"
    }
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
    "actions_workflow" => "n8n-actions-cache.yml",
    "boringcache_workflow" => "n8n-boringcache.yml"
  },
  {
    "benchmark" => "n8n-docker",
    "name" => "n8n Docker",
    "logo" => "n8n",
    "repo" => "n8n-io/n8n",
    "source_repo" => "boringcache/benchmark-n8n",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (n8n image)",
    "actions_workflow" => "n8n-docker-actions-cache.yml",
    "boringcache_workflow" => "n8n-docker-boringcache.yml"
  },
  {
    "benchmark" => "n8n-runners",
    "name" => "n8n Runners",
    "logo" => "n8n",
    "repo" => "n8n-io/n8n",
    "source_repo" => "boringcache/benchmark-n8n",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (task runners)",
    "actions_workflow" => "n8n-docker-actions-cache.yml",
    "boringcache_workflow" => "n8n-docker-boringcache.yml"
  },
  {
    "benchmark" => "n8n-runners-distroless",
    "name" => "n8n Runners Distroless",
    "logo" => "n8n",
    "repo" => "n8n-io/n8n",
    "source_repo" => "boringcache/benchmark-n8n",
    "public" => false,
    "category" => "docker",
    "step" => "Docker build (distroless task runners)",
    "actions_workflow" => "n8n-docker-actions-cache.yml",
    "boringcache_workflow" => "n8n-docker-boringcache.yml"
  }
].freeze

EXCLUDED_PROVIDER_RUNS = {
  "boringcache/benchmark-posthog" => {
    26_157_635_153 => "PostHog rolling cache tag was manually evicted during storage-pressure cleanup; sample repopulated the rolling cache."
  }
}.freeze

PROVIDER_LANE_OUTLIERS = {
  "zed-sccache" => {
    "depot-cache" => {
      "fresh" => "Depot Cache's sccache store cannot be reset for this benchmark, so fresh samples retain remote compiler-cache hits and are not cold-provider evidence."
    }
  }
}.freeze

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
  Open3.popen3(*args, pgroup: true) do |stdin, stdout, stderr, wait_thread|
    stdin.close
    stdout_reader = Thread.new { stdout.read rescue "" }
    stderr_reader = Thread.new { stderr.read rescue "" }
    unless wait_thread.join(CMD_TIMEOUT_SECONDS)
      terminate_command_group(wait_thread.pid)
      close_command_streams(stdout, stderr)
      wait_thread.join(1)
      raise "Command timed out after #{CMD_TIMEOUT_SECONDS}s: #{args.join(' ')}"
    end

    unless drain_command_output(stdout_reader, stderr_reader)
      terminate_command_group(wait_thread.pid)
      close_command_streams(stdout, stderr)
      raise "Command output pipes did not close after #{CMD_OUTPUT_DRAIN_TIMEOUT_SECONDS}s: #{args.join(' ')}"
    end

    [stdout_reader.value, stderr_reader.value, wait_thread.value]
  end
end

def terminate_command_group(pid)
  kill_command_group(pid, "TERM")
  sleep(1)
  kill_command_group(pid, "KILL") if command_group_alive?(pid)
end

def kill_command_group(pid, signal)
  Process.kill(signal, -pid)
rescue Errno::ESRCH
  begin
    Process.kill(signal, pid)
  rescue Errno::ESRCH
  end
end

def command_group_alive?(pid)
  Process.kill(0, -pid)
  true
rescue Errno::ESRCH
  false
end

def close_command_streams(*streams)
  streams.each do |stream|
    stream.close unless stream.closed?
  rescue IOError
  end
end

def drain_command_output(*readers)
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + CMD_OUTPUT_DRAIN_TIMEOUT_SECONDS
  readers.all? do |reader|
    remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
    reader.join([remaining, 0].max)
  end
end

def log_progress(message)
  warn "[publish-index] #{message}"
end

def with_benchmark_timeout(benchmark)
  Timeout.timeout(BENCHMARK_REFRESH_TIMEOUT_SECONDS) { yield }
rescue Timeout::Error
  raise "Timed out refreshing #{benchmark.fetch('benchmark')} after #{BENCHMARK_REFRESH_TIMEOUT_SECONDS}s"
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
  return "n/a" if value.nil?

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
  return "n/a" if saved_bytes.nil?

  if saved_bytes.to_f >= 0
    "#{bytes_to_text(saved_bytes)} less (#{improvement_pct.to_f.abs}%)"
  else
    "#{bytes_to_text(saved_bytes.to_f.abs)} more (#{improvement_pct.to_f.abs}%)"
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

def deep_copy(value)
  JSON.parse(JSON.generate(value))
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

def cache_review_from(payload)
  review = payload["cache_review"] || payload.dig("diagnostics", "cache_review")
  review.is_a?(Hash) ? review : nil
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

def storage_breakdown_from(payload)
  breakdown = payload.dig("cache", "storage_breakdown") || payload["storage_breakdown"]
  breakdown.is_a?(Hash) ? breakdown : nil
end

def tool_outcomes_from(payload)
  outcomes = payload["tool_outcomes"]
  outcomes.is_a?(Hash) ? outcomes : nil
end

def native_tool_from(payload)
  native_tool = payload["native_tool"] || payload.dig("diagnostics", "native_tool")
  native_tool.is_a?(Hash) ? native_tool : nil
end

def slow_reason_from(payload)
  slow_reason = payload["slow_reason"]
  slow_reason.is_a?(Hash) ? slow_reason : nil
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

def median(values)
  values = values.compact.sort
  return nil if values.empty?

  midpoint = values.length / 2
  return values[midpoint] if values.length.odd?

  (values[midpoint - 1] + values[midpoint]) / 2.0
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
  return "n/a" if delta_pct.nil?

  case timing_result_bucket(before_value, after_value)
  when :faster
    "#{delta_pct.round}% faster"
  when :slower
    "#{delta_pct.abs.round}% slower"
  else
    "near tie"
  end
end

def provider_label(strategy)
  PROVIDER_LABELS.fetch(strategy, strategy)
end

def provider_workflows_for(benchmark)
  workflows = {
    "actions-cache" => benchmark.fetch("actions_workflow"),
    "boringcache" => benchmark.fetch("boringcache_workflow")
  }
  if benchmark["category"] == "docker"
    workflows["boringcache-native"] = benchmark.fetch("boringcache_workflow")
  end
  workflows.merge(benchmark.fetch("provider_workflows", {}))
end

def provider_storage_available?(strategy)
  PROVIDER_STORAGE_STRATEGIES.include?(strategy)
end

def excluded_provider_run?(repo:, run_id:)
  EXCLUDED_PROVIDER_RUNS.fetch(repo, {}).key?(run_id.to_i)
end

def filter_excluded_provider_runs(repo:, runs:)
  runs.reject { |run| excluded_provider_run?(repo: repo, run_id: run["databaseId"]) }
end

def provider_lane_outlier_reason(benchmark:, strategy:, lane:)
  PROVIDER_LANE_OUTLIERS.dig(benchmark.fetch("benchmark"), strategy, lane)
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

  runs = JSON.parse(output)
    .select { |item| item["conclusion"] == "success" }

  filter_excluded_provider_runs(repo: repo, runs: runs)
    .sort_by { |item| parse_timestamp(item["createdAt"]) || Time.at(0) }
    .reverse
end

def benchmark_artifact_name(repo:, run_id:, benchmark_id:, strategy:)
  output = run_cmd("gh", "api", "repos/#{repo}/actions/runs/#{run_id}/artifacts")
  artifacts = JSON.parse(output).fetch("artifacts", [])
  benchmark_ids = Array(benchmark_id)

  artifact = artifacts.find do |item|
    name = item["name"].to_s
    !item["expired"] && benchmark_ids.any? do |id|
      if strategy == "boringcache-native"
        name.start_with?("benchmark-#{id}-native-boringcache")
      else
        name.start_with?("benchmark-#{id}-#{strategy}")
      end
    end
  end

  artifact && artifact["name"]
end

def lane_artifact_names(benchmark_id:, strategy:, lane:)
  Array(benchmark_id).flat_map do |id|
    artifact_strategy = strategy == "boringcache-native" ? "native-boringcache" : strategy
    names = ["benchmark-#{id}-#{artifact_strategy}-#{lane}"]
    names << "benchmark-#{id}-#{artifact_strategy}" if lane == "fresh"
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
    storage_breakdown: storage_breakdown_from(payload),
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
    cache_review: cache_review_from(payload),
    summary_schema: payload["summary_schema"] || payload["summary_schema_label"],
    reporting_url: payload["reporting_url"] || payload.dig("diagnostics", "reporting_url"),
    tool_outcomes: tool_outcomes_from(payload),
    native_tool: native_tool_from(payload),
    slow_reason: slow_reason_from(payload)
  }
end

def inferred_mode(payload)
  return payload["strategy"] unless payload["strategy"] == "boringcache"

  benchmark = payload["benchmark"].to_s
  case benchmark
  when /hugo|immich|discourse|mastodon|posthog/
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
  benchmark = payload["benchmark"].to_s
  return "buildkit-native" if mode == "docker" && benchmark.end_with?("-native")

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

def warm_build_steady_seconds(metrics)
  warm_steady_seconds(metrics)
end

def first_build_seconds(metrics)
  metrics[:cold_seconds]
end

def headline_candidates(actions_metrics:, boringcache_metrics:)
  [
    ["warm", warm_build_steady_seconds(actions_metrics), warm_build_steady_seconds(boringcache_metrics)],
    ["cold", first_build_seconds(actions_metrics), first_build_seconds(boringcache_metrics)]
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

  metrics = extract_strategy_metrics(payload)
  metrics[:adapter] = "buildkit-native" if strategy == "boringcache-native"

  cache[cache_key] = {
    run: run,
    run_total_seconds: run_total,
    metrics: metrics
  }
end

def strategy_snapshot(data, paired_run_id = nil)
  metrics = data.fetch(:metrics)
  run = data.fetch(:run)
  slow_reason = if metrics[:slow_reason].is_a?(Hash)
    JSON.parse(JSON.generate(metrics[:slow_reason]))
  end
  slow_reason["paired_run_id"] = paired_run_id if slow_reason && paired_run_id

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
    "storage_breakdown" => metrics[:storage_breakdown],
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
    "cache_review" => metrics[:cache_review],
    "summary_schema" => metrics[:summary_schema],
    "reporting_url" => metrics[:reporting_url],
    "tool_outcomes" => metrics[:tool_outcomes],
    "native_tool" => metrics[:native_tool],
    "slow_reason" => slow_reason
  }
end

def headline_metric_for(actions_metrics:, boringcache_metrics:)
  candidates = headline_candidates(
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics
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

def headline_for_scenario(scenario:, actions_metrics:, boringcache_metrics:)
  before_value, after_value = BenchmarkReporting.scenario_pair(
    scenario: scenario,
    actions_cold: first_build_seconds(actions_metrics),
    boringcache_cold: first_build_seconds(boringcache_metrics),
    actions_warm: warm_build_steady_seconds(actions_metrics),
    boringcache_warm: warm_build_steady_seconds(boringcache_metrics)
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
    boringcache_metrics: boringcache_metrics
  )
  headline ||= headline_metric_for(
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics
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
    "sample_count" => 1,
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
      "sample_count" => 1,
      "actions_cache" => strategy_snapshot(actions_data, boringcache_data.fetch(:run)["databaseId"]),
      "boringcache" => strategy_snapshot(boringcache_data, actions_data.fetch(:run)["databaseId"]),
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

def average_storage_breakdown_payload(snapshots)
  payloads = snapshots.map { |snapshot| snapshot["storage_breakdown"] }.select { |payload| payload.is_a?(Hash) }
  return nil if payloads.empty?

  summary_keys = payloads.flat_map { |payload| (payload["summary"] || {}).keys }.uniq
  summary = summary_keys.each_with_object({}) do |key, acc|
    values = payloads.map { |payload| parse_number(payload.dig("summary", key)) }.compact
    next if values.empty?

    acc[key] = average(values).round
  end

  component_groups = Hash.new { |hash, key| hash[key] = [] }
  payloads.each do |payload|
    Array(payload["components"]).each do |component|
      next unless component.is_a?(Hash)

      key = [
        component["component_type"].to_s,
        component["component_label"].to_s,
        component["storage_mode"].to_s
      ]
      component_groups[key] << component
    end
  end

  components = component_groups.map do |(component_type, component_label, storage_mode), grouped|
    {
      "component_type" => component_type,
      "component_label" => component_label,
      "storage_mode" => storage_mode,
      "bytes" => average(grouped.map { |component| parse_number(component["bytes"]) }).round,
      "sample_count" => grouped.length,
      "tags" => grouped.map { |component| component["tag"] }.compact.uniq
    }.reject { |_, value| value.respond_to?(:empty?) ? value.empty? : value.nil? }
  end

  total_bytes = average(payloads.map { |payload| parse_number(payload["total_bytes"]) })
  {
    "total_bytes" => (total_bytes.round if total_bytes),
    "summary" => summary,
    "components" => components
  }.reject { |_, value| value.respond_to?(:empty?) ? value.empty? : value.nil? }
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

def average_slow_reason_payload(snapshots)
  rows = snapshots.map { |snapshot| snapshot["slow_reason"] }.select { |row| row.is_a?(Hash) }
  return nil if rows.empty?

  latest_snapshot = snapshots
    .select { |snapshot| snapshot["slow_reason"].is_a?(Hash) }
    .max_by { |snapshot| parse_timestamp(snapshot["created_at"]) || Time.at(0) }
  averaged = JSON.parse(JSON.generate(latest_snapshot["slow_reason"]))

  SLOW_REASON_NUMERIC_KEYS.each do |key|
    value = average(rows.map { |row| parse_number(row[key]) })
    next if value.nil?

    value = value.round if key.end_with?("_bytes") || key.end_with?("_count")
    averaged[key] = value
  end

  averaged["sample_count"] = rows.length
  averaged["sample_run_ids"] = snapshots.map { |snapshot| snapshot["run_id"] if snapshot["slow_reason"].is_a?(Hash) }.compact
  averaged["hypothesis_ids"] = rows.flat_map do |row|
    Array(row["hypotheses"]).map { |hypothesis| hypothesis["id"] if hypothesis.is_a?(Hash) }.compact
  end.uniq
  averaged["samples"] = rows if rows.length > 1
  averaged
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

  slow_reason = average_slow_reason_payload(snapshots)
  averaged["slow_reason"] = slow_reason if slow_reason

  oci_payload = average_oci_payload(snapshots)
  hydration_policy = most_common(snapshots.map { |snapshot| snapshot.dig("oci", "hydration_policy") })
  oci_payload["hydration_policy"] = hydration_policy if hydration_policy
  averaged["oci"] = oci_payload if oci_payload.any?
  startup_prefetch_payload = average_startup_prefetch_payload(snapshots)
  averaged["startup_prefetch"] = startup_prefetch_payload if startup_prefetch_payload.any?
  storage_breakdown_payload = average_storage_breakdown_payload(snapshots)
  averaged["storage_breakdown"] = storage_breakdown_payload if storage_breakdown_payload
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
    publish_status session_summary cache_review summary_schema reporting_url tool_outcomes native_tool
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
    boringcache_metrics: boringcache_metrics
  )
  headline ||= headline_metric_for(
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics
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
      "storage_improvement_pct" => percent_delta(actions_metrics[:storage_bytes], boringcache_metrics[:storage_bytes])&.round(2),
      "storage_saved_bytes" => if actions_metrics[:storage_bytes] && boringcache_metrics[:storage_bytes]
        actions_metrics[:storage_bytes] - boringcache_metrics[:storage_bytes]
      end
    }
  }
  lane_entry["comparison"]["product_cohort"] = product_cohort if product_cohort
  lane_entry
end

def latest_lane_entry(entries)
  return nil if entries.empty?

  deep_copy(entries.first)
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
  default_entry = deep_copy(entries_by_lane.fetch(default_lane))
  default_entry["default_lane"] = default_lane
  default_entry["available_lanes"] = entries_by_lane.keys
  default_entry["lanes"] = entries_by_lane.transform_values do |entry|
    deep_copy(entry)
  end
  default_entry
end

def lane_report_row(entry, lane)
  lane_entry = entry.dig("lanes", lane) || (entry["lane"] == lane ? entry : nil)
  return nil if lane_entry.nil?

  comparison = lane_entry.fetch("comparison", {})
  boringcache = comparison.fetch("boringcache", {})
  bc_classification = boringcache["classification"] || {}
  reporting = BenchmarkReporting.normalize_summary(
    lane: lane,
    category: entry["category"],
    reporting: comparison.fetch("reporting", {}),
    classification: bc_classification,
    sample_count: comparison["sample_count"].to_i
  )

  [
    entry.fetch("name"),
    lane_entry["headline_label"] || reporting["headline_label"] || BenchmarkReporting.headline_label(lane: lane, scenario: lane_entry["headline_scenario"]),
    lane_entry["before"],
    lane_entry["after"],
    reporting.fetch("comparative", true) ? timing_result_text(lane_entry["before_seconds"], lane_entry["after_seconds"]) : reporting["result_text"],
    storage_summary_text(comparison)
  ]
end

def lane_available?(entry, lane)
  entry.dig("lanes", lane) || entry["lane"] == lane
end

def coverage_summary(entries)
  total = entries.length
  fresh = entries.count { |entry| lane_available?(entry, "fresh") }
  rolling = entries.count { |entry| lane_available?(entry, "rolling") }
  "Coverage: #{total} benchmarks; fresh #{fresh}/#{total}, rolling #{rolling}/#{total}."
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
  headers = ["Benchmark", "Metric", "GitHub Actions Cache", "BoringCache", "Result", "Storage"]
  fresh_rows = entries.map { |entry| lane_report_row(entry, "fresh") }.compact
  rolling_rows = entries.map { |entry| lane_report_row(entry, "rolling") }.compact

  [
    "# Latest Benchmark Report",
    "",
    "Generated: #{generated_label}",
    "",
    coverage_summary(entries),
    "",
    "Rows are latest complete same-commit pairs.",
    "",
    "## Fresh",
    "",
    markdown_table(headers, fresh_rows),
    "",
    "## Rolling",
    "",
    markdown_table(headers, rolling_rows),
    ""
  ].join("\n")
end

def write_report(entries, generated_at:)
  report = build_report(entries, generated_at: generated_at)
  File.write(REPORT_PATH, report)
  puts "Wrote #{REPORT_PATH}"
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

def pair_point_from_entry(entry)
  point = deep_copy(entry)
  comparison = point.fetch("comparison", {})
  actions_cache = comparison.fetch("actions_cache", {})
  boringcache = comparison.fetch("boringcache", {})
  created_times = [
    parse_timestamp(actions_cache["created_at"]),
    parse_timestamp(boringcache["created_at"])
  ].compact

  point["point_type"] = "benchmark_commit_pair"
  point["head_sha"] = comparison["pairing_head_sha"] || Array(comparison["pairing_head_shas"]).first
  point["actions_run_id"] = actions_cache["run_id"]
  point["boringcache_run_id"] = boringcache["run_id"]
  point["created_at"] = created_times.max&.utc&.iso8601
  point
end

def lane_health(benchmark:, lane:, actions_runs:, boringcache_runs:, paired_head_count:, entries:)
  latest = entries.first
  classification = latest ? pair_classification(latest, lane: lane, category: benchmark["category"]) : {}
  reporting_mode = latest ? BenchmarkReporting.reporting_mode(lane: lane, category: benchmark["category"], classification: classification) : nil
  latest_comparison = latest&.fetch("comparison", {}) || {}
  latest_actions = latest_comparison.fetch("actions_cache", {})
  latest_boringcache = latest_comparison.fetch("boringcache", {})
  latest_created_at = [
    parse_timestamp(latest_actions["created_at"]),
    parse_timestamp(latest_boringcache["created_at"])
  ].compact.max

  state = if latest.nil?
    "missing_pair"
  elsif reporting_mode == "invalid"
    "invalid"
  elsif reporting_mode == "investigation_only"
    "investigation"
  else
    "healthy"
  end

  {
    "lane" => lane,
    "state" => state,
    "actions_successful_run_count" => actions_runs.length,
    "boringcache_successful_run_count" => boringcache_runs.length,
    "paired_head_count" => paired_head_count,
    "selected_pair_count" => entries.length,
    "window_pair_target" => PAIR_COUNT,
    "latest_head_sha" => latest_comparison["pairing_head_sha"] || Array(latest_comparison["pairing_head_shas"]).first,
    "latest_created_at" => latest_created_at&.utc&.iso8601,
    "latest_actions_run_id" => latest_actions["run_id"],
    "latest_boringcache_run_id" => latest_boringcache["run_id"],
    "latest_reporting_mode" => reporting_mode,
    "latest_reporting_reason" => classification["reporting_reason"] || classification["validity_reason"],
    "latest_cache_import_status" => classification["cache_import_status"],
    "latest_sample_valid" => classification.key?("sample_valid") ? classification["sample_valid"] : nil
  }.reject { |_, value| value.nil? }
end

def provider_scenario_seconds(snapshot)
  snapshot["cold_seconds"] || snapshot["warm_steady_seconds"]
end

def provider_scenario_metric_source(snapshot)
  return "cold_seconds" if snapshot["cold_seconds"]
  return "warm_steady_seconds" if snapshot["warm_steady_seconds"]

  nil
end

def provider_post_build_tool_seconds(snapshot)
  slow_reason = snapshot["slow_reason"].is_a?(Hash) ? snapshot["slow_reason"] : {}
  cache_save_export_seconds = slow_reason["cache_save_export_seconds"] || snapshot["docker_cache_export_seconds"]
  [
    cache_save_export_seconds,
    slow_reason["post_cleanup_seconds"]
  ].map { |value| parse_number(value) }.compact.sum
end

def provider_tool_elapsed_seconds(snapshot)
  scenario_seconds = provider_scenario_seconds(snapshot)
  return nil unless scenario_seconds

  scenario_seconds + provider_post_build_tool_seconds(snapshot)
end

def provider_tool_elapsed_components(snapshot)
  scenario_seconds = provider_scenario_seconds(snapshot)
  return nil unless scenario_seconds

  slow_reason = snapshot["slow_reason"].is_a?(Hash) ? snapshot["slow_reason"] : {}
  cache_save_export_seconds = parse_number(slow_reason["cache_save_export_seconds"] || snapshot["docker_cache_export_seconds"])
  post_cleanup_seconds = parse_number(slow_reason["post_cleanup_seconds"])
  {
    "scenario_seconds" => scenario_seconds,
    "cache_save_export_seconds" => cache_save_export_seconds,
    "post_cleanup_seconds" => post_cleanup_seconds
  }.reject { |_, value| value.nil? }
end

def native_tool_snapshot(snapshot)
  native_tool = snapshot["native_tool"]
  native_tool.is_a?(Hash) ? native_tool : {}
end

def native_tool_number(snapshot, key)
  parse_number(native_tool_snapshot(snapshot)[key])
end

def native_tool_hash(snapshot, key)
  value = native_tool_snapshot(snapshot)[key]
  value.is_a?(Hash) ? value : {}
end

def similar_native_tool_count?(left, right, key)
  left_value = native_tool_number(left, key)
  right_value = native_tool_number(right, key)
  return false if left_value.nil? || right_value.nil?

  (left_value - right_value).abs <= RUNNER_VARIANCE_MAX_CACHE_COUNT_DELTA
end

def similar_native_tool_hash_counts?(left, right, key)
  left_counts = native_tool_hash(left, key)
  right_counts = native_tool_hash(right, key)
  return false if left_counts.empty? || right_counts.empty?
  return false unless left_counts.keys.sort == right_counts.keys.sort

  left_counts.keys.all? do |count_key|
    left_value = parse_number(left_counts[count_key])
    right_value = parse_number(right_counts[count_key])
    left_value && right_value && (left_value - right_value).abs <= RUNNER_VARIANCE_MAX_CACHE_COUNT_DELTA
  end
end

def cache_error_free_for_runner_variance?(snapshot)
  RUNNER_VARIANCE_CACHE_ERROR_KEYS.all? do |key|
    value = native_tool_number(snapshot, key)
    !value.nil? && value.zero?
  end
end

def cache_timeouts_similar_for_runner_variance?(left, right)
  left_timeouts = native_tool_number(left, "cache_timeouts")
  right_timeouts = native_tool_number(right, "cache_timeouts")
  return false if left_timeouts.nil? || right_timeouts.nil?
  return false if [left_timeouts, right_timeouts].max > RUNNER_VARIANCE_MAX_CACHE_TIMEOUTS

  (left_timeouts - right_timeouts).abs <= RUNNER_VARIANCE_MAX_CACHE_TIMEOUT_DELTA
end

def comparable_native_tool_work?(left, right)
  left_tool = native_tool_snapshot(left)["tool"].to_s
  right_tool = native_tool_snapshot(right)["tool"].to_s
  left_hit_rate = native_tool_number(left, "hit_rate")
  right_hit_rate = native_tool_number(right, "hit_rate")
  left_non_cacheable_signature = stable_hash_signature(native_tool_hash(left, "non_cacheable_reasons"))
  right_non_cacheable_signature = stable_hash_signature(native_tool_hash(right, "non_cacheable_reasons"))
  return false if left_tool.empty? || left_tool != right_tool
  return false if left_hit_rate.nil? || right_hit_rate.nil?
  return false if left_non_cacheable_signature.nil? || right_non_cacheable_signature.nil?
  return false unless cache_error_free_for_runner_variance?(left) && cache_error_free_for_runner_variance?(right)
  return false unless cache_timeouts_similar_for_runner_variance?(left, right)

  %w[compile_requests compile_requests_executed cache_hits cache_misses non_cacheable_calls].all? do |key|
    similar_native_tool_count?(left, right, key)
  end &&
    similar_native_tool_hash_counts?(left, right, "hit_counts") &&
    similar_native_tool_hash_counts?(left, right, "miss_counts") &&
    (left_hit_rate - right_hit_rate).abs <= RUNNER_VARIANCE_MAX_HIT_RATE_DELTA &&
    left_non_cacheable_signature == right_non_cacheable_signature
end

def compiler_seconds_for_runner_variance(snapshot)
  compiler_seconds = native_tool_number(snapshot, "average_compiler_seconds")
  return nil if compiler_seconds.nil? || compiler_seconds <= 0

  compiler_seconds
end

def tool_elapsed_seconds_for_runner_variance(snapshot)
  elapsed_seconds = provider_tool_elapsed_seconds(snapshot)
  return nil if elapsed_seconds.nil? || elapsed_seconds <= 0

  elapsed_seconds
end

def spread_ratio(values)
  peer_median = median(values)
  return nil if peer_median.nil? || peer_median <= 0

  (values.max - values.min) / peer_median
end

def runner_variance_outlier_evidence(candidate:, peers:)
  candidate_compiler = compiler_seconds_for_runner_variance(candidate.fetch(:snapshot))
  candidate_elapsed = tool_elapsed_seconds_for_runner_variance(candidate.fetch(:snapshot))
  return nil unless candidate_compiler
  return nil unless candidate_elapsed

  comparable_peers = peers.select do |peer|
    compiler_seconds_for_runner_variance(peer.fetch(:snapshot)) &&
      tool_elapsed_seconds_for_runner_variance(peer.fetch(:snapshot)) &&
      comparable_native_tool_work?(candidate.fetch(:snapshot), peer.fetch(:snapshot))
  end
  return nil if comparable_peers.length < RUNNER_VARIANCE_MIN_PROVIDER_SAMPLES - 1

  peer_compilers = comparable_peers.map { |peer| compiler_seconds_for_runner_variance(peer.fetch(:snapshot)) }
  peer_spread_ratio = spread_ratio(peer_compilers)
  return nil if peer_spread_ratio.nil? || peer_spread_ratio > RUNNER_VARIANCE_MAX_PEER_SPREAD_RATIO
  peer_elapsed_seconds = comparable_peers.map { |peer| tool_elapsed_seconds_for_runner_variance(peer.fetch(:snapshot)) }
  peer_elapsed_spread_ratio = spread_ratio(peer_elapsed_seconds)
  return nil if peer_elapsed_spread_ratio.nil? || peer_elapsed_spread_ratio > RUNNER_VARIANCE_MAX_PEER_SPREAD_RATIO

  peer_median = median(peer_compilers)
  compiler_delta = candidate_compiler - peer_median
  compiler_deviation_seconds = compiler_delta.abs
  compiler_deviation_ratio = compiler_deviation_seconds / peer_median
  return nil unless compiler_deviation_seconds >= RUNNER_VARIANCE_MIN_COMPILER_DEVIATION_SECONDS &&
    compiler_deviation_ratio >= RUNNER_VARIANCE_MIN_COMPILER_DEVIATION_RATIO

  peer_elapsed_median = median(peer_elapsed_seconds)
  elapsed_delta = candidate_elapsed - peer_elapsed_median
  elapsed_deviation_seconds = elapsed_delta.abs
  elapsed_deviation_ratio = elapsed_deviation_seconds / peer_elapsed_median
  return nil if compiler_delta.positive? != elapsed_delta.positive?
  return nil unless elapsed_deviation_seconds >= RUNNER_VARIANCE_MIN_TOOL_ELAPSED_DEVIATION_SECONDS &&
    elapsed_deviation_ratio >= RUNNER_VARIANCE_MIN_TOOL_ELAPSED_DEVIATION_RATIO

  {
    "outlier_direction" => candidate_compiler > peer_median ? "slower" : "faster",
    "peer_run_ids" => comparable_peers.map { |peer| peer.fetch(:snapshot)["run_id"] }.compact,
    "peer_average_compiler_seconds" => peer_compilers.map { |value| value.round(3) },
    "peer_average_compiler_median_seconds" => peer_median.round(3),
    "peer_compiler_spread_ratio" => peer_spread_ratio.round(4),
    "compiler_deviation_seconds" => compiler_deviation_seconds.round(3),
    "compiler_deviation_ratio" => compiler_deviation_ratio.round(4),
    "tool_elapsed_seconds" => candidate_elapsed.round(3),
    "peer_tool_elapsed_seconds" => peer_elapsed_seconds.map { |value| value.round(3) },
    "peer_tool_elapsed_median_seconds" => peer_elapsed_median.round(3),
    "peer_tool_elapsed_spread_ratio" => peer_elapsed_spread_ratio.round(4),
    "tool_elapsed_deviation_seconds" => elapsed_deviation_seconds.round(3),
    "tool_elapsed_deviation_ratio" => elapsed_deviation_ratio.round(4)
  }
end

def runner_variance_outlier_for_sample?(candidate:, peers:)
  !runner_variance_outlier_evidence(candidate: candidate, peers: peers).nil?
end

def runner_variance_outliers_for_samples(samples)
  samples_by_head = samples.group_by { |sample| sample.fetch(:snapshot)["head_sha"].to_s }.reject { |head, _| head.empty? }

  samples_by_head.flat_map do |head_sha, head_samples|
    next [] if head_samples.length < RUNNER_VARIANCE_MIN_PROVIDER_SAMPLES

    head_samples.each_with_object([]) do |candidate, acc|
      peers = head_samples.reject { |sample| sample.equal?(candidate) }
      evidence = runner_variance_outlier_evidence(candidate: candidate, peers: peers)
      next if evidence.nil?

      snapshot = candidate.fetch(:snapshot)
      acc << {
        "strategy" => candidate.fetch(:strategy),
        "run_id" => snapshot["run_id"],
        "run_url" => snapshot["run_url"],
        "head_sha" => head_sha,
        "reason" => "runner_variance_outlier",
        "average_compiler_seconds" => native_tool_number(snapshot, "average_compiler_seconds"),
        "cache_hits" => native_tool_number(snapshot, "cache_hits")&.round,
        "cache_misses" => native_tool_number(snapshot, "cache_misses")&.round,
        "hit_rate" => native_tool_number(snapshot, "hit_rate"),
        "compile_requests" => native_tool_number(snapshot, "compile_requests")&.round,
        "compile_requests_executed" => native_tool_number(snapshot, "compile_requests_executed")&.round,
        "non_cacheable_calls" => native_tool_number(snapshot, "non_cacheable_calls")&.round
      }.merge(evidence).reject { |_, value| value.nil? }
    end
  end
end

def provider_snapshot(data, strategy:)
  snapshot = strategy_snapshot(data)
  scenario_seconds = provider_scenario_seconds(snapshot)
  snapshot["scenario_seconds"] = scenario_seconds if scenario_seconds
  scenario_metric_source = provider_scenario_metric_source(snapshot)
  snapshot["scenario_metric_source"] = scenario_metric_source if scenario_metric_source

  tool_elapsed_seconds = provider_tool_elapsed_seconds(snapshot)
  snapshot["tool_elapsed_seconds"] = tool_elapsed_seconds if tool_elapsed_seconds
  tool_elapsed_components = provider_tool_elapsed_components(snapshot)
  snapshot["tool_elapsed_components"] = tool_elapsed_components if tool_elapsed_components

  return snapshot if provider_storage_available?(strategy)

  snapshot.reject { |key, _| %w[storage_bytes storage_source storage_breakdown].include?(key) }.merge(
    "storage_available" => false,
    "storage_note" => "#{provider_label(strategy)} storage is not available from benchmark artifacts."
  )
end

def provider_lane_payload(lane:, runs:, unique_head_count:, snapshots:, storage_available:)
  summary = average_snapshot(snapshots)
  scenario_seconds = average(snapshots.map { |snapshot| provider_scenario_seconds(snapshot) })
  tool_elapsed_seconds = average(snapshots.map { |snapshot| provider_tool_elapsed_seconds(snapshot) })
  state = if snapshots.empty?
    "missing_sample"
  elsif tool_elapsed_seconds
    "healthy"
  else
    "missing_tool_elapsed"
  end

  payload = {
    "lane" => lane,
    "state" => state,
    "successful_run_count" => runs.length,
    "unique_head_count" => unique_head_count,
    "selected_sample_count" => snapshots.length,
    "window_sample_target" => PAIR_COUNT,
    "storage_available" => storage_available
  }

  if snapshots.any?
    summary["scenario_seconds"] = scenario_seconds if scenario_seconds
    summary["tool_elapsed_seconds"] = tool_elapsed_seconds if tool_elapsed_seconds
    payload.merge!(
      "latest_run_id" => summary["run_id"],
      "latest_run_url" => summary["run_url"],
      "latest_head_sha" => summary["head_sha"],
      "latest_created_at" => summary["created_at"],
      "sample_run_ids" => summary["sample_run_ids"],
      "sample_run_urls" => summary["sample_run_urls"],
      "sample_head_shas" => summary["head_shas"],
      "summary" => summary,
      "samples" => snapshots
    )
    if tool_elapsed_seconds
      payload["headline"] = {
        "metric" => "tool_elapsed_seconds",
        "label" => "Tool Elapsed",
        "seconds" => tool_elapsed_seconds,
        "sample_count" => snapshots.length
      }
    end
  end

  payload
end

def provider_lane_samples(providers, lane)
  providers.flat_map do |strategy, provider|
    lane_payload = provider.dig("lanes", lane)
    next [] unless lane_payload.is_a?(Hash)

    Array(lane_payload["samples"]).map do |snapshot|
      {
        strategy: strategy,
        snapshot: snapshot
      }
    end
  end
end

def rebuild_provider_lane_with_runner_variance_outliers(lane_payload:, lane:, outliers:)
  rejected_run_ids = outliers.map { |row| row["run_id"] }.compact
  remaining_samples = Array(lane_payload["samples"]).reject { |snapshot| rejected_run_ids.include?(snapshot["run_id"]) }

  rebuilt = provider_lane_payload(
    lane: lane,
    runs: Array.new(lane_payload["successful_run_count"].to_i),
    unique_head_count: lane_payload["unique_head_count"].to_i,
    snapshots: remaining_samples,
    storage_available: lane_payload["storage_available"]
  )

  rebuilt["source_sample_count"] = Array(lane_payload["samples"]).length
  rebuilt["excluded_sample_count"] = outliers.length
  rebuilt["excluded_runner_variance_outlier_count"] = outliers.length
  rebuilt["runner_variance_outliers"] = outliers
  rebuilt["reporting_note"] = "#{outliers.length}/#{Array(lane_payload["samples"]).length} samples excluded as conservative runner-variance outliers."
  rebuilt
end

def apply_runner_variance_outlier_filter(providers)
  LANE_IDS.each do |lane|
    outliers = runner_variance_outliers_for_samples(provider_lane_samples(providers, lane))
    next if outliers.empty?

    outliers_by_strategy = outliers.group_by { |row| row.fetch("strategy") }
    outliers_by_strategy.each do |strategy, strategy_outliers|
      lane_payload = providers.dig(strategy, "lanes", lane)
      next unless lane_payload.is_a?(Hash)

      providers[strategy]["lanes"][lane] = rebuild_provider_lane_with_runner_variance_outliers(
        lane_payload: lane_payload,
        lane: lane,
        outliers: strategy_outliers
      )
    end
  end

  providers
end

def provider_lane_outlier_payload(lane:, runs:, unique_head_count:, storage_available:, reason:)
  {
    "lane" => lane,
    "state" => "outlier",
    "successful_run_count" => runs.length,
    "unique_head_count" => unique_head_count,
    "selected_sample_count" => 0,
    "window_sample_target" => PAIR_COUNT,
    "storage_available" => storage_available,
    "outlier_reason" => reason
  }
end

def load_provider_lane_data(temp_root:, benchmark:, lane:, strategy:, runs:, cache:, artifacts_cache:)
  runs_by_head = runs_by_head_grouped(runs)
  outlier_reason = provider_lane_outlier_reason(benchmark: benchmark, strategy: strategy, lane: lane)
  if outlier_reason
    return provider_lane_outlier_payload(
      lane: lane,
      runs: runs,
      unique_head_count: runs_by_head.keys.length,
      storage_available: provider_storage_available?(strategy),
      reason: outlier_reason
    )
  end

  heads = runs_by_head.keys.sort_by do |head|
    runs_by_head[head].map { |run| parse_timestamp(run["createdAt"]) || Time.at(0) }.max
  end.reverse
  snapshots = []
  artifact_ids = benchmark_artifact_ids(benchmark)

  heads.each do |head|
    run = latest_run_with_artifact(
      runs_for_head: runs_by_head[head],
      repo: benchmark.fetch("source_repo"),
      benchmark_id: artifact_ids,
      strategy: strategy,
      lane: lane,
      artifacts_cache: artifacts_cache
    )
    next if run.nil?

    data = load_strategy_data(
      temp_root: temp_root,
      repo: benchmark.fetch("source_repo"),
      run: run,
      benchmark_id: artifact_ids,
      strategy: strategy,
      lane: lane,
      cache: cache
    )
    next if data[:metrics].nil?

    snapshots << provider_snapshot(data, strategy: strategy)
    break if snapshots.length >= PAIR_COUNT
  end

  provider_lane_payload(
    lane: lane,
    runs: runs,
    unique_head_count: runs_by_head.keys.length,
    snapshots: snapshots,
    storage_available: provider_storage_available?(strategy)
  )
end

def load_provider_entry(temp_root:, benchmark:, provider_workflows:, provider_runs:, cache:, artifacts_cache:)
  providers = provider_workflows.each_with_object({}) do |(strategy, workflow_name), acc|
    runs = provider_runs.fetch(strategy, [])
    lanes = LANE_IDS.each_with_object({}) do |lane, lane_acc|
      lane_acc[lane] = load_provider_lane_data(
        temp_root: temp_root,
        benchmark: benchmark,
        lane: lane,
        strategy: strategy,
        runs: runs,
        cache: cache,
        artifacts_cache: artifacts_cache
      )
    end

    acc[strategy] = {
      "strategy" => strategy,
      "label" => provider_label(strategy),
      "workflow" => workflow_name,
      "lanes" => lanes
    }
  end
  providers = apply_runner_variance_outlier_filter(providers)

  {
    "benchmark" => benchmark.fetch("benchmark"),
    "name" => benchmark.fetch("name"),
    "source_repo" => benchmark.fetch("source_repo"),
    "category" => benchmark.fetch("category"),
    "step" => benchmark.fetch("step"),
    "providers" => providers
  }
end

def load_lane_data(temp_root:, benchmark:, lane:, actions_runs:, boringcache_runs:, cache:, artifacts_cache:)
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

  {
    latest: latest_lane_entry(entries),
    window: average_lane_entries(entries, benchmark: benchmark, lane: lane),
    pairs: entries.map { |entry| pair_point_from_entry(entry) },
    health: lane_health(
      benchmark: benchmark,
      lane: lane,
      actions_runs: actions_runs,
      boringcache_runs: boringcache_runs,
      paired_head_count: paired.length,
      entries: entries
    )
  }
end

def load_lane_entry(temp_root:, benchmark:, lane:, actions_runs:, boringcache_runs:, cache:, artifacts_cache:)
  load_lane_data(
    temp_root: temp_root,
    benchmark: benchmark,
    lane: lane,
    actions_runs: actions_runs,
    boringcache_runs: boringcache_runs,
    cache: cache,
    artifacts_cache: artifacts_cache
  )[:window]
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

def write_pair_points(pair_points, generated_at:)
  FileUtils.mkdir_p(File.dirname(PAIR_POINTS_PATH))
  payload = {
    "generated_at" => generated_at,
    "pair_count" => pair_points.length,
    "pairs" => pair_points
  }
  File.write(PAIR_POINTS_PATH, JSON.pretty_generate(payload) + "\n")
  puts "Wrote #{PAIR_POINTS_PATH} with #{pair_points.length} pairs"
end

def write_windows(entries, generated_at:)
  FileUtils.mkdir_p(File.dirname(WINDOWS_PATH))
  payload = {
    "generated_at" => generated_at,
    "window_pair_target" => PAIR_COUNT,
    "entries" => entries
  }
  File.write(WINDOWS_PATH, JSON.pretty_generate(payload) + "\n")
  puts "Wrote #{WINDOWS_PATH} with #{entries.length} entries"
end

def write_health(health_entries, generated_at:)
  FileUtils.mkdir_p(File.dirname(HEALTH_PATH))
  payload = {
    "generated_at" => generated_at,
    "entries" => health_entries
  }
  File.write(HEALTH_PATH, JSON.pretty_generate(payload) + "\n")
  puts "Wrote #{HEALTH_PATH} with #{health_entries.length} entries"
end

def write_provider_matrix(provider_entries, generated_at:)
  FileUtils.mkdir_p(File.dirname(PROVIDERS_PATH))
  payload = {
    "generated_at" => generated_at,
    "window_sample_target" => PAIR_COUNT,
    "providers" => PROVIDER_LABELS,
    "entries" => provider_entries
  }
  File.write(PROVIDERS_PATH, JSON.pretty_generate(payload) + "\n")
  puts "Wrote #{PROVIDERS_PATH} with #{provider_entries.length} entries"
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
  window_entries = []
  pair_points = []
  health_entries = []
  provider_entries = []
  strategy_data_cache = {}
  raise "BENCHMARKS_PAIR_COUNT must be >= 1" if PAIR_COUNT < 1

  Dir.mktmpdir("benchmark-index-") do |tmp|
    BENCHMARKS.each do |benchmark|
      benchmark_id = benchmark.fetch("benchmark")
      preserved_entry = existing_entries[benchmark_id]
      preserved_entry = preserved_entry.merge("public" => benchmark.fetch("public")) if preserved_entry

      begin
        with_benchmark_timeout(benchmark) do
          repo = benchmark.fetch("source_repo")
          log_progress("refreshing #{benchmark_id} from #{repo}")
          provider_workflows = provider_workflows_for(benchmark)
          log_progress("loading #{benchmark_id} workflow runs")
          provider_runs = provider_workflows.transform_values do |workflow_name|
            latest_successful_runs(repo: repo, workflow_name: workflow_name)
          end
          actions_runs = provider_runs.fetch("actions-cache")
          boringcache_runs = provider_runs.fetch("boringcache")
          artifacts_cache = {}
          latest_lane_entries = {}
          window_lane_entries = {}
          lane_health = {}

          LANE_IDS.each do |lane|
            log_progress("loading #{benchmark_id} #{lane} lane")
            lane_data = load_lane_data(
              temp_root: tmp,
              benchmark: benchmark,
              lane: lane,
              actions_runs: actions_runs,
              boringcache_runs: boringcache_runs,
              cache: strategy_data_cache,
              artifacts_cache: artifacts_cache
            )

            latest_lane_entries[lane] = lane_data[:latest] if lane_data[:latest]
            window_lane_entries[lane] = lane_data[:window] if lane_data[:window]
            pair_points.concat(lane_data[:pairs])
            lane_health[lane] = lane_data[:health]
          end

          log_progress("loading #{benchmark_id} provider matrix")
          provider_entries << load_provider_entry(
            temp_root: tmp,
            benchmark: benchmark,
            provider_workflows: provider_workflows,
            provider_runs: provider_runs,
            cache: strategy_data_cache,
            artifacts_cache: artifacts_cache
          )

          entry = merge_lane_entries(latest_lane_entries)
          window_entry = merge_lane_entries(window_lane_entries)
          health_entries << {
            "benchmark" => benchmark_id,
            "name" => benchmark["name"],
            "source_repo" => benchmark["source_repo"],
            "lanes" => lane_health
          }

          if entry.nil?
            if PRESERVE_STALE_ENTRIES && preserved_entry
              warn "Preserving #{benchmark['name']} from existing index: no successful run pair found"
              entries << preserved_entry
            else
              warn "Skipping #{benchmark['name']}: no successful run pair found"
            end
          else
            entries << entry
            window_entries << window_entry if window_entry
          end

          log_progress("finished #{benchmark_id}")
        end
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
  window_entries = window_entries.map { |entry| normalize_entry_reporting(entry) }
  pair_points = pair_points.map { |entry| normalize_entry_reporting(entry) }
  write_index(entries, generated_at: generated_at)
  write_pair_points(pair_points, generated_at: generated_at)
  write_windows(window_entries, generated_at: generated_at)
  write_health(health_entries, generated_at: generated_at)
  write_provider_matrix(provider_entries, generated_at: generated_at)
  write_detail_files(entries, generated_at: generated_at)
  write_report(entries, generated_at: generated_at)
end

main if __FILE__ == $PROGRAM_NAME
