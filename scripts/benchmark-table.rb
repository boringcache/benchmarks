#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "optparse"
require "time"
require "tmpdir"
require "yaml"
require_relative "benchmark-reporting"

BENCHMARK_ROOT = File.expand_path("..", __dir__)
DEFAULT_INDEX_PATH = File.join(BENCHMARK_ROOT, "data", "latest", "index.json")
DEFAULT_CACHE_DIR = ENV.fetch("BENCHMARK_TABLE_CACHE_DIR", File.join(Dir.tmpdir, "boringcache-benchmark-artifacts"))
MAX_GH_RETRIES = ENV.fetch("BENCHMARK_TABLE_GH_RETRIES", "3").to_i
LANES = %w[fresh rolling].freeze
STRATEGIES = %w[actions-cache boringcache].freeze

BENCHMARKS = [
  {
    "benchmark" => "hugo",
    "name" => "Hugo",
    "repo" => "gohugoio/hugo",
    "source_repo" => "boringcache/benchmark-hugo",
    "category" => "docker",
    "step" => "Docker build (Go)"
  },
  {
    "benchmark" => "hugo-go",
    "name" => "Hugo Go",
    "repo" => "gohugoio/hugo",
    "source_repo" => "boringcache/benchmark-hugo-go",
    "category" => "go",
    "step" => "Go build (native build cache)"
  },
  {
    "benchmark" => "immich",
    "name" => "Immich",
    "repo" => "immich-app/immich",
    "source_repo" => "boringcache/benchmark-immich",
    "category" => "docker",
    "step" => "Docker build (server)"
  },
  {
    "benchmark" => "mastodon-docker",
    "aliases" => ["mastodon"],
    "name" => "Mastodon",
    "repo" => "mastodon/mastodon",
    "source_repo" => "boringcache/benchmark-mastodon",
    "category" => "docker",
    "step" => "Docker build (Ruby+Node)"
  },
  {
    "benchmark" => "posthog",
    "name" => "PostHog",
    "repo" => "PostHog/posthog",
    "source_repo" => "boringcache/benchmark-posthog",
    "category" => "docker",
    "step" => "Docker build (full stack)"
  },
  {
    "benchmark" => "storybook",
    "name" => "Storybook",
    "repo" => "storybookjs/storybook",
    "source_repo" => "boringcache/benchmark-storybook",
    "category" => "nodejs",
    "step" => "Nx build (Yarn monorepo)"
  },
  {
    "benchmark" => "otel-gradle",
    "aliases" => ["otel", "opentelemetry", "opentelemetry-java"],
    "name" => "OpenTelemetry Java",
    "repo" => "open-telemetry/opentelemetry-java",
    "source_repo" => "boringcache/benchmark-opentelemetry-java",
    "category" => "gradle",
    "step" => "Gradle build (native HTTP cache)"
  },
  {
    "benchmark" => "spring-ai-maven",
    "aliases" => ["spring", "spring-ai"],
    "name" => "Spring AI",
    "repo" => "spring-projects/spring-ai",
    "source_repo" => "boringcache/benchmark-spring-ai",
    "category" => "maven",
    "step" => "Maven build (build-cache extension)"
  },
  {
    "benchmark" => "grpc-bazel",
    "aliases" => ["grpc", "gRPC"],
    "name" => "gRPC",
    "repo" => "grpc/grpc",
    "source_repo" => "boringcache/benchmark-grpc",
    "category" => "bazel",
    "step" => "Bazel build (remote cache)"
  },
  {
    "benchmark" => "zed-sccache",
    "aliases" => ["zed"],
    "name" => "Zed",
    "repo" => "zed-industries/zed",
    "source_repo" => "boringcache/benchmark-zed",
    "category" => "rust",
    "step" => "Rust build (sccache)"
  },
  {
    "benchmark" => "n8n",
    "name" => "n8n",
    "repo" => "n8n-io/n8n",
    "source_repo" => "boringcache/benchmark-n8n",
    "category" => "nodejs",
    "step" => "Turbo build (pnpm monorepo)"
  }
].freeze

BENCHMARK_BY_KEY = BENCHMARKS.each_with_object({}) do |benchmark, acc|
  ([benchmark.fetch("benchmark"), benchmark.fetch("name")] + Array(benchmark["aliases"])).each do |key|
    acc[key.to_s.downcase] = benchmark
  end
