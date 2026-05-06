#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "publish-index"

repos_dir = ARGV[0] || ENV.fetch("BENCHMARK_REPOS_DIR", File.expand_path("../../benchmark-repos", __dir__))
abort "benchmark repos directory not found: #{repos_dir}" unless Dir.exist?(repos_dir)

registry_by_repo = BENCHMARKS.each_with_object({}) do |benchmark, index|
  repo_name = benchmark.fetch("source_repo").split("/").last
  index[repo_name] = benchmark
end

repo_names = Dir[File.join(repos_dir, "benchmark-*")].select { |path| File.directory?(path) }.map { |path| File.basename(path) }.sort

missing_from_registry = repo_names - registry_by_repo.keys
extra_in_registry = registry_by_repo.keys - repo_names
errors = []

errors << "benchmark repos missing from aggregate registry: #{missing_from_registry.join(", ")}" if missing_from_registry.any?
errors << "aggregate registry points at missing repos: #{extra_in_registry.join(", ")}" if extra_in_registry.any?

registry_by_repo.each do |repo_name, benchmark|
  repo_path = File.join(repos_dir, repo_name)
  next unless Dir.exist?(repo_path)

  workflow_ids = Dir[File.join(repo_path, ".github", "workflows", "*.yml")].flat_map do |path|
    File.readlines(path).map do |line|
      line[/^\s*benchmark_id:\s*([A-Za-z0-9._-]+)\s*$/, 1] ||
        line[/^\s*BENCHMARK_ID:\s*([A-Za-z0-9._-]+)\s*$/, 1]
    end.compact
  end.uniq.sort

  allowed_ids = [benchmark.fetch("benchmark"), *Array(benchmark["aliases"])].uniq.sort
  unknown_ids = workflow_ids - allowed_ids
  missing_id = (workflow_ids & allowed_ids).empty?

  errors << "#{repo_name}: no concrete benchmark_id found in workflows" if workflow_ids.empty?
  errors << "#{repo_name}: workflow benchmark ids #{workflow_ids.join(", ")} do not match registry ids #{allowed_ids.join(", ")}" if missing_id
  errors << "#{repo_name}: unknown workflow benchmark ids #{unknown_ids.join(", ")}; registry ids are #{allowed_ids.join(", ")}" if unknown_ids.any?
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "benchmark registry aligned: #{registry_by_repo.length} repos"
