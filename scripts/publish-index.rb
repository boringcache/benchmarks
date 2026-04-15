#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "time"
require "tmpdir"

OUTPUT_DIR = File.join("data", "latest")
OUTPUT_PATH = File.join(OUTPUT_DIR, "index.json")
DETAIL_OUTPUT_DIR = File.join(OUTPUT_DIR, "benchmarks")
MAX_CMD_RETRIES = ENV.fetch("BENCHMARKS_GH_RETRIES", "3").to_i
RUN_HISTORY_LIMIT = ENV.fetch("BENCHMARKS_GH_RUN_LIMIT", "100").to_i
LANE_IDS = %w[fresh rolling].freeze

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
    stdout, stderr, status = Open3.capture3(*args)
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

def percent_delta(baseline, candidate)
  return nil if baseline.nil? || candidate.nil? || baseline <= 0

  ((baseline.to_f - candidate.to_f) / baseline.to_f) * 100.0
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

  artifact = artifacts.find do |item|
    name = item["name"].to_s
    !item["expired"] && name.start_with?("benchmark-#{benchmark_id}-#{strategy}")
  end

  artifact && artifact["name"]
end

def lane_artifact_names(benchmark_id:, strategy:, lane:)
  names = ["benchmark-#{benchmark_id}-#{strategy}-#{lane}"]
  names << "benchmark-#{benchmark_id}-#{strategy}" if lane == "fresh"
  names
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

def run_view(repo:, run_id:)
  output = run_cmd(
    "gh", "run", "view", run_id.to_s,
    "--repo", repo,
    "--json", "databaseId,conclusion,status,url,jobs,createdAt,updatedAt"
  )
  JSON.parse(output)
end

def duration_seconds(started_at:, completed_at:)
  started = parse_timestamp(started_at)
  completed = parse_timestamp(completed_at)
  return nil unless started && completed && completed >= started

  completed - started
end

def job_duration_seconds(job)
  duration_seconds(started_at: job["startedAt"], completed_at: job["completedAt"])
end

def run_total_seconds(repo:, run_id:)
  run = run_view(repo: repo, run_id: run_id)
  jobs = Array(run["jobs"])
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
  stale = payload.fetch("stale", payload.fetch("stale_docker_cache", {}))
  layer_miss = payload.fetch("layer_miss", payload.fetch("internal_only", {}))
  cache = payload.fetch("cache", {})
  docker_cache = payload.fetch("docker_cache", {})

  warm1 = parse_number(runs["warm1_seconds"])
  warm2 = parse_number(runs["warm2_seconds"])
  stale_low = parse_number(stale["low_seconds"]) || parse_number(runs["stale_low_seconds"])
  stale_mid = parse_number(stale["mid_seconds"]) || parse_number(runs["stale_mid_seconds"])
  stale_high = parse_number(stale["high_seconds"]) || parse_number(runs["stale_high_seconds"])
  warm_avg = parse_number(speed["warm_average_seconds"])
  if warm_avg.nil?
    warm_values = [warm1, warm2].compact
    warm_avg = warm_values.sum / warm_values.length if warm_values.any?
  end

  stale_seconds = parse_number(stale["seconds"]) || parse_number(runs["stale_seconds"]) || parse_number(runs["stale_docker_seconds"])
  stale_seconds ||= stale_mid || stale_low || stale_high

  {
    cold_seconds: parse_number(runs["cold_seconds"]),
    warm1_seconds: warm1,
    warm2_seconds: warm2,
    warm_average_seconds: warm_avg,
    stale_seconds: stale_seconds,
    stale_low_seconds: stale_low,
    stale_mid_seconds: stale_mid,
    stale_high_seconds: stale_high,
    layer_miss_seconds: parse_number(layer_miss["seconds"]) || parse_number(runs["layer_miss_seconds"]) || parse_number(layer_miss["warm_no_docker_cache_seconds"]),
    storage_bytes: parse_number(cache["storage_bytes"])&.round&.to_i,
    storage_source: cache["storage_source"].to_s.strip,
    docker_cache_import_seconds: parse_number(docker_cache["import_seconds"]),
    docker_cache_export_seconds: parse_number(docker_cache["export_seconds"])
  }
end

def payload_lane(payload)
  lane = payload["lane"].to_s.strip
  lane.empty? ? "fresh" : lane
end

def lane_label(lane)
  case lane.to_s
  when "rolling"
    "Rolling historical"
  else
    "Fresh isolated"
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

  run_tmp = File.join(temp_root, "#{benchmark_id}-#{strategy}-#{run_id}")
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
    "warm1_seconds" => metrics[:warm1_seconds],
    "warm2_seconds" => metrics[:warm2_seconds],
    "warm_average_seconds" => metrics[:warm_average_seconds],
    "warm_steady_seconds" => warm_steady_seconds(metrics),
    "stale_seconds" => metrics[:stale_seconds],
    "stale_low_seconds" => metrics[:stale_low_seconds],
    "stale_mid_seconds" => metrics[:stale_mid_seconds],
    "stale_high_seconds" => metrics[:stale_high_seconds],
    "layer_miss_seconds" => metrics[:layer_miss_seconds],
    "run_total_seconds" => data[:run_total_seconds],
    "storage_bytes" => metrics[:storage_bytes],
    "storage_source" => metrics[:storage_source],
    "docker_cache_import_seconds" => metrics[:docker_cache_import_seconds],
    "docker_cache_export_seconds" => metrics[:docker_cache_export_seconds]
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