end

def parse_timestamp(value)
  return nil if value.nil? || value.to_s.empty?

  Time.parse(value.to_s)
rescue ArgumentError
  nil
end

def parse_number(value)
  return nil if value.nil? || value.to_s.empty?

  Float(value)
rescue ArgumentError, TypeError
  nil
end

def seconds_to_text(value)
  return "—" if value.nil?

  total = value.round
  minutes = total / 60
  seconds = total % 60
  "#{minutes}m #{seconds}s"
end

def seconds_to_detail_text(value)
  return "—" if value.nil?

  seconds = value.to_f
  return format("%.1fs", seconds) if seconds < 10 && seconds != seconds.round

  seconds_to_text(seconds)
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

def markdown_escape(value)
  value.to_s.gsub(/[|\r\n]/, "|" => "\\|", "\r" => " ", "\n" => "<br>")
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

def percent_delta(before_value, after_value)
  return nil if before_value.nil? || after_value.nil? || before_value <= 0

  ((before_value.to_f - after_value.to_f) / before_value.to_f) * 100.0
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

def storage_summary_text(comparison)
  saved_bytes = comparison["storage_saved_bytes"]
  improvement_pct = comparison["storage_improvement_pct"]
  return "—" if saved_bytes.nil?

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

def lane_label(lane)
  lane.to_s == "rolling" ? "Rolling" : "Fresh"
end

def first_build_label(lane)
  lane.to_s == "rolling" ? "Commit build" : "Cold build"
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

def run_cmd(*args)
  attempts = 0

  begin
    stdout, stderr, status = Open3.capture3(*args)
    raise "Command failed: #{args.join(' ')}\n#{stderr}" unless status.success?

    stdout
  rescue StandardError
    attempts += 1
    if args.first == "gh" && attempts < [MAX_GH_RETRIES, 1].max
      sleep(attempts * 2)
      retry
    end
    raise
  end
end

def benchmark_for(value)
  benchmark = BENCHMARK_BY_KEY[value.to_s.downcase]
  raise ArgumentError, "Unknown benchmark #{value.inspect}. Use --list-benchmarks." unless benchmark

  benchmark
end

def parse_lane(value)
  lane = value.to_s.downcase
  raise ArgumentError, "Unsupported lane #{value.inspect}; expected fresh or rolling" unless LANES.include?(lane)

  lane
end

def parse_strategy(value)
  strategy = value.to_s.downcase
  strategy = "actions-cache" if strategy == "ac" || strategy == "actions"
  strategy = "boringcache" if strategy == "bc"
  raise ArgumentError, "Unsupported strategy #{value.inspect}; expected actions-cache or boringcache" unless STRATEGIES.include?(strategy)

  strategy
end

def duration_seconds(started_at:, completed_at:)
  started = parse_timestamp(started_at)
  completed = parse_timestamp(completed_at)
  return nil unless started && completed && completed >= started

  completed - started
end

def run_total_seconds(run)
  jobs = Array(run["jobs"])
  return nil if jobs.empty?

  jobs.map do |job|
    duration_seconds(
      started_at: job["startedAt"] || job["started_at"],
      completed_at: job["completedAt"] || job["completed_at"]
    )
  end.compact.max
end

def fetch_run(repo:, run_id:)
  run = JSON.parse(
    run_cmd(
      "gh", "api",
      "repos/#{repo}/actions/runs/#{run_id}"
    )
  )
  jobs = JSON.parse(
    run_cmd(
      "gh", "api",
      "repos/#{repo}/actions/runs/#{run_id}/jobs?per_page=100"
    )
  ).fetch("jobs", [])

  {
    "databaseId" => run["id"],
    "conclusion" => run["conclusion"],
    "status" => run["status"],
    "url" => run["html_url"],
    "jobs" => jobs,
    "createdAt" => run["run_started_at"] || run["created_at"],
    "updatedAt" => run["updated_at"],
    "headSha" => run["head_sha"]
  }
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

