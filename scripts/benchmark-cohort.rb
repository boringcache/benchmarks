#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "optparse"
require "tempfile"
require "time"
require "tmpdir"

BENCHMARK_ROOT = File.expand_path("..", __dir__)
TABLE_SCRIPT = File.join(BENCHMARK_ROOT, "scripts", "benchmark-table.rb")
DEFAULT_CACHE_DIR = ENV.fetch("BENCHMARK_TABLE_CACHE_DIR", File.join(Dir.tmpdir, "boringcache-benchmark-artifacts"))
MAX_GH_RETRIES = ENV.fetch("BENCHMARK_COHORT_GH_RETRIES", "3").to_i
LANES = %w[fresh rolling].freeze

BENCHMARKS = [
  {
    "benchmark" => "hugo",
    "name" => "Hugo",
    "repo" => "boringcache/benchmark-hugo",
    "category" => "docker",
    "workflow" => "hugo-benchmark.yml"
  },
  {
    "benchmark" => "hugo-go",
    "name" => "Hugo Go",
    "repo" => "boringcache/benchmark-hugo-go",
    "category" => "go",
    "workflow" => "hugo-go-benchmark.yml"
  },
  {
    "benchmark" => "immich",
    "name" => "Immich",
    "repo" => "boringcache/benchmark-immich",
    "category" => "docker",
    "workflow" => "immich-benchmark.yml"
  },
  {
    "benchmark" => "mastodon-docker",
    "aliases" => ["mastodon"],
    "name" => "Mastodon",
    "repo" => "boringcache/benchmark-mastodon",
    "category" => "docker",
    "workflow" => "mastodon-docker-benchmark.yml"
  },
  {
    "benchmark" => "mastodon-streaming",
    "name" => "Mastodon Streaming",
    "repo" => "boringcache/benchmark-mastodon",
    "category" => "docker",
    "workflow" => "mastodon-streaming-docker-benchmark.yml"
  },
  {
    "benchmark" => "discourse-docker-amd64",
    "aliases" => ["discourse", "discourse-docker"],
    "name" => "Discourse Docker (amd64)",
    "repo" => "boringcache/discourse_docker",
    "category" => "docker",
    "workflow" => "build.yml"
  },
  {
    "benchmark" => "discourse-docker-arm64",
    "aliases" => ["discourse-arm64"],
    "name" => "Discourse Docker (arm64)",
    "repo" => "boringcache/discourse_docker",
    "category" => "docker",
    "workflow" => "build.yml"
  },
  {
    "benchmark" => "posthog",
    "name" => "PostHog",
    "repo" => "boringcache/benchmark-posthog",
    "category" => "docker",
    "workflow" => "posthog-benchmark.yml"
  },
  {
    "benchmark" => "storybook",
    "name" => "Storybook",
    "repo" => "boringcache/benchmark-storybook",
    "category" => "nodejs",
    "workflow" => "storybook-benchmark.yml"
  },
  {
    "benchmark" => "otel-gradle",
    "aliases" => ["otel", "opentelemetry", "opentelemetry-java"],
    "name" => "OpenTelemetry Java",
    "repo" => "boringcache/benchmark-opentelemetry-java",
    "category" => "gradle",
    "workflow" => "opentelemetry-java-gradle-benchmark.yml"
  },
  {
    "benchmark" => "spring-ai-maven",
    "aliases" => ["spring", "spring-ai"],
    "name" => "Spring AI",
    "repo" => "boringcache/benchmark-spring-ai",
    "category" => "maven",
    "workflow" => "spring-ai-maven-benchmark.yml"
  },
  {
    "benchmark" => "grpc-bazel",
    "aliases" => ["grpc", "gRPC"],
    "name" => "gRPC",
    "repo" => "boringcache/benchmark-grpc",
    "category" => "bazel",
    "workflow" => "grpc-bazel-benchmark.yml"
  },
  {
    "benchmark" => "zed-cargo",
    "aliases" => ["zed", "zed-sccache"],
    "name" => "Zed",
    "repo" => "boringcache/benchmark-zed",
    "category" => "rust",
    "workflow" => "zed-cargo-product.yml"
  },
  {
    "benchmark" => "deno-cargo",
    "aliases" => ["deno"],
    "name" => "Deno",
    "repo" => "boringcache/benchmark-deno",
    "category" => "rust",
    "workflow" => "deno-cargo-product.yml"
  },
  {
    "benchmark" => "duckgres",
    "name" => "Duckgres",
    "repo" => "boringcache/benchmark-duckgres",
    "category" => "docker",
    "workflow" => "duckgres-benchmark.yml"
  },
  {
    "benchmark" => "chroma",
    "name" => "Chroma",
    "repo" => "boringcache/benchmark-chroma",
    "category" => "docker",
    "workflow" => "chroma-benchmark.yml"
  },
  {
    "benchmark" => "linkerd2-v2",
    "aliases" => ["linkerd", "linkerd2", "linkerd2-web"],
    "name" => "Linkerd2 Web",
    "repo" => "boringcache/benchmark-linkerd2",
    "category" => "docker",
    "workflow" => "linkerd2-benchmark.yml"
  },
  {
    "benchmark" => "qdrant",
    "name" => "Qdrant",
    "repo" => "boringcache/benchmark-qdrant",
    "category" => "docker",
    "workflow" => "qdrant-benchmark.yml"
  },
  {
    "benchmark" => "n8n",
    "name" => "n8n",
    "repo" => "boringcache/benchmark-n8n",
    "category" => "nodejs",
    "workflow" => "n8n-benchmark.yml"
  },
  {
    "benchmark" => "n8n-docker",
    "name" => "n8n Docker",
    "repo" => "boringcache/benchmark-n8n",
    "category" => "docker",
    "workflow" => "n8n-docker-benchmark.yml"
  },
  {
    "benchmark" => "n8n-runners",
    "name" => "n8n Runners",
    "repo" => "boringcache/benchmark-n8n",
    "category" => "docker",
    "workflow" => "n8n-docker-benchmark.yml"
  },
  {
    "benchmark" => "n8n-runners-distroless",
    "name" => "n8n Runners Distroless",
    "repo" => "boringcache/benchmark-n8n",
    "category" => "docker",
    "workflow" => "n8n-docker-benchmark.yml"
  }
].freeze

