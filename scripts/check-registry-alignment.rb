#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "publish-index"
require "open3"

def default_repos_dir
  candidates = [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ]
  candidates.find { |path| Dir.exist?(path) } || candidates.first
end

BENCHMARK_ID_ASSIGNMENT = /\b(?:benchmark_id|BENCHMARK_ID):[ \t]*(?:"([^"]*)"|'([^']*)'|((?:\$\{\{.*?\}\}|[^,}\s])+))/
BENCHMARK_ID_VALUES = [
  /\A([A-Za-z0-9._-]+)\z/,
  /\A([A-Za-z0-9._-]+)\$\{\{\s*inputs\.benchmark_id_suffix\s*\}\}\z/,
  /\A\$\{\{\s*format\('([A-Za-z0-9._-]+)\{0\}',\s*inputs\.benchmark_id_suffix\)\s*\}\}\z/
].freeze

def benchmark_ids_in(line)
  line.scan(BENCHMARK_ID_ASSIGNMENT).filter_map do |captures|
    value = captures.compact.first.to_s.strip
    BENCHMARK_ID_VALUES.filter_map { |pattern| value[pattern, 1] }.first
  end
end

def canonical_checkout?(path)
  remote, status = Open3.capture2("git", "-C", path, "remote", "get-url", "origin")
  return true unless status.success?

  remote_name = File.basename(remote.strip).delete_suffix(".git")
  remote_name == File.basename(path)
end

repos_dir = ARGV[0] || ENV.fetch("BENCHMARK_REPOS_DIR", default_repos_dir)
abort "benchmark repos directory not found: #{repos_dir}" unless Dir.exist?(repos_dir)

registry_by_repo = BENCHMARKS.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |benchmark, index|
  repo_name = benchmark.fetch("source_repo").split("/").last
  index[repo_name] << benchmark
end

registry_exempt_repos = ["benchmark-docker", "benchmark-obs-studio"]
sync_exempt_repos = ["benchmark-docker"]
owned_repo_names = Dir[File.join(repos_dir, "benchmark-*")]
  .select { |path| File.directory?(path) && canonical_checkout?(path) }
  .map { |path| File.basename(path) }
  .sort
repo_names = owned_repo_names - registry_exempt_repos

missing_from_registry = repo_names - registry_by_repo.keys
extra_in_registry = registry_by_repo.keys - repo_names
errors = []
sync_offsets = Hash.new { |offsets, minute| offsets[minute] = [] }

errors << "benchmark repos missing from aggregate registry: #{missing_from_registry.join(", ")}" if missing_from_registry.any?
errors << "aggregate registry points at missing repos: #{extra_in_registry.join(", ")}" if extra_in_registry.any?