def artifact_name_for_run(repo:, run_id:, benchmark_id:, strategy:, lane:)
  output = run_cmd("gh", "api", "repos/#{repo}/actions/runs/#{run_id}/artifacts")
  artifacts = JSON.parse(output).fetch("artifacts", [])
  candidate_names = lane_artifact_names(benchmark_id: benchmark_id, strategy: strategy, lane: lane)

  artifact = artifacts.find do |item|
    !item["expired"] && candidate_names.include?(item["name"].to_s)
  end

  artifact && artifact["name"]
end

def download_artifact_payload(repo:, run_id:, artifact_name:, cache_dir:)
  target_dir = File.join(cache_dir, repo.tr("/", "__"), run_id.to_s, artifact_name)
  FileUtils.mkdir_p(target_dir)

  unless Dir.glob(File.join(target_dir, "**", "*.json")).any?
    run_cmd(
      "gh", "run", "download", run_id.to_s,
      "--repo", repo,
      "-n", artifact_name,
      "--dir", target_dir
    )
  end

  json_files = Dir.glob(File.join(target_dir, "**", "*.json")).sort
  expected_summary = "#{artifact_name.sub(/\Abenchmark-/, "")}.json"
  json_file = json_files.find { |path| File.basename(path) == expected_summary }
  json_file ||= json_files.find { |path| !File.basename(path).include?("phase-breakdown") }
  json_file ||= json_files.first
  raise "No JSON files found in downloaded artifact #{artifact_name} for #{repo} run #{run_id}" unless json_file

  JSON.parse(File.read(json_file))
end

def download_strategy_data(benchmark:, lane:, strategy:, run_id:, cache_dir:)
  repo = benchmark.fetch("source_repo")
  run = fetch_run(repo: repo, run_id: run_id)
  artifact_name = artifact_name_for_run(
    repo: repo,
    run_id: run_id,
    benchmark_id: benchmark_artifact_ids(benchmark),
    strategy: strategy,
    lane: lane
  )
  raise "No #{strategy} #{lane} artifact found for #{repo} run #{run_id}" unless artifact_name

  payload = download_artifact_payload(repo: repo, run_id: run_id, artifact_name: artifact_name, cache_dir: cache_dir)
  strategy_data_from_payload(payload, run: run, run_total_seconds: run_total_seconds(run))
end

def extract_strategy_metrics(payload)
  runs = payload.fetch("runs", {})
  speed = payload.fetch("speed", {})
  cache = payload.fetch("cache", {})
  docker_cache = payload.fetch("docker_cache", {})
  oci = payload.fetch("oci", {})
  classification = payload.fetch("classification", {})

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
    oci: oci,
    classification: classification
  }
end

def strategy_data_from_payload(payload, run: nil, run_total_seconds: nil, source_path: nil)
  benchmark = benchmark_for(payload.fetch("benchmark"))
  lane = parse_lane(payload["lane"].to_s.empty? ? "fresh" : payload.fetch("lane"))
  strategy = parse_strategy(payload.fetch("strategy"))
  run ||= {
    "databaseId" => nil,
    "url" => nil,
    "headSha" => payload.dig("project", "ref"),
    "createdAt" => payload["generated_at"],
    "conclusion" => nil,
    "status" => nil
  }

  {
    benchmark: benchmark,
    lane: lane,
    strategy: strategy,
    run: run,
    run_total_seconds: run_total_seconds,
    metrics: extract_strategy_metrics(payload),
    source_path: source_path
  }
end

def latest_payloads_from_dir(dir)
  Dir.glob(File.join(dir, "**", "*.json")).map do |path|
    payload = JSON.parse(File.read(path))
    next unless payload["benchmark"] && payload["strategy"]

    strategy_data_from_payload(payload, source_path: path)
  rescue JSON::ParserError, KeyError, ArgumentError => e
    warn "Skipping #{path}: #{e.message}"
    nil
  end.compact
end

def pick_latest_strategy_data(items)
  items.max_by do |item|
    run_created = parse_timestamp(item.dig(:run, "createdAt"))
    source_mtime = item[:source_path] && File.exist?(item[:source_path]) ? File.mtime(item[:source_path]) : nil
    run_created || source_mtime || Time.at(0)
  end
end