BENCHMARK_BY_KEY = BENCHMARKS.each_with_object({}) do |benchmark, acc|
  ([benchmark.fetch("benchmark"), benchmark.fetch("name")] + Array(benchmark["aliases"])).each do |key|
    acc[key.to_s.downcase] = benchmark
  end
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

def parse_time(value)
  Time.parse(value.to_s)
rescue ArgumentError
  Time.at(0)
end

def lane_for(run)
  title = run["displayTitle"].to_s.downcase
  return "rolling" if title.include?("rolling")
  return "fresh" if title.include?("fresh")

  nil
end

def latest_successful_runs(repo:, workflow:, limit:)
  JSON.parse(
    run_cmd(
      "gh", "run", "list",
      "--repo", repo,
      "--workflow", workflow,
      "--limit", limit.to_s,
      "--json", "databaseId,displayTitle,workflowName,status,conclusion,createdAt,updatedAt,headSha,url"
    )
  ).select { |run| run["conclusion"] == "success" }
end

def latest_by_head(runs, lane)
  runs.each_with_object({}) do |run, acc|
    next unless lane_for(run) == lane

    head = run["headSha"].to_s
    next if head.empty?

    existing = acc[head]
    acc[head] = run if existing.nil? || parse_time(run["createdAt"]) > parse_time(existing["createdAt"])
  end
end

def benchmark_for(key)
  benchmark = BENCHMARK_BY_KEY[key.to_s.downcase]
  raise ArgumentError, "Unknown benchmark #{key.inspect}" unless benchmark

  benchmark
