#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "time"
require "tmpdir"

REPO = ENV.fetch("BENCHMARKS_REPO", "boringcache/benchmarks")
OUTPUT_PATH = File.join("data", "latest", "index.json")
MAX_CMD_RETRIES = ENV.fetch("BENCHMARKS_GH_RETRIES", "3").to_i

DEFAULT_ENTRIES = [
  {
    "name" => "n8n",
    "logo" => "n8n",
    "repo" => "n8n-io/n8n",
    "step" => "Docker build (pnpm+turbo)",
    "before" => "6m 4s",
    "after" => "1m 22s",
    "faster" => "77"
  },
  {
    "name" => "Immich",
    "logo" => "immich",
    "repo" => "immich-app/immich",
    "step" => "Docker build (server)",
    "before" => "12m 36s",
    "after" => "10m 40s",
    "faster" => "15"
  },
  {
    "name" => "Hugo",
    "logo" => "hugo",
    "repo" => "gohugoio/hugo",
    "step" => "Docker build (Go)",
    "before" => "12m 36s",
    "after" => "7m 32s",
    "faster" => "40"
  },
  {
    "name" => "Mastodon",
    "logo" => "mastodon",
    "repo" => "mastodon/mastodon",
    "step" => "Docker build (Ruby+Node)",
    "before" => "pending",
    "after" => "22m 40s",
    "faster" => "0"
  },
  {
    "name" => "PostHog",
    "logo" => "posthog",
    "repo" => "PostHog/posthog",
    "step" => "Docker build (full stack)",
    "before" => "pending",
    "after" => "26m 33s",
    "faster" => "0"
  },
  {
    "name" => "Friday Pulse",
    "logo" => "fridaypulse",
    "repo" => "FridayPulse/fridaypulse",
    "step" => "Docker build",
    "before" => "7m 20s",
    "after" => "2m 39s",
    "faster" => "64"
  }
].freeze