def pair_strategy_data(items)
  grouped = items.group_by { |item| [item.fetch(:benchmark).fetch("benchmark"), item.fetch(:lane), item.fetch(:strategy)] }
  pairs = {}

  BENCHMARKS.each do |benchmark|
    LANES.each do |lane|
      actions_data = pick_latest_strategy_data(grouped[[benchmark.fetch("benchmark"), lane, "actions-cache"]] || [])
      boringcache_data = pick_latest_strategy_data(grouped[[benchmark.fetch("benchmark"), lane, "boringcache"]] || [])
      next unless actions_data && boringcache_data

      pairs[[benchmark.fetch("benchmark"), lane]] = [actions_data, boringcache_data]
    end
  end

  pairs
end

def strategy_snapshot(data)
  metrics = data.fetch(:metrics)
  run = data.fetch(:run)

  {
    "run_id" => run["databaseId"],
    "run_url" => run["url"],
    "head_sha" => run["headSha"],
    "created_at" => run["createdAt"],
    "status" => run["status"],
    "conclusion" => run["conclusion"],
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
    "oci" => metrics[:oci],
    "classification" => metrics[:classification]
  }
end

def headline_candidates(actions_metrics:, boringcache_metrics:)
  [
    ["warm", warm_build_steady_seconds(actions_metrics), warm_build_steady_seconds(boringcache_metrics)],
    ["cold", first_build_seconds(actions_metrics), first_build_seconds(boringcache_metrics)]
  ].select { |_, before_value, after_value| before_value && after_value }
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

  candidates.find { |scenario, _, _| scenario == "cold" } || candidates.first
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

def build_entry(benchmark:, lane:, actions_data:, boringcache_data:)
  actions_metrics = actions_data.fetch(:metrics)
  boringcache_metrics = boringcache_data.fetch(:metrics)
  actions_head = actions_data.dig(:run, "headSha").to_s
  boringcache_head = boringcache_data.dig(:run, "headSha").to_s
  paired_head = !actions_head.empty? && actions_head == boringcache_head
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
  return nil unless headline

  headline_scenario, before_value, after_value = headline
  faster_pct = [percent_delta(before_value, after_value).to_f, 0].max

  {
    "lane" => lane,
    "lane_label" => lane_label(lane),
    "first_build_label" => first_build_label(lane),
    "benchmark" => benchmark.fetch("benchmark"),
    "name" => benchmark.fetch("name"),
    "repo" => benchmark.fetch("repo"),
    "source_repo" => benchmark.fetch("source_repo"),
    "category" => benchmark.fetch("category"),
    "step" => benchmark.fetch("step"),
    "headline_scenario" => reporting["headline_scenario"] || headline_scenario,
    "headline_label" => reporting["headline_label"] || BenchmarkReporting.headline_label(lane: lane, scenario: reporting["headline_scenario"] || headline_scenario),
    "before" => seconds_to_text(before_value),
    "after" => seconds_to_text(after_value),
    "before_seconds" => before_value.round(2),
    "after_seconds" => after_value.round(2),
    "faster" => reporting["comparative"] ? faster_pct.round.to_s : nil,
    "comparison" => {
      "paired_on_head_sha" => paired_head,
      "pairing_head_sha" => paired_head ? actions_head : nil,
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
      "storage_improvement_pct" => percent_delta(actions_metrics[:storage_bytes], boringcache_metrics[:storage_bytes])&.round(2),
      "storage_saved_bytes" => if actions_metrics[:storage_bytes] && boringcache_metrics[:storage_bytes]
        actions_metrics[:storage_bytes] - boringcache_metrics[:storage_bytes]
      end
    }
  }
end

def merge_lane_entries(entries)
  entries.group_by { |entry| entry.fetch("benchmark") }.map do |benchmark_id, benchmark_entries|
    by_lane = benchmark_entries.to_h { |entry| [entry.fetch("lane"), entry] }
    default_lane = by_lane.key?("fresh") ? "fresh" : by_lane.keys.first
    default_entry = JSON.parse(JSON.generate(by_lane.fetch(default_lane)))
    default_entry["default_lane"] = default_lane
    default_entry["available_lanes"] = by_lane.keys
    default_entry["lanes"] = by_lane.transform_values { |entry| JSON.parse(JSON.generate(entry)) }
    default_entry
  end.compact.sort_by do |entry|
    benchmark_id = entry.fetch("benchmark")
    BENCHMARKS.index { |benchmark| benchmark.fetch("benchmark") == benchmark_id } || 999
  end
