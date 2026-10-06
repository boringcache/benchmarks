# frozen_string_literal: true

require "json"
require "open3"

workspace = "boringcache/benchmarks"
raise "Pause benchmark scheduling before resetting caches" unless ENV["BENCHMARK_CADENCE_ACTIVE"] == "false"
raise "Reset must use the benchmark workspace" unless ENV["BORINGCACHE_WORKSPACE"] == workspace
deleted = 0
200.times do
  output, status = Open3.capture2("boringcache", "ls", workspace, "--limit", "100", "--page", "1", "--json")
  raise "Cannot list benchmark caches" unless status.success?
  inventory = JSON.parse(output)
  raise "Cache inventory belongs to another workspace" unless inventory.fetch("workspace") == workspace
  entries = inventory.fetch("entries")
  if entries.empty?
    raise "Cache inventory is incomplete" unless inventory.fetch("total") == 0
    puts "Deleted #{deleted} benchmark cache tags; the workspace has no cache entries."
    exit
  end
  tags = entries.map { |entry| entry.fetch("tag") }
  raise "Cannot reset an untagged cache entry" unless tags.all? { |tag| tag.is_a?(String) && tag.match?(/\A[a-zA-Z0-9._-]+\z/) }
  raise "Duplicate tags in cache inventory" unless tags.uniq == tags
  raise "Benchmark cache deletion failed" unless system("boringcache", "rm", workspace, tags.join(","), "--no-platform", "--no-git")
  deleted += tags.length
end
raise "Cache reset did not reach an empty workspace"