owned_repo_names.each do |repo_name|
  repo_path = File.join(repos_dir, repo_name)
  readme_path = File.join(repo_path, "README.md")
  lines = File.file?(readme_path) ? File.readlines(readme_path, chomp: true) : []
  title = lines.first.to_s
  subject = title.delete_prefix("# BoringCache ").delete_suffix(" benchmark")
  valid_readme = !subject.empty? &&
    title == "# BoringCache #{subject} benchmark" &&
    lines.drop(1).any? { |line| !line.empty? } &&
    lines.any? { |line| line.include?(".boringcache.toml") }

  errors << "#{repo_name}: README must use the owned benchmark title and point to .boringcache.toml" unless valid_readme
  workflows_path = File.join(repo_path, ".github", "workflows")
  errors << "#{repo_name}: .github/workflows is missing" unless Dir.exist?(workflows_path)
  errors << "#{repo_name}: .boringcache.toml is missing" unless File.file?(File.join(repo_path, ".boringcache.toml"))

  next if sync_exempt_repos.include?(repo_name)

  sync_path = File.join(workflows_path, "sync.yml")
  unless File.file?(sync_path)
    errors << "#{repo_name}: sync.yml is missing for a single-upstream benchmark"
    next
  end

  sync_text = File.read(sync_path)
  sync_minutes = sync_text[/^\s*- cron: "(\d+),(\d+) \* \* \* \*"$/m] ? [Regexp.last_match(1).to_i, Regexp.last_match(2).to_i] : nil
  unless sync_minutes && sync_minutes[1] - sync_minutes[0] == 30 && sync_minutes[0].between?(1, 29)
    errors << "#{repo_name}: sync.yml must run twice an hour on a repo-specific offset, as \"<m>,<m+30> * * * *\" with m between 1 and 29"
  end
  sync_offsets[sync_minutes[0]] << repo_name if sync_minutes
  errors << "#{repo_name}: sync.yml must push with BOT_PUBLIC_GITHUB_TOKEN" unless sync_text.include?("secrets.BOT_PUBLIC_GITHUB_TOKEN")

  source_pin = File.file?(File.join(repo_path, "benchmark-source.env")) ? "benchmark-source.env" : "upstream"
  if sync_text.include?("gh run list") || sync_text.include?("steps.previous.outputs.ready")
    errors << "#{repo_name}: source sync must not depend on a previous benchmark conclusion"
  end
  benchmark_workflows = Dir[File.join(workflows_path, "*.yml")].reject { |path| path == sync_path }.map { |path| File.read(path) }
  source_push_trigger = benchmark_workflows.any? do |workflow|
    workflow.match?(/^\s{2}push:\s*$/) && workflow.include?(source_pin)
  end
  errors << "#{repo_name}: source updates must trigger a benchmark from #{source_pin}" unless source_push_trigger

  cargo_rolling_chain = Dir[File.join(workflows_path, "*cargo-rolling-chain.yml")].any?
  if cargo_rolling_chain
    rolling_source_push = benchmark_workflows.any? do |workflow|
      workflow.match?(/^\s{2}push:\s*$/) && workflow.include?(source_pin) && workflow.include?("cargo-rolling-chain")
    end
    errors << "#{repo_name}: Cargo source updates must trigger the persistent rolling chain" unless rolling_source_push
  end
end

sync_offsets.select { |_, repos| repos.length > 1 }.each do |minute, repos|
  errors << "sync offset #{minute} is shared by #{repos.sort.join(", ")}; give each benchmark its own minute"
end

registry_by_repo.each do |repo_name, benchmarks|
  repo_path = File.join(repos_dir, repo_name)
  next unless Dir.exist?(repo_path)

  workflow_ids = Dir[File.join(repo_path, ".github", "workflows", "*.yml")].flat_map do |path|
    File.readlines(path).flat_map { |line| benchmark_ids_in(line) }
  end.uniq.sort

  config_path = File.join(repo_path, ".boringcache.toml")
  config_ids = if File.file?(config_path)
    File.read(config_path).scan(/\bbenchmark=([A-Za-z0-9._-]+)/).flatten
  else
    []
  end
  declared_ids = (workflow_ids + config_ids).uniq.sort

  allowed_ids = benchmarks.flat_map do |benchmark|
    ids = [benchmark.fetch("benchmark"), *Array(benchmark["aliases"])]
    ids.concat(ids.map { |id| "#{id}-toolcache" }) if Array(benchmark["extra_providers"]).include?("boringcache-toolcache")
    ids.concat(ids.map { |id| "#{id}-mountcache" }) if Array(benchmark["extra_providers"]).include?("boringcache-mountcache")
    ids.concat(Array(benchmark["workflow_benchmark_ids"]))
    ids
  end.uniq.sort
  unknown_ids = declared_ids - allowed_ids
  missing_id = (declared_ids & allowed_ids).empty?

  errors << "#{repo_name}: no concrete benchmark id found in workflows or .boringcache.toml" if declared_ids.empty?
  errors << "#{repo_name}: declared benchmark ids #{declared_ids.join(", ")} do not match registry ids #{allowed_ids.join(", ")}" if missing_id
  errors << "#{repo_name}: unknown declared benchmark ids #{unknown_ids.join(", ")}; registry ids are #{allowed_ids.join(", ")}" if unknown_ids.any?
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "benchmark registry aligned: #{registry_by_repo.length} repos"