end

def select_benchmarks(keys)
  return BENCHMARKS if keys.empty?

  keys.map { |key| benchmark_for(key) }.uniq { |benchmark| benchmark.fetch("benchmark") }
end

def build_cohort(benchmarks:, lanes:, pairs_per_lane:, run_limit:)
  pairs = []
  summary = []

  benchmarks.each do |benchmark|
    workflow = benchmark.fetch("workflow")
    actions_runs = latest_successful_runs(
      repo: benchmark.fetch("repo"),
      workflow: workflow,
      limit: run_limit
    )
    boringcache_runs = latest_successful_runs(
      repo: benchmark.fetch("repo"),
      workflow: workflow,
      limit: run_limit
    )

    lanes.each do |lane|
      actions_by_head = latest_by_head(actions_runs, lane)
      boringcache_by_head = latest_by_head(boringcache_runs, lane)
      paired_heads = (actions_by_head.keys & boringcache_by_head.keys).sort_by do |head|
        [
          parse_time(actions_by_head.fetch(head)["createdAt"]),
          parse_time(boringcache_by_head.fetch(head)["createdAt"])
        ].max
      end.reverse
      selected_heads = paired_heads.first(pairs_per_lane)

      summary << {
        "benchmark" => benchmark.fetch("benchmark"),
        "name" => benchmark.fetch("name"),
        "lane" => lane,
        "available_pairs" => paired_heads.length,
        "selected_pairs" => selected_heads.length,
        "heads" => selected_heads
      }

      selected_heads.each do |head|
        actions_run = actions_by_head.fetch(head)
        boringcache_run = boringcache_by_head.fetch(head)
        pairs << {
          "benchmark" => benchmark.fetch("benchmark"),
          "name" => benchmark.fetch("name"),
          "category" => benchmark.fetch("category"),
          "lane" => lane,
          "head_sha" => head,
          "actions_cache" => actions_run.fetch("databaseId"),
          "boringcache" => boringcache_run.fetch("databaseId"),
          "actions_url" => actions_run.fetch("url"),
          "boringcache_url" => boringcache_run.fetch("url"),
          "actions_title" => actions_run.fetch("displayTitle"),
          "boringcache_title" => boringcache_run.fetch("displayTitle")
        }
      end
    end
  end

  {
    "generated_at" => Time.now.utc.iso8601,
    "pairs_per_lane" => pairs_per_lane,
    "run_history_limit" => run_limit,
    "pairs" => pairs,
    "summary" => summary
  }
end

def write_json(path, payload)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, JSON.pretty_generate(payload) + "\n")
end

def percent_delta(before_value, after_value)
  return nil if before_value.nil? || after_value.nil? || before_value.to_f.zero?

  ((before_value.to_f - after_value.to_f) / before_value.to_f) * 100.0
end

def average(values)
  values = values.compact
  return nil if values.empty?

  values.sum.to_f / values.length
end

def seconds_text(value)
  return "—" if value.nil?

  total = value.round
  "#{total / 60}m #{total % 60}s"
end

def bytes_text(value)
  return "—" if value.nil?

  units = %w[B KB MB GB TB]
  size = value.to_f.abs
  unit = 0
  while size >= 1024.0 && unit < units.length - 1
    size /= 1024.0
    unit += 1
  end
  suffix = value.to_f.negative? ? " more" : ""
  format("%.2f %s%s", size, units.fetch(unit), suffix)
end

def result_text(before_value, after_value)
  delta = percent_delta(before_value, after_value)
  return "—" if delta.nil?

  longest = [before_value.to_f, after_value.to_f].max
  delta_seconds = (before_value.to_f - after_value.to_f).abs
  return "near tie" if delta_seconds <= 5 && longest <= 60
  return "near tie" if delta.abs < 3.0

  delta.positive? ? "#{delta.round}% faster" : "#{delta.abs.round}% slower"
end