end

def lane_entry(entry, lane)
  entry.dig("lanes", lane) || (entry["lane"] == lane ? entry : nil)
end

def lane_report_row(entry, lane)
  current = lane_entry(entry, lane)
  return nil unless current

  comparison = current.fetch("comparison", {})
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

  {
    benchmark: entry.fetch("name"),
    scenario: current["headline_label"] || reporting["headline_label"] || BenchmarkReporting.headline_label(lane: lane, scenario: current["headline_scenario"]),
    actions: current["before"],
    boringcache: current["after"],
    result: reporting.fetch("comparative", true) ? timing_result_text(current["before_seconds"], current["after_seconds"]) : reporting["result_text"],
    storage: storage_summary_text(comparison)
  }
end

def coverage_summary(entries)
  total = entries.length
  fresh = entries.count { |entry| lane_entry(entry, "fresh") }
  rolling = entries.count { |entry| lane_entry(entry, "rolling") }

  if fresh == total && rolling == total
    "Coverage: #{total} benchmarks, with fresh and rolling lanes available for all."
  else
    "Coverage: #{total} benchmarks; fresh #{fresh}/#{total}, rolling #{rolling}/#{total}."
  end
end

def raw_row(entry, lane)
  current = lane_entry(entry, lane)
  return nil unless current

  comparison = current.fetch("comparison", {})
  actions = comparison.fetch("actions_cache", {})
  boringcache = comparison.fetch("boringcache", {})
  [
    entry.fetch("name"),
    seconds_to_text(actions["cold_seconds"]),
    seconds_to_text(boringcache["cold_seconds"]),
    seconds_to_text(actions["warm_steady_seconds"]),
    seconds_to_text(boringcache["warm_steady_seconds"]),
    bytes_to_text(actions["storage_bytes"]),
    bytes_to_text(boringcache["storage_bytes"]),
    actions["run_id"] || "—",
    boringcache["run_id"] || "—"
  ]
end

def docker_detail_row(entry, lane)
  current = lane_entry(entry, lane)
  return nil unless current

  comparison = current.fetch("comparison", {})
  actions = comparison.fetch("actions_cache", {})
  boringcache = comparison.fetch("boringcache", {})
  return nil unless [actions["docker_cache_import_seconds"], actions["docker_cache_export_seconds"], boringcache["docker_cache_import_seconds"], boringcache["docker_cache_export_seconds"]].compact.any?

  [
    entry.fetch("name"),
    lane,
    seconds_to_detail_text(actions["docker_cache_import_seconds"]),
    seconds_to_detail_text(boringcache["docker_cache_import_seconds"]),
    seconds_to_detail_text(actions["docker_cache_export_seconds"]),
    seconds_to_detail_text(boringcache["docker_cache_export_seconds"]),
    (boringcache.dig("oci", "hydration_policy") || "—"),
    (boringcache["http_transport"] || "—"),
    (boringcache["oci_stream_through_min_bytes"] || "—").to_s,
    (boringcache.dig("oci", "new_blob_count") || "—").to_s,
    bytes_to_text(boringcache.dig("oci", "new_blob_bytes")),
    bytes_to_text(boringcache.dig("oci", "body_remote_bytes"))
  ]
end