COMPARISON_WORKFLOWS = [
  {
    "benchmark" => "n8n",
    "name" => "n8n",
    "logo" => "n8n",
    "repo" => "n8n-io/n8n",
    "step" => "Docker build (pnpm+turbo)",
    "actions_workflow" => "n8n - Actions Cache",
    "boringcache_workflow" => "n8n - BoringCache"
  },
  {
    "benchmark" => "immich",
    "name" => "Immich",
    "logo" => "immich",
    "repo" => "immich-app/immich",
    "step" => "Docker build (server)",
    "actions_workflow" => "Immich - Actions Cache",
    "boringcache_workflow" => "Immich - BoringCache"
  },
  {
    "benchmark" => "hugo",
    "name" => "Hugo",
    "logo" => "hugo",
    "repo" => "gohugoio/hugo",
    "step" => "Docker build (Go)",
    "actions_workflow" => "Hugo - Actions Cache",
    "boringcache_workflow" => "Hugo - BoringCache"
  },
  {
    "benchmark" => "posthog",
    "name" => "PostHog",
    "logo" => "posthog",
    "repo" => "PostHog/posthog",
    "step" => "Docker build (full stack)",
    "actions_workflow" => "PostHog - Actions Cache",
    "boringcache_workflow" => "PostHog - BoringCache",
    "depot_repo" => "depot/benchmark-posthog"
  },
  {
    "benchmark" => "mastodon-docker",
    "name" => "Mastodon",
    "logo" => "mastodon",
    "repo" => "mastodon/mastodon",
    "step" => "Docker build (Ruby+Node)",
    "actions_workflow" => "Mastodon Docker - Actions Cache",
    "boringcache_workflow" => "Mastodon Docker - BoringCache",
    "depot_repo" => "depot/benchmark-mastodon"
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
  return nil if value.nil?

  Time.parse(value.to_s)
rescue ArgumentError
  nil
end

def seconds_to_text(value)
  total = value.round
  minutes = total / 60
  seconds = total % 60
  "#{minutes}m #{seconds}s"
end

def parse_number(value)
  return nil if value.nil?

  Float(value)
rescue ArgumentError, TypeError
  nil
end

def percent_delta(baseline, candidate)
  return nil if baseline.nil? || candidate.nil? || baseline <= 0

  ((baseline - candidate) / baseline) * 100.0
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

  runs = JSON.parse(output)
  runs
    .select { |item| item["conclusion"] == "success" }
    .sort_by { |item| parse_timestamp(item["createdAt"]) || Time.at(0) }
    .reverse
end

def benchmark_artifact_name(run_id, benchmark_id, strategy)
  output = run_cmd("gh", "api", "repos/#{REPO}/actions/runs/#{run_id}/artifacts")
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

def step_duration_seconds(job, action_name)
  step = Array(job["steps"]).find do |item|
    name = item["name"].to_s
    name.include?(action_name) && item["status"] == "completed"
  end
  return nil if step.nil?

  duration_seconds(started_at: step["startedAt"], completed_at: step["completedAt"])
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

def infer_depot_metrics(depot_repo)
  run_id = latest_successful_runs(repo: depot_repo, workflow_name: "Benchmark", limit: 10).first&.fetch("databaseId", nil)
  return nil unless run_id

  run = run_view(repo: depot_repo, run_id: run_id)
  jobs = Array(run["jobs"])
  return nil if jobs.empty?

  docker_job = jobs.find { |job| job["name"].to_s.downcase.include?("docker") }
  depot_job = jobs.find { |job| job["name"].to_s.downcase.include?("depot") }

  docker_seconds = if docker_job
    step_duration_seconds(docker_job, "docker/build-push-action") || job_duration_seconds(docker_job)
  end
  depot_seconds = if depot_job
    step_duration_seconds(depot_job, "depot/build-push-action") || job_duration_seconds(depot_job)
  end

  return nil if docker_seconds.nil? && depot_seconds.nil?

  {
    "repo" => depot_repo,
    "run_id" => run_id,
    "run_url" => run["url"],
    "docker_seconds" => docker_seconds&.round(2),
    "docker_text" => docker_seconds ? seconds_to_text(docker_seconds) : nil,
    "docker_job_url" => docker_job && docker_job["url"],
    "depot_seconds" => depot_seconds&.round(2),
    "depot_text" => depot_seconds ? seconds_to_text(depot_seconds) : nil,
    "depot_job_url" => depot_job && depot_job["url"]
  }
rescue StandardError => e
  warn "Depot metrics lookup failed for #{depot_repo}: #{e.message}"
  nil
end

def download_artifact_json(run_id, artifact_name, temp_dir)
  run_cmd(
    "gh", "run", "download", run_id.to_s,
    "--repo", REPO,
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
  stale = payload.fetch("stale_docker_cache", {})
  internal_only = payload.fetch("internal_only", {})
  cache = payload.fetch("cache", {})

  warm1 = parse_number(runs["warm1_seconds"])
  warm2 = parse_number(runs["warm2_seconds"])
  warm_avg = parse_number(speed["warm_average_seconds"])
  if warm_avg.nil?
    warm_values = [warm1, warm2].compact
    warm_avg = warm_values.sum / warm_values.length if warm_values.any?
  end

  {
    cold_seconds: parse_number(runs["cold_seconds"]),
    warm1_seconds: warm1,
    warm2_seconds: warm2,
    warm_average_seconds: warm_avg,
    stale_docker_seconds: parse_number(stale["seconds"]) || parse_number(runs["stale_docker_seconds"]),
    internal_only_warm_seconds: parse_number(internal_only["warm_no_docker_cache_seconds"]),
    storage_bytes: parse_number(cache["storage_bytes"])&.round&.to_i,
    storage_source: cache["storage_source"].to_s.strip,
    warm_runs_succeeded: payload.dig("hit_behavior", "two_consecutive_warm_runs_succeeded") == true
  }
end

def warm_steady_seconds(metrics)
  metrics[:warm2_seconds] || metrics[:warm_average_seconds] || metrics[:warm1_seconds]
end

def load_strategy_data(temp_root:, run:, benchmark_id:, strategy:)
  run_id = run.fetch("databaseId")
  artifact_name = benchmark_artifact_name(run_id, benchmark_id, strategy)
  run_total = run_total_seconds(repo: REPO, run_id: run_id)
  return {
    run: run,
    run_total_seconds: run_total,
    artifact_name: nil,
    metrics: nil
  } if artifact_name.nil?

  run_tmp = File.join(temp_root, "#{benchmark_id}-#{strategy}-#{run_id}")
  FileUtils.mkdir_p(run_tmp)
  payload = download_artifact_json(run_id, artifact_name, run_tmp)
  return {
    run: run,
    run_total_seconds: run_total,
    artifact_name: artifact_name,
    metrics: nil
  } if payload.nil?

  {
    run: run,
    run_total_seconds: run_total,
    artifact_name: artifact_name,
    metrics: extract_strategy_metrics(payload)
  }
end

def pick_run_pair(actions_runs:, boringcache_runs:)
  return nil if actions_runs.empty? || boringcache_runs.empty?

  # Prefer a true same-head comparison for apples-to-apples data.
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

  latest_actions = actions_runs.first
  latest_boringcache = boringcache_runs.first

  # Fallback: recency when no shared head exists yet.
  {
    actions: latest_actions,
    boringcache: latest_boringcache,
    paired_on_head_sha: false,
    pairing_head_sha: nil
  }
end

def build_run_duration_only_entry(metadata, pair, actions_data, boringcache_data)
  ac_total = actions_data[:run_total_seconds]
  bc_total = boringcache_data[:run_total_seconds]
  return nil if ac_total.nil? || bc_total.nil?

  faster_pct = percent_delta(ac_total, bc_total)
  return nil if faster_pct.nil?

  {
    "name" => metadata["name"],
    "logo" => metadata["logo"],
    "repo" => metadata["repo"],
    "step" => metadata["step"],
    "before" => seconds_to_text(ac_total),
    "after" => seconds_to_text(bc_total),
    "faster" => [faster_pct.round, 0].max.to_s,
    "before_seconds" => ac_total.round(2),
    "after_seconds" => bc_total.round(2),
    "comparison" => {
      "baseline_strategy" => "actions-cache",
      "candidate_strategy" => "boringcache",
      "paired_on_head_sha" => pair.fetch(:paired_on_head_sha),
      "pairing_head_sha" => pair.fetch(:pairing_head_sha),
      "actions_cache" => {
        "run_id" => pair.fetch(:actions)["databaseId"],
        "run_url" => pair.fetch(:actions)["url"],
        "head_sha" => pair.fetch(:actions)["headSha"],
        "created_at" => pair.fetch(:actions)["createdAt"],
        "run_total_seconds" => ac_total.round(2)
      },
      "boringcache" => {
        "run_id" => pair.fetch(:boringcache)["databaseId"],
        "run_url" => pair.fetch(:boringcache)["url"],
        "head_sha" => pair.fetch(:boringcache)["headSha"],
        "created_at" => pair.fetch(:boringcache)["createdAt"],
        "run_total_seconds" => bc_total.round(2)
      },
      "run_total_delta_seconds" => (ac_total - bc_total).round(2),
      "run_total_improvement_pct" => faster_pct.round(2)
    }
  }
end

def strategy_snapshot(data)
  metrics = data.fetch(:metrics)
  run = data.fetch(:run)
  run_total_seconds = data[:run_total_seconds]

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
    "stale_docker_seconds" => metrics[:stale_docker_seconds],
    "internal_only_warm_seconds" => metrics[:internal_only_warm_seconds],
    "run_total_seconds" => run_total_seconds,
    "storage_bytes" => metrics[:storage_bytes],
    "storage_source" => metrics[:storage_source],
    "two_warm_runs_succeeded" => metrics[:warm_runs_succeeded]
  }
end

def build_comparison_entry(metadata, actions_data, boringcache_data, pair, depot_metrics: nil)
  actions_metrics = actions_data.fetch(:metrics)
  boringcache_metrics = boringcache_data.fetch(:metrics)
  ac_run_total = actions_data[:run_total_seconds]
  bc_run_total = boringcache_data[:run_total_seconds]

  ac_warm = warm_steady_seconds(actions_metrics)
  bc_warm = warm_steady_seconds(boringcache_metrics)
  return nil if ac_warm.nil? || bc_warm.nil?

  # For Docker benchmarks, headline uses the "code changed" (stale Docker) scenario —
  # that's the most common real-world CI build. run_total includes all benchmark
  # scenarios (cold+seed+warm×2+stale+internal) and doesn't represent a single build.
  ac_stale = actions_metrics[:stale_docker_seconds]
  bc_stale = boringcache_metrics[:stale_docker_seconds]
  is_docker_benchmark = ac_stale && bc_stale

  if is_docker_benchmark
    display_before = ac_stale
    display_after = bc_stale
  else
    display_before = ac_run_total || ac_warm
    display_after = bc_run_total || bc_warm
  end
  display_faster_pct = percent_delta(display_before, display_after)
  warm_faster_pct = percent_delta(ac_warm, bc_warm)
  return nil if display_faster_pct.nil? || warm_faster_pct.nil?

  entry = {
    "name" => metadata["name"],
    "logo" => metadata["logo"],
    "repo" => metadata["repo"],
    "step" => metadata["step"],
    "headline_scenario" => is_docker_benchmark ? "stale_docker" : "run_total",
    "before" => seconds_to_text(display_before),
    "after" => seconds_to_text(display_after),
    "faster" => [display_faster_pct.round, 0].max.to_s,
    "before_seconds" => display_before.round(2),
    "after_seconds" => display_after.round(2),
    "metrics" => {
      "stale_docker_seconds" => boringcache_metrics[:stale_docker_seconds],
      "internal_only_warm_seconds" => boringcache_metrics[:internal_only_warm_seconds]
    },
    "comparison" => {
      "baseline_strategy" => "actions-cache",
      "candidate_strategy" => "boringcache",
      "paired_on_head_sha" => pair.fetch(:paired_on_head_sha),
      "pairing_head_sha" => pair.fetch(:pairing_head_sha),
      "actions_cache" => strategy_snapshot(actions_data),
      "boringcache" => strategy_snapshot(boringcache_data),
      "warm_delta_seconds" => (ac_warm - bc_warm).round(2),
      "warm_improvement_pct" => warm_faster_pct.round(2)
    }
  }

  # Run total (full benchmark workflow) — kept for reference, not used as headline
  if ac_run_total && bc_run_total
    entry["comparison"]["run_total_delta_seconds"] = (ac_run_total - bc_run_total).round(2)
    entry["comparison"]["run_total_improvement_pct"] = percent_delta(ac_run_total, bc_run_total)&.round(2)
  end

  if is_docker_benchmark
    entry["comparison"]["stale_delta_seconds"] = (ac_stale - bc_stale).round(2)
    entry["comparison"]["stale_improvement_pct"] = percent_delta(ac_stale, bc_stale)&.round(2)
  end

  internal_baseline = actions_metrics[:internal_only_warm_seconds]
  internal_baseline_source = "actions-cache.internal_only"
  if internal_baseline.nil?
    internal_baseline = actions_metrics[:stale_docker_seconds]
    internal_baseline_source = "actions-cache.stale_docker"
  end
  bc_internal = boringcache_metrics[:internal_only_warm_seconds]
  if internal_baseline && bc_internal
    entry["comparison"]["internal_baseline_source"] = internal_baseline_source
    entry["comparison"]["internal_delta_seconds"] = (internal_baseline - bc_internal).round(2)
    entry["comparison"]["internal_improvement_pct"] = percent_delta(internal_baseline, bc_internal)&.round(2)
  end

  ac_storage = actions_metrics[:storage_bytes]
  bc_storage = boringcache_metrics[:storage_bytes]
  ac_storage_source = actions_metrics[:storage_source].to_s
  bc_storage_source = boringcache_metrics[:storage_source].to_s

  # For Docker benchmarks, the AC script reports total repo cache (buildkit blobs
  # are shared across projects and can't be attributed per-project). Only compute
  # storage ratios when AC storage is clearly per-project (non-Docker benchmarks).
  is_docker = actions_metrics[:stale_docker_seconds] || boringcache_metrics[:stale_docker_seconds]
  ac_storage_is_per_project = !is_docker

  if ac_storage && bc_storage && bc_storage > 0 && ac_storage_is_per_project
    entry["comparison"]["storage_saved_bytes"] = ac_storage - bc_storage
    entry["comparison"]["storage_improvement_pct"] = percent_delta(ac_storage.to_f, bc_storage.to_f)&.round(2)
    entry["comparison"]["storage_ratio_ac_div_bc"] = (ac_storage.to_f / bc_storage).round(2)
  end

  if depot_metrics
    entry["depot"] = depot_metrics
    depot_docker = parse_number(depot_metrics["docker_seconds"])
    if depot_docker && depot_docker.positive?
      entry["comparison"]["warm_vs_depot_docker_delta_seconds"] = (depot_docker - bc_warm).round(2)
      entry["comparison"]["warm_vs_depot_docker_improvement_pct"] = percent_delta(depot_docker, bc_warm)&.round(2)
    end
  end

  entry
end

def write_index(entries)
  FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
  File.write(OUTPUT_PATH, JSON.pretty_generate({ "entries" => entries }) + "\n")
  puts "Wrote #{OUTPUT_PATH} with #{entries.length} entries"
end

entries_by_name = DEFAULT_ENTRIES.map { |entry| [entry["name"], entry.dup] }.to_h

Dir.mktmpdir("benchmark-index-") do |tmp|
  COMPARISON_WORKFLOWS.each do |workflow|
    begin
      actions_runs = latest_successful_runs(repo: REPO, workflow_name: workflow.fetch("actions_workflow"), limit: 40)
      boringcache_runs = latest_successful_runs(repo: REPO, workflow_name: workflow.fetch("boringcache_workflow"), limit: 40)
      pair = pick_run_pair(actions_runs: actions_runs, boringcache_runs: boringcache_runs)
      next if pair.nil?

      actions_data = load_strategy_data(
        temp_root: tmp,
        run: pair.fetch(:actions),
        benchmark_id: workflow.fetch("benchmark"),
        strategy: "actions-cache"
      )
      boringcache_data = load_strategy_data(
        temp_root: tmp,
        run: pair.fetch(:boringcache),
        benchmark_id: workflow.fetch("benchmark"),
        strategy: "boringcache"
      )
      if actions_data.nil? || boringcache_data.nil?
        fallback_entry = build_run_duration_only_entry(workflow, pair, actions_data || {}, boringcache_data || {})
        entries_by_name[fallback_entry["name"]] = fallback_entry if fallback_entry
        next
      end

      if actions_data[:metrics].nil? || boringcache_data[:metrics].nil?
        fallback_entry = build_run_duration_only_entry(workflow, pair, actions_data, boringcache_data)
        entries_by_name[fallback_entry["name"]] = fallback_entry if fallback_entry
        next
      end

      depot_metrics = workflow["depot_repo"] ? infer_depot_metrics(workflow["depot_repo"]) : nil
      dynamic_entry = build_comparison_entry(workflow, actions_data, boringcache_data, pair, depot_metrics: depot_metrics)
      next if dynamic_entry.nil?

      entries_by_name[dynamic_entry["name"]] = dynamic_entry
    rescue StandardError => e
      warn "Skipping #{workflow['name'] || workflow['benchmark']}: #{e.message}"
    end
  end
end

ordered_entries = DEFAULT_ENTRIES.map { |entry| entries_by_name[entry["name"]] }.compact
write_index(ordered_entries)