def rolling_bootstrap_investigation?(row)
  row.dig("reporting", "status") == "investigation_only"
end

def invalid_sample?(row)
  row.dig("reporting", "status") == "invalid"
end

def most_common(values)
  values = values.compact.reject { |value| value.to_s.empty? }
  return nil if values.empty?

  values.group_by(&:itself).max_by { |_, grouped| grouped.length }&.first
end

def markdown_table(headers, rows)
  lines = []
  lines << "| #{headers.join(' | ')} |"
  lines << "| #{headers.map { '---' }.join(' | ')} |"
  rows.each { |row| lines << "| #{row.join(' | ')} |" }
  lines.join("\n")
end

def normalize_pair(pair, cache_dir)
  Tempfile.create(["benchmark-pair-", ".json"]) do |json_file|
    Tempfile.create(["benchmark-pair-", ".md"]) do |md_file|
      spec = [
        pair.fetch("benchmark"),
        pair.fetch("lane"),
        pair.fetch("actions_cache"),
        pair.fetch("boringcache")
      ].join(":")
      run_cmd(
        "ruby", TABLE_SCRIPT,
        "--pair", spec,
        "--format", "raw",
        "--cache-dir", cache_dir,
        "--output-json", json_file.path,
        "--output-md", md_file.path
      )
      payload = JSON.parse(File.read(json_file.path))
      entry = payload.fetch("entries").first
      lane_entry = entry.dig("lanes", pair.fetch("lane")) || entry
      pair.merge("entry" => lane_entry)
    end
  end
end

def metric(snapshot, key)
  snapshot && snapshot[key]
end

def aggregate_pairs(pairs)
  pairs.group_by { |pair| [pair.fetch("benchmark"), pair.fetch("lane")] }.map do |(benchmark_id, lane), grouped|
    first = grouped.first
    entries = grouped.map { |pair| pair.fetch("entry") }
    actions = entries.map { |entry| entry.dig("comparison", "actions_cache") }
    boringcache = entries.map { |entry| entry.dig("comparison", "boringcache") }

    ac_cold = average(actions.map { |snapshot| metric(snapshot, "cold_seconds") })
    bc_cold = average(boringcache.map { |snapshot| metric(snapshot, "cold_seconds") })
    ac_warm = average(actions.map { |snapshot| metric(snapshot, "warm_steady_seconds") })
    bc_warm = average(boringcache.map { |snapshot| metric(snapshot, "warm_steady_seconds") })
    ac_storage = average(actions.map { |snapshot| metric(snapshot, "storage_bytes") })
    bc_storage = average(boringcache.map { |snapshot| metric(snapshot, "storage_bytes") })
    ac_export = average(actions.map { |snapshot| metric(snapshot, "docker_cache_export_seconds") })
    bc_export = average(boringcache.map { |snapshot| metric(snapshot, "docker_cache_export_seconds") })
    bc_new_blobs = average(boringcache.map { |snapshot| snapshot.dig("oci", "new_blob_count") })
    bootstraps = boringcache.count { |snapshot| snapshot.dig("classification", "rolling_reseed") == true }
    reporting_entries = entries.map { |entry| entry.dig("comparison", "reporting") || {} }
    invalid_count = reporting_entries.count { |reporting| reporting["status"] == "invalid" }
    investigation_count = reporting_entries.count { |reporting| reporting["status"] == "investigation_only" }
    reporting_status = if invalid_count.positive?
      "invalid"
    elsif investigation_count.positive?
      "investigation_only"
    else
      "comparative"
    end

    {
      "benchmark" => benchmark_id,
      "name" => first.fetch("name"),
      "category" => first.fetch("category"),
      "lane" => lane,
      "pairs" => grouped.length,
      "head_shas" => grouped.map { |pair| pair.fetch("head_sha") },
      "actions_cache" => {
        "avg_cold_seconds" => ac_cold,
        "avg_warm_seconds" => ac_warm,
        "avg_storage_bytes" => ac_storage,
        "avg_docker_export_seconds" => ac_export
      },
      "boringcache" => {
        "avg_cold_seconds" => bc_cold,
        "avg_warm_seconds" => bc_warm,
        "avg_storage_bytes" => bc_storage,
        "avg_docker_export_seconds" => bc_export,
        "avg_oci_new_blob_count" => bc_new_blobs,
        "cache_bootstrap_count" => bootstraps
      },
      "reporting" => {
        "status" => reporting_status,
        "invalid_count" => invalid_count,
        "investigation_count" => investigation_count,
        "result_text" => most_common(reporting_entries.map { |reporting| reporting["result_text"] }),
        "note" => most_common(reporting_entries.map { |reporting| reporting["note"] })
      },
      "improvement" => {
        "cold_pct" => percent_delta(ac_cold, bc_cold),
        "warm_pct" => percent_delta(ac_warm, bc_warm),
        "storage_pct" => percent_delta(ac_storage, bc_storage),
        "docker_export_pct" => percent_delta(ac_export, bc_export)
      }
    }
  end
