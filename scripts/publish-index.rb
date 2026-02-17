#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "time"
require "tmpdir"

REPO = ENV.fetch("BENCHMARKS_REPO", "boringcache/benchmarks")
OUTPUT_PATH = File.join("data", "latest", "index.json")

DEFAULT_ENTRIES = [
  {
    "name" => "gRPC",
    "logo" => "grpc",
    "repo" => "grpc/grpc",
    "step" => "Docker build (Bazel)",
    "before" => "26m 34s",
    "after" => "1m 46s",
    "faster" => "93"
  },
  {
    "name" => "Mastodon",
    "logo" => "mastodon",
    "repo" => "mastodon/mastodon",
    "step" => "Docker build (Ruby+Node)",
    "before" => "9m 24s",
    "after" => "0m 58s",
    "faster" => "89"
  },
  {
    "name" => "Bevy",
    "logo" => "bevy",
    "repo" => "bevyengine/bevy",
    "step" => "cargo build",
    "before" => "10m 7s",
    "after" => "1m 20s",
    "faster" => "86"
  },
  {
    "name" => "n8n",
    "logo" => "n8n",
    "repo" => "n8n-io/n8n",
    "step" => "Docker build (pnpm+turbo)",
    "before" => "5m 37s",
    "after" => "0m 56s",
    "faster" => "83"
  },
  {
    "name" => "Zed",
    "logo" => "zed",
    "repo" => "zed-industries/zed",
    "step" => "cargo build",
    "before" => "5m 18s",
    "after" => "1m 30s",
    "faster" => "71"
  },
  {
    "name" => "PostHog",
    "logo" => "posthog",
    "repo" => "PostHog/posthog",
    "step" => "Docker build (full stack)",
    "before" => "8m 6s",
    "after" => "3m 6s",
    "faster" => "62"
  },
  {
    "name" => "Discourse",
    "logo" => "discourse",
    "repo" => "discourse/discourse",
    "step" => "bundle install",
    "before" => "1m 48s",
    "after" => "0m 44s",
    "faster" => "59"
  }
].freeze

BORINGCACHE_WORKFLOWS = [
  {
    "workflow" => "Mastodon Docker - BoringCache",
    "benchmark" => "mastodon-docker",
    "name" => "Mastodon",
    "logo" => "mastodon",
    "repo" => "mastodon/mastodon",
    "step" => "Docker build (Ruby+Node)",
    "depot_repo" => "depot/benchmark-mastodon"
  },
  {
    "workflow" => "PostHog - BoringCache",
    "benchmark" => "posthog",
    "name" => "PostHog",
    "logo" => "posthog",
    "repo" => "PostHog/posthog",
    "step" => "Docker build (full stack)",
    "depot_repo" => "depot/benchmark-posthog"
  }
].freeze

def run_cmd(*args)
  stdout, stderr, status = Open3.capture3(*args)
  raise "Command failed: #{args.join(' ')}\n#{stderr}" unless status.success?

  stdout
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

def latest_successful_run_id(repo:, workflow_name:)
  output = run_cmd(
    "gh", "run", "list",
    "--repo", repo,
    "--workflow", workflow_name,
    "--status", "completed",
    "--limit", "10",
    "--json", "databaseId,conclusion"
  )
  runs = JSON.parse(output)
  run = runs.find { |item| item["conclusion"] == "success" }
  run && run["databaseId"]
end

def benchmark_artifact_name(run_id, benchmark_id)
  output = run_cmd("gh", "api", "repos/#{REPO}/actions/runs/#{run_id}/artifacts")
  artifacts = JSON.parse(output).fetch("artifacts", [])
  artifact = artifacts.find do |item|
    name = item["name"].to_s
    name.start_with?("benchmark-#{benchmark_id}-") && !item["expired"]
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

def parse_timestamp(value)
  return nil if value.nil?

  text = value.to_s
  return nil if text.empty? || text.start_with?("0001-01-01T")

  Time.parse(text)
rescue ArgumentError
  nil
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

def infer_depot_metrics(depot_repo)
  run_id = latest_successful_run_id(repo: depot_repo, workflow_name: "Benchmark")
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

def build_entry_from_payload(metadata, payload, depot_metrics: nil)
  runs = payload.fetch("runs", {})
  speed = payload.fetch("speed", {})
  stale = payload.fetch("stale_docker_cache", {})
  internal_only = payload.fetch("internal_only", {})

  cold = parse_number(runs["cold_seconds"])
  warm = parse_number(speed["warm_average_seconds"])
  warm ||= parse_number(runs["warm2_seconds"])
  warm ||= parse_number(runs["warm1_seconds"])

  faster = parse_number(speed["warm_vs_cold_improvement_pct"])
  faster ||= ((cold - warm) / cold) * 100.0 if cold && cold.positive? && warm

  return nil if cold.nil? || warm.nil? || faster.nil?

  entry = {
    "name" => metadata["name"],
    "logo" => metadata["logo"],
    "repo" => metadata["repo"],
    "step" => metadata["step"],
    "before" => seconds_to_text(cold),
    "after" => seconds_to_text(warm),
    "faster" => [faster.round, 0].max.to_s,
    "before_seconds" => cold.round(2),
    "after_seconds" => warm.round(2),
    "metrics" => {
      "stale_docker_seconds" => parse_number(runs["stale_docker_seconds"]) || parse_number(stale["seconds"]),
      "internal_only_warm_seconds" => parse_number(internal_only["warm_no_docker_cache_seconds"])
    }
  }

  if depot_metrics
    entry["depot"] = depot_metrics
    depot_docker = parse_number(depot_metrics["docker_seconds"])
    if depot_docker && depot_docker.positive?
      delta = depot_docker - warm
      entry["comparison"] = {
        "warm_vs_depot_docker_delta_seconds" => delta.round(2),
        "warm_vs_depot_docker_improvement_pct" => (((depot_docker - warm) / depot_docker) * 100.0).round(2)
      }
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
  BORINGCACHE_WORKFLOWS.each do |workflow|
    begin
      run_id = latest_successful_run_id(repo: REPO, workflow_name: workflow["workflow"])
      next unless run_id

      artifact_name = benchmark_artifact_name(run_id, workflow["benchmark"])
      next unless artifact_name

      artifact_dir = File.join(tmp, run_id.to_s)
      FileUtils.mkdir_p(artifact_dir)

      payload = download_artifact_json(run_id, artifact_name, artifact_dir)
      next unless payload

      depot_metrics = workflow["depot_repo"] ? infer_depot_metrics(workflow["depot_repo"]) : nil
      dynamic_entry = build_entry_from_payload(workflow, payload, depot_metrics: depot_metrics)
      next unless dynamic_entry

      entries_by_name[dynamic_entry["name"]] = dynamic_entry
    rescue StandardError => e
      warn "Skipping #{workflow['workflow']}: #{e.message}"
    end
  end
end

ordered_entries = DEFAULT_ENTRIES.map { |entry| entries_by_name[entry["name"]] }.compact
write_index(ordered_entries)