def build_markdown(entries, generated_at:, format:)
  generated_label = Time.parse(generated_at).utc.strftime("%Y-%m-%d %H:%M UTC")
  sections = [
    "## Benchmark Numbers",
    "",
    "Generated: #{generated_label}",
    ""
  ]

  if %w[summary both].include?(format)
    sections += [coverage_summary(entries), ""]

    LANES.each do |lane|
      rows = entries.map { |entry| lane_report_row(entry, lane) }.compact
      next if rows.empty?

      sections += [
        "### #{lane_label(lane).split.map(&:capitalize).join(' ')}",
        "",
        markdown_table(
          ["Benchmark", "Metric", "GitHub Actions Cache", "BoringCache", "Result", "Storage"],
          rows.map { |row| [row[:benchmark], row[:scenario], row[:actions], row[:boringcache], row[:result], row[:storage]] }
        ),
        ""
      ]
    end
  end

  if %w[raw both].include?(format)
    LANES.each do |lane|
      rows = entries.map { |entry| raw_row(entry, lane) }.compact
      next if rows.empty?

      sections += [
        "### #{lane_label(lane).split.map(&:capitalize).join(' ')} Raw",
        "",
        markdown_table(
          ["Benchmark", "GitHub Actions Cache Cold/Commit Build", "BoringCache Cold/Commit Build", "GitHub Actions Cache Warm Build", "BoringCache Warm Build", "GitHub Actions Cache Storage", "BoringCache Storage", "GitHub Actions Cache Run", "BoringCache Run"],
          rows
        ),
        ""
      ]
    end

    docker_rows = LANES.flat_map { |lane| entries.map { |entry| docker_detail_row(entry, lane) }.compact }
    if docker_rows.any?
      sections += [
        "### Docker Cache Detail",
        "",
        markdown_table(["Benchmark", "Lane", "GitHub Actions Cache Import", "BoringCache Import", "GitHub Actions Cache Export", "BoringCache Export", "BoringCache OCI Hydration", "BoringCache HTTP", "BoringCache Stream Min Bytes", "BoringCache New Blobs", "BoringCache New Blob Bytes", "BoringCache Remote Body Bytes"], docker_rows),
        ""
      ]
    end
  end

  sections.join("\n").rstrip + "\n"
end

def load_index_entries(path)
  payload = JSON.parse(File.read(path))
  Array(payload.fetch("entries"))
end

def parse_pair_spec(spec)
  benchmark_key, lane_value, actions_run, boringcache_run = spec.to_s.split(":", 4)
  raise ArgumentError, "Invalid --pair #{spec.inspect}; expected benchmark:lane:actions_run_id:boringcache_run_id" if [benchmark_key, lane_value, actions_run, boringcache_run].any?(&:nil?)

  {
    benchmark: benchmark_for(benchmark_key),
    lane: parse_lane(lane_value),
    actions_run: actions_run,
    boringcache_run: boringcache_run
  }
end

def parse_run_spec(spec)
  benchmark_key, lane_value, strategy_value, run_id = spec.to_s.split(":", 4)
  raise ArgumentError, "Invalid --run #{spec.inspect}; expected benchmark:lane:strategy:run_id" if [benchmark_key, lane_value, strategy_value, run_id].any?(&:nil?)

  {
    benchmark: benchmark_for(benchmark_key),
    lane: parse_lane(lane_value),
    strategy: parse_strategy(strategy_value),
    run_id: run_id
  }
end

def load_cohort_file(path)
  payload = if [".yml", ".yaml"].include?(File.extname(path).downcase)
    YAML.safe_load(File.read(path), permitted_classes: [Time, Symbol], aliases: true)
  else
    JSON.parse(File.read(path))
  end

  pairs = Array(payload["pairs"]).map do |item|
    {
      benchmark: benchmark_for(item.fetch("benchmark")),
      lane: parse_lane(item["lane"] || "fresh"),
      actions_run: item["actions_cache"] || item["actions_run"] || item["ac"],
      boringcache_run: item["boringcache"] || item["boringcache_run"] || item["bc"]
    }
  end

  runs = Array(payload["runs"]).map do |item|
    {
      benchmark: benchmark_for(item.fetch("benchmark")),
      lane: parse_lane(item["lane"] || "fresh"),
      strategy: parse_strategy(item.fetch("strategy")),
      run_id: item.fetch("run_id")
    }
  end

  [pairs, runs]
end