def build_entry(benchmark:, pair:, actions_data:, boringcache_data:, lane:)
  actions_metrics = actions_data[:metrics]
  boringcache_metrics = boringcache_data[:metrics]
  return nil if actions_metrics.nil? || boringcache_metrics.nil?

  headline = headline_metric_for(
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
    "benchmark" => benchmark["benchmark"],
    "name" => benchmark["name"],
    "logo" => benchmark["logo"],
    "repo" => benchmark["repo"],
    "source_repo" => benchmark["source_repo"],
    "public" => benchmark.fetch("public"),
    "category" => benchmark["category"],
    "step" => benchmark["step"],
    "headline_scenario" => headline_scenario,
    "before" => seconds_to_text(before_value),
    "after" => seconds_to_text(after_value),
    "before_seconds" => before_value.round(2),
    "after_seconds" => after_value.round(2),
    "faster" => faster_pct.round.to_s,
    "comparison" => {
      "paired_on_head_sha" => pair[:paired_on_head_sha],
      "pairing_head_sha" => pair[:pairing_head_sha],
      "actions_cache" => strategy_snapshot(actions_data),
      "boringcache" => strategy_snapshot(boringcache_data),
      "warm_improvement_pct" => percent_delta(
        warm_steady_seconds(actions_metrics),
        warm_steady_seconds(boringcache_metrics)
      )&.round(2),
      "cold_improvement_pct" => percent_delta(actions_metrics[:cold_seconds], boringcache_metrics[:cold_seconds])&.round(2),
      "stale_low_improvement_pct" => percent_delta(actions_metrics[:stale_low_seconds], boringcache_metrics[:stale_low_seconds])&.round(2),
      "stale_mid_improvement_pct" => percent_delta(actions_metrics[:stale_mid_seconds], boringcache_metrics[:stale_mid_seconds])&.round(2),
      "stale_high_improvement_pct" => percent_delta(actions_metrics[:stale_high_seconds], boringcache_metrics[:stale_high_seconds])&.round(2),
      "layer_miss_improvement_pct" => percent_delta(actions_metrics[:layer_miss_seconds], boringcache_metrics[:layer_miss_seconds])&.round(2),
      "storage_improvement_pct" => percent_delta(actions_metrics[:storage_bytes], boringcache_metrics[:storage_bytes])&.round(2),
      "storage_saved_bytes" => if actions_metrics[:storage_bytes] && boringcache_metrics[:storage_bytes]
        actions_metrics[:storage_bytes] - boringcache_metrics[:storage_bytes]
      end
    }
  }
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

def load_lane_entry(temp_root:, benchmark:, lane:, actions_runs:, boringcache_runs:, cache:)
  return nil if actions_runs.empty? || boringcache_runs.empty?

  actions_by_head = actions_runs.each_with_object({}) do |run, acc|
    head = run["headSha"].to_s
    next if head.empty?
    acc[head] ||= run
  end

  boringcache_runs.each do |bc_run|
    head = bc_run["headSha"].to_s
    next if head.empty?
    ac_run = actions_by_head[head]
    next if ac_run.nil?

    actions_data = load_strategy_data(
      temp_root: temp_root,
      repo: benchmark.fetch("source_repo"),
      run: ac_run,
      benchmark_id: benchmark.fetch("benchmark"),
      strategy: "actions-cache",
      lane: lane,
      cache: cache
    )
    next if actions_data[:metrics].nil?

    boringcache_data = load_strategy_data(
      temp_root: temp_root,
      repo: benchmark.fetch("source_repo"),
      run: bc_run,
      benchmark_id: benchmark.fetch("benchmark"),
      strategy: "boringcache",
      lane: lane,
      cache: cache
    )
    next if boringcache_data[:metrics].nil?

    pair = {
      actions: ac_run,
      boringcache: bc_run,
      paired_on_head_sha: true,
      pairing_head_sha: head
    }

    return build_entry(
      benchmark: benchmark,
      pair: pair,
      actions_data: actions_data,
      boringcache_data: boringcache_data,
      lane: lane
    )
  end

  nil
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

existing_entries = load_existing_entries
entries = []
strategy_data_cache = {}

Dir.mktmpdir("benchmark-index-") do |tmp|
  BENCHMARKS.each do |benchmark|
    benchmark_id = benchmark.fetch("benchmark")
    preserved_entry = existing_entries[benchmark_id]
    preserved_entry = preserved_entry.merge("public" => benchmark.fetch("public")) if preserved_entry

    begin
      repo = benchmark.fetch("source_repo")
      actions_runs = latest_successful_runs(repo: repo, workflow_name: benchmark.fetch("actions_workflow"))
      boringcache_runs = latest_successful_runs(repo: repo, workflow_name: benchmark.fetch("boringcache_workflow"))
      lane_entries = LANE_IDS.each_with_object({}) do |lane, acc|
        lane_entry = load_lane_entry(
          temp_root: tmp,
          benchmark: benchmark,
          lane: lane,
          actions_runs: actions_runs,
          boringcache_runs: boringcache_runs,
          cache: strategy_data_cache
        )
        acc[lane] = lane_entry if lane_entry
      end

      entry = merge_lane_entries(lane_entries)
      if entry.nil?
        if preserved_entry
          warn "Preserving #{benchmark['name']} from existing index: no successful run pair found"
          entries << preserved_entry
        else
          warn "Skipping #{benchmark['name']}: no successful run pair found"
        end
        next
      end

      entries << entry
    rescue StandardError => e
      if preserved_entry
        warn "Preserving #{benchmark['name']} from existing index: #{e.message}"
        entries << preserved_entry
      else
        warn "Skipping #{benchmark['name']}: #{e.message}"
      end
    end
  end
end

generated_at = Time.now.utc.iso8601
write_index(entries, generated_at: generated_at)
write_detail_files(entries, generated_at: generated_at)