end

def build_report(aggregates, cohort)
  sections = []
  sections << "# Latest Paired Benchmark Cohort"
  sections << ""
  sections << "Generated: #{Time.now.utc.strftime('%Y-%m-%d %H:%M UTC')}"
  sections << ""
  sections << "Pairs per benchmark/lane: #{cohort.fetch('pairs_per_lane')}"
  sections << "Run history limit: #{cohort.fetch('run_history_limit')}"
  sections << ""

  LANES.each do |lane|
    rows = aggregates.select { |row| row.fetch("lane") == lane }.map do |row|
      cold_result = if invalid_sample?(row)
        row.dig("reporting", "result_text") || "invalid sample"
      elsif rolling_bootstrap_investigation?(row)
        row.dig("reporting", "result_text") || "investigation only"
      else
        result_text(row.dig("actions_cache", "avg_cold_seconds"), row.dig("boringcache", "avg_cold_seconds"))
      end

      [
        row.fetch("name"),
        row.fetch("category"),
        row.fetch("pairs").to_s,
        seconds_text(row.dig("actions_cache", "avg_cold_seconds")),
        seconds_text(row.dig("boringcache", "avg_cold_seconds")),
        cold_result,
        seconds_text(row.dig("actions_cache", "avg_warm_seconds")),
        seconds_text(row.dig("boringcache", "avg_warm_seconds")),
        bytes_text(
          if row.dig("actions_cache", "avg_storage_bytes") && row.dig("boringcache", "avg_storage_bytes")
            row.dig("actions_cache", "avg_storage_bytes") - row.dig("boringcache", "avg_storage_bytes")
          end
        ),
        row.dig("boringcache", "cache_bootstrap_count").to_s
      ]
    end
    next if rows.empty?

    sections << "## #{lane == 'fresh' ? 'Fresh' : 'Rolling'}"
    sections << ""
    sections << markdown_table(
      ["Benchmark", "Category", "Pairs", "GitHub Actions Cache Cold/Commit Build", "BoringCache Cold/Commit Build", "Build Result", "GitHub Actions Cache Warm Build", "BoringCache Warm Build", "Avg Storage Delta", "BoringCache Bootstraps"],
      rows
    )
    sections << ""
  end

  docker_rows = aggregates.select { |row| row.fetch("category") == "docker" }.map do |row|
    export_result = if invalid_sample?(row)
      row.dig("reporting", "result_text") || "invalid sample"
    elsif rolling_bootstrap_investigation?(row)
      row.dig("reporting", "result_text") || "investigation only"
    else
      result_text(row.dig("actions_cache", "avg_docker_export_seconds"), row.dig("boringcache", "avg_docker_export_seconds"))
    end

    [
      row.fetch("name"),
      row.fetch("lane"),
      row.fetch("pairs").to_s,
      seconds_text(row.dig("actions_cache", "avg_docker_export_seconds")),
      seconds_text(row.dig("boringcache", "avg_docker_export_seconds")),
      export_result,
      row.dig("boringcache", "avg_oci_new_blob_count")&.round(1)&.to_s || "—",
      row.dig("boringcache", "cache_bootstrap_count").to_s
    ]
  end
  if docker_rows.any?
    sections << "## Docker Export Detail"
    sections << ""
    sections << markdown_table(
      ["Benchmark", "Lane", "Pairs", "GitHub Actions Cache Export", "BoringCache Export", "Export Result", "Avg BoringCache New Blobs", "BoringCache Bootstraps"],
      docker_rows
    )
    sections << ""
  end

  sections.join("\n").rstrip + "\n"