options = {
  source: :latest,
  index_path: DEFAULT_INDEX_PATH,
  artifact_dirs: [],
  pairs: [],
  runs: [],
  format: "both",
  cache_dir: DEFAULT_CACHE_DIR,
  output_md: nil,
  output_json: nil
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on("--latest", "Read #{DEFAULT_INDEX_PATH} (default)") do
    options[:source] = :latest
  end

  opts.on("--index PATH", "Read an aggregate benchmark index JSON") do |path|
    options[:source] = :latest
    options[:index_path] = path
  end

  opts.on("--artifacts DIR", "Read downloaded benchmark artifact JSON files from DIR") do |dir|
    options[:source] = :artifacts
    options[:artifact_dirs] << dir
  end

  opts.on("--pair SPEC", "Download one pair: benchmark:lane:actions_run_id:boringcache_run_id") do |spec|
    options[:source] = :runs
    options[:pairs] << parse_pair_spec(spec)
  end

  opts.on("--run SPEC", "Download one run: benchmark:lane:strategy:run_id") do |spec|
    options[:source] = :runs
    options[:runs] << parse_run_spec(spec)
  end

  opts.on("--cohort PATH", "Read JSON/YAML with pairs/runs arrays") do |path|
    options[:source] = :runs
    pairs, runs = load_cohort_file(path)
    options[:pairs].concat(pairs)
    options[:runs].concat(runs)
  end

  opts.on("--format FORMAT", "summary, raw, or both (default: both)") do |format|
    options[:format] = format
  end

  opts.on("--cache-dir DIR", "Artifact download cache (default: #{DEFAULT_CACHE_DIR})") do |dir|
    options[:cache_dir] = dir
  end

  opts.on("--output-md PATH", "Write markdown report to PATH") do |path|
    options[:output_md] = path
  end

  opts.on("--output-json PATH", "Write normalized entries JSON to PATH") do |path|
    options[:output_json] = path
  end

  opts.on("--list-benchmarks", "Print supported benchmark ids and exit") do
    BENCHMARKS.each do |benchmark|
      aliases = Array(benchmark["aliases"])
      suffix = aliases.empty? ? "" : " (aliases: #{aliases.join(', ')})"
      puts "#{benchmark.fetch('benchmark')} - #{benchmark.fetch('name')}#{suffix}"
    end
    exit 0
  end
end

parser.parse!

unless %w[summary raw both].include?(options[:format])
  raise ArgumentError, "Unsupported --format #{options[:format].inspect}; expected summary, raw, or both"
end

entries = case options[:source]
when :latest
  load_index_entries(options.fetch(:index_path))
when :artifacts
  raise ArgumentError, "--artifacts requires at least one directory" if options[:artifact_dirs].empty?

  data = options[:artifact_dirs].flat_map { |dir| latest_payloads_from_dir(dir) }
  merge_lane_entries(
    pair_strategy_data(data).map do |(benchmark_id, lane), (actions_data, boringcache_data)|
      build_entry(
        benchmark: benchmark_for(benchmark_id),
        lane: lane,
        actions_data: actions_data,
        boringcache_data: boringcache_data
      )
    end.compact
  )
when :runs
  data = []

  options[:pairs].each do |pair|
    data << download_strategy_data(
      benchmark: pair.fetch(:benchmark),
      lane: pair.fetch(:lane),
      strategy: "actions-cache",
      run_id: pair.fetch(:actions_run),
      cache_dir: options.fetch(:cache_dir)
    )
    data << download_strategy_data(
      benchmark: pair.fetch(:benchmark),
      lane: pair.fetch(:lane),
      strategy: "boringcache",
      run_id: pair.fetch(:boringcache_run),
      cache_dir: options.fetch(:cache_dir)
    )
  end

  options[:runs].each do |run|
    data << download_strategy_data(
      benchmark: run.fetch(:benchmark),
      lane: run.fetch(:lane),
      strategy: run.fetch(:strategy),
      run_id: run.fetch(:run_id),
      cache_dir: options.fetch(:cache_dir)
    )
  end

  merge_lane_entries(
    pair_strategy_data(data).map do |(benchmark_id, lane), (actions_data, boringcache_data)|
      build_entry(
        benchmark: benchmark_for(benchmark_id),
        lane: lane,
        actions_data: actions_data,
        boringcache_data: boringcache_data
      )
    end.compact
  )
else
  raise "Unsupported source #{options[:source].inspect}"
end

generated_at = Time.now.utc.iso8601
payload = {
  "generated_at" => generated_at,
  "entries" => entries
}
markdown = build_markdown(entries, generated_at: generated_at, format: options.fetch(:format))

if options[:output_json]
  FileUtils.mkdir_p(File.dirname(options[:output_json]))
  File.write(options[:output_json], JSON.pretty_generate(payload) + "\n")
end

if options[:output_md]
  FileUtils.mkdir_p(File.dirname(options[:output_md]))
  File.write(options[:output_md], markdown)
else
  puts markdown
end
