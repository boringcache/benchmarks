#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "time"
require "tmpdir"

OUTPUT_PATH = File.join("data", "latest", "index.json")
MAX_CMD_RETRIES = ENV.fetch("BENCHMARKS_GH_RETRIES", "3").to_i

BENCHMARKS = [
  {
    "benchmark" => "hugo",
    "name" => "Hugo",
    "logo" => "hugo",
    "repo" => "gohugoio/hugo",
    "source_repo" => "boringcache/benchmark-hugo",
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

def latest_successful_runs(repo:, workflow_name:, limit: 30)
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

  json_file = Dir.glob(File.join(temp_dir, "**", "*.json")).first
  return nil unless json_file

  JSON.parse(File.read(json_file))
end

def extract_strategy_metrics(payload)
  runs = payload.fetch("runs", {})
  speed = payload.fetch("speed", {})
  stale = payload.fetch("stale", payload.fetch("stale_docker_cache", {}))
  layer_miss = payload.fetch("layer_miss", payload.fetch("internal_only", {}))
  cache = payload.fetch("cache", {})

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
    storage_source: cache["storage_source"].to_s.strip
  }
end

def warm_steady_seconds(metrics)
  metrics[:warm2_seconds] || metrics[:warm_average_seconds] || metrics[:warm1_seconds]
end

def load_strategy_data(temp_root:, repo:, run:, benchmark_id:, strategy:)
  run_id = run.fetch("databaseId")
  artifact_name = benchmark_artifact_name(repo: repo, run_id: run_id, benchmark_id: benchmark_id, strategy: strategy)
  run_total = run_total_seconds(repo: repo, run_id: run_id)

  return { run: run, run_total_seconds: run_total, metrics: nil } if artifact_name.nil?

  run_tmp = File.join(temp_root, "#{benchmark_id}-#{strategy}-#{run_id}")
  FileUtils.mkdir_p(run_tmp)
  payload = download_artifact_json(repo: repo, run_id: run_id, artifact_name: artifact_name, temp_dir: run_tmp)

  return { run: run, run_total_seconds: run_total, metrics: nil } if payload.nil?

  {
    run: run,
    run_total_seconds: run_total,
    metrics: extract_strategy_metrics(payload)
  }
end

def pick_run_pair(actions_runs:, boringcache_runs:)
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

    return {
      actions: ac_run,
      boringcache: bc_run,
      paired_on_head_sha: true,
      pairing_head_sha: head
    }
  end

  {
    actions: actions_runs.first,
    boringcache: boringcache_runs.first,
    paired_on_head_sha: false,
    pairing_head_sha: nil
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
    "storage_source" => metrics[:storage_source]
  }
end

def headline_metric_for(category:, actions_metrics:, boringcache_metrics:, actions_run_total:, boringcache_run_total:)
  if category == "docker" && actions_metrics[:layer_miss_seconds] && boringcache_metrics[:layer_miss_seconds]
    return ["layer_miss", actions_metrics[:layer_miss_seconds], boringcache_metrics[:layer_miss_seconds]]
  end

  if actions_metrics[:stale_mid_seconds] && boringcache_metrics[:stale_mid_seconds]
    return ["stale_mid", actions_metrics[:stale_mid_seconds], boringcache_metrics[:stale_mid_seconds]]
  end

  ac_warm = warm_steady_seconds(actions_metrics)
  bc_warm = warm_steady_seconds(boringcache_metrics)
  if ac_warm && bc_warm
    return ["warm", ac_warm, bc_warm]
  end

  if actions_run_total && boringcache_run_total
    return ["run_total", actions_run_total, boringcache_run_total]
  end

  nil
end

def build_entry(benchmark:, pair:, actions_data:, boringcache_data:)
  actions_metrics = actions_data[:metrics]
  boringcache_metrics = boringcache_data[:metrics]
  return nil if actions_metrics.nil? || boringcache_metrics.nil?

  headline = headline_metric_for(
    category: benchmark.fetch("category"),
    actions_metrics: actions_metrics,
    boringcache_metrics: boringcache_metrics,
    actions_run_total: actions_data[:run_total_seconds],
    boringcache_run_total: boringcache_data[:run_total_seconds]
  )
  return nil if headline.nil?

  headline_scenario, before_value, after_value = headline
  faster_pct = percent_delta(before_value, after_value)
  return nil if faster_pct.nil?

  {
    "benchmark" => benchmark["benchmark"],
    "name" => benchmark["name"],
    "logo" => benchmark["logo"],
    "repo" => benchmark["repo"],
    "source_repo" => benchmark["source_repo"],
    "category" => benchmark["category"],
    "step" => benchmark["step"],
    "headline_scenario" => headline_scenario,
    "before" => seconds_to_text(before_value),
    "after" => seconds_to_text(after_value),
    "before_seconds" => before_value.round(2),
    "after_seconds" => after_value.round(2),
    "faster" => [faster_pct.round, 0].max.to_s,
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

def write_index(entries)
  FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
  payload = {
    "generated_at" => Time.now.utc.iso8601,
    "entries" => entries
  }
  File.write(OUTPUT_PATH, JSON.pretty_generate(payload) + "\n")
  puts "Wrote #{OUTPUT_PATH} with #{entries.length} entries"
end

entries = []

Dir.mktmpdir("benchmark-index-") do |tmp|
  BENCHMARKS.each do |benchmark|
    begin
      repo = benchmark.fetch("source_repo")
      actions_runs = latest_successful_runs(repo: repo, workflow_name: benchmark.fetch("actions_workflow"))
      boringcache_runs = latest_successful_runs(repo: repo, workflow_name: benchmark.fetch("boringcache_workflow"))
      pair = pick_run_pair(actions_runs: actions_runs, boringcache_runs: boringcache_runs)
      next if pair.nil?

      actions_data = load_strategy_data(
        temp_root: tmp,
        repo: repo,
        run: pair.fetch(:actions),
        benchmark_id: benchmark.fetch("benchmark"),
        strategy: "actions-cache"
      )
      boringcache_data = load_strategy_data(
        temp_root: tmp,
        repo: repo,
        run: pair.fetch(:boringcache),
        benchmark_id: benchmark.fetch("benchmark"),
        strategy: "boringcache"
      )
      entry = build_entry(
        benchmark: benchmark,
        pair: pair,
        actions_data: actions_data,
        boringcache_data: boringcache_data
      )
      entries << entry if entry
    rescue StandardError => e
      warn "Skipping #{benchmark['name']}: #{e.message}"
    end
  end
end

write_index(entries)
