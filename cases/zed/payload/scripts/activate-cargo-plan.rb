#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"

lane, phase = ARGV
raise "Use a Cargo layer lane and release phase" unless %w[cold target-only sccache-only combined].include?(lane) && %w[primary remote-server].include?(phase)
run, attempt = ENV.values_at("GITHUB_RUN_ID", "GITHUB_RUN_ATTEMPT")
raise "A fresh layer cohort requires a numeric run ID and attempt" unless [run, attempt].all? { |value| value&.match?(/\A\d+\z/) }
scope = "zed-cargo-layers-r#{run}-a#{attempt}"
series = ENV["BENCHMARK_SERIES_ID"]
unless series.to_s.empty?
  sample = ENV.fetch("BENCHMARK_SAMPLE")
  raise "Invalid series or sample" unless series.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/) && sample.match?(/\A[1-9]\d*\z/)
  scope = "zed-cargo-layers-series-#{series}-s#{sample}-r#{run}-a#{attempt}"
end
plan = BenchmarkPlan.load(File.join(BenchmarkPlan::ROOT, "plans", lane, phase, ".boringcache.toml"))
engine = ENV.fetch("COMPILER_CACHE", "sccache")
raise "Unknown compiler cache: #{engine}" unless %w[sccache kache mbx].include?(engine)
scope += "-#{engine}"
cargo = plan.fetch("adapters").fetch("cargo")
cargo["compiler-cache"] = engine unless cargo["compiler-cache"] == "none"
if engine != "sccache"
  settings = plan.fetch("adapters").delete("sccache")
  plan.fetch("adapters")[engine] = settings if settings
end
[plan.fetch("entries"), plan.fetch("adapters")].each do |group|
  group.each_value do |entry|
    next unless entry["tag"]
    tag = entry.fetch("tag")
    raise "Expected a local layer tag: #{tag}" unless tag.start_with?("zed-cargo-layers-local-")
    entry["tag"] = tag.sub("zed-cargo-layers-local", scope)
  end
end
upstream = File.join(BenchmarkPlan::ROOT, "upstream")
git_dir, status = Open3.capture2("git", "-C", upstream, "rev-parse", "--absolute-git-dir")
raise "The upstream checkout is missing" unless status.success?
exclude = File.join(git_dir.strip, "info", "exclude")
File.open(exclude, "a") { |file| file.puts "/.boringcache.toml" } unless File.file?(exclude) && File.readlines(exclude, chomp: true).include?("/.boringcache.toml")
destination = File.join(upstream, ".boringcache.toml")
File.unlink(destination) if File.symlink?(destination)
File.write(destination, TomlRB.dump(plan))
output, status = Open3.capture2("git", "-C", upstream, "status", "--porcelain=v1", "--untracked-files=all")
raise "The upstream checkout must be clean" unless status.success? && output.empty?
puts "Activated #{lane}/#{phase} with cache scope #{scope}"
