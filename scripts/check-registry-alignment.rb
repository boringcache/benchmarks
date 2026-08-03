#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "publish-index"

def default_repos_dir
  candidates = [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ]
  candidates.find { |path| Dir.exist?(path) } || candidates.first
end

repos_dir = ARGV[0] || ENV.fetch("BENCHMARK_REPOS_DIR", default_repos_dir)
abort "benchmark repos directory not found: #{repos_dir}" unless Dir.exist?(repos_dir)

registry_by_repo = BENCHMARKS.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |benchmark, index|
  repo_name = benchmark.fetch("source_repo").split("/").last
  index[repo_name] << benchmark
end

suite_repos = ["benchmark-docker"]
repo_names = Dir[File.join(repos_dir, "benchmark-*")].select { |path| File.directory?(path) }.map { |path| File.basename(path) }.sort - suite_repos

missing_from_registry = repo_names - registry_by_repo.keys
extra_in_registry = registry_by_repo.keys - repo_names
errors = []

errors << "benchmark repos missing from aggregate registry: #{missing_from_registry.join(", ")}" if missing_from_registry.any?
errors << "aggregate registry points at missing repos: #{extra_in_registry.join(", ")}" if extra_in_registry.any?

registry_by_repo.each do |repo_name, benchmarks|
  repo_path = File.join(repos_dir, repo_name)
  next unless Dir.exist?(repo_path)

  workflow_ids = Dir[File.join(repo_path, ".github", "workflows", "*.yml")].flat_map do |path|
    File.readlines(path).map do |line|
      line[/^\s*benchmark_id:\s*([A-Za-z0-9._-]+)\s*$/, 1] ||
        line[/^\s*BENCHMARK_ID:\s*([A-Za-z0-9._-]+)\s*$/, 1] ||
        line[/^\s*benchmark_id:\s*([A-Za-z0-9._-]+)\$\{\{\s*inputs\.benchmark_id_suffix\s*\}\}\s*$/, 1] ||
        line[/^\s*benchmark_id:\s*\$\{\{\s*format\('([A-Za-z0-9._-]+)\{0\}',\s*inputs\.benchmark_id_suffix\)\s*\}\}\s*$/, 1]
    end.compact
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