end

options = {
  pairs_per_lane: 3,
  run_limit: 100,
  lanes: LANES,
  benchmarks: [],
  cache_dir: DEFAULT_CACHE_DIR,
  output_cohort: nil,
  output_json: nil,
  output_md: nil,
  cohort_only: false
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on("--pairs N", Integer, "Paired head SHAs per benchmark/lane (default: 3)") do |value|
    options[:pairs_per_lane] = value
  end

  opts.on("--run-limit N", Integer, "GitHub run history limit per workflow (default: 100)") do |value|
    options[:run_limit] = value
  end

  opts.on("--lane LANE", "fresh, rolling, or all (default: all)") do |value|
    lane = value.to_s.downcase
    options[:lanes] = lane == "all" ? LANES : [lane]
  end

  opts.on("--benchmark KEY", "Restrict to one benchmark; repeatable") do |value|
    options[:benchmarks] << value
  end

  opts.on("--cache-dir DIR", "Artifact cache dir (default: #{DEFAULT_CACHE_DIR})") do |value|
    options[:cache_dir] = value
  end

  opts.on("--output-cohort PATH", "Write selected pair cohort JSON") do |value|
    options[:output_cohort] = value
  end

  opts.on("--output-json PATH", "Write averages JSON") do |value|
    options[:output_json] = value
  end

  opts.on("--output-md PATH", "Write markdown averages report") do |value|
    options[:output_md] = value
  end

  opts.on("--cohort-only", "Only select and print pairs; skip artifact normalization and averages") do
    options[:cohort_only] = true
  end
end

parser.parse!

raise ArgumentError, "--pairs must be >= 1" if options[:pairs_per_lane] < 1
unsupported_lanes = options[:lanes] - LANES
raise ArgumentError, "Unsupported lane(s): #{unsupported_lanes.join(', ')}" if unsupported_lanes.any?

benchmarks = select_benchmarks(options[:benchmarks])
cohort = build_cohort(
  benchmarks: benchmarks,
  lanes: options[:lanes],
  pairs_per_lane: options[:pairs_per_lane],
  run_limit: options[:run_limit]
)

write_json(options[:output_cohort], cohort) if options[:output_cohort]

if options[:cohort_only]
  puts JSON.pretty_generate(cohort)
  exit 0
end

pairs = cohort.fetch("pairs")
normalized_pairs = pairs.each_with_index.map do |pair, index|
  warn "Normalizing #{index + 1}/#{pairs.length}: #{pair.fetch('benchmark')} #{pair.fetch('lane')} GitHub Actions Cache=#{pair.fetch('actions_cache')} BoringCache=#{pair.fetch('boringcache')}"
  normalize_pair(pair, options[:cache_dir])
end
aggregates = aggregate_pairs(normalized_pairs)
payload = {
  "generated_at" => Time.now.utc.iso8601,
  "cohort" => cohort,
  "aggregates" => aggregates
}
report = build_report(aggregates, cohort)

write_json(options[:output_json], payload) if options[:output_json]
if options[:output_md]
  FileUtils.mkdir_p(File.dirname(options[:output_md]))
  File.write(options[:output_md], report)
end
puts report unless options[:output_md]
