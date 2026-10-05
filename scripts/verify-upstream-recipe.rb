#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
require "digest"
require "open3"

root = BenchmarkPlan::ROOT
source = ARGV.first || File.join(root, "upstream")
contract = JSON.parse(File.read(File.join(root, ARGV[1] || "recipe-contract.json")))
files = contract.fetch("upstream_files")
if contract.key?("upstream_files_by_revision")
  revision, status = Open3.capture2("git", "-C", source, "rev-parse", "HEAD")
  raise "Cannot determine the source revision for recipe verification" unless status.success?
  context_path = File.join(root, "benchmark-context.json")
  if File.realpath(source) == File.realpath(root) && File.file?(context_path)
    declared = JSON.parse(File.read(context_path)).dig("source", "revision")
    if declared
      parent, status = Open3.capture2("git", "-C", source, "rev-parse", "HEAD^")
      unless declared.match?(/\A[0-9a-f]{40}\z/) && status.success? && parent.strip == declared
        raise "Prepared snapshot does not have the declared upstream parent"
      end
      revision = declared
    end
  end
  overrides = contract.fetch("upstream_files_by_revision")
  raise "Recipe exceptions require exact source revisions" unless overrides.keys.all? { |sha| sha.match?(/\A[0-9a-f]{40}\z/) }
  files = overrides.fetch(revision.strip, files)
  raise "Recipe exception changes the reviewed file set" unless files.keys.sort == contract.fetch("upstream_files").keys.sort
end
files.each do |path, digest|
  actual = File.join(source, path)
  raise "Upstream recipe file is missing: #{path}" unless File.file?(actual)
  raise "Upstream recipe changed: #{path}; review the workload before updating its recipe digest" unless Digest::SHA256.file(actual).hexdigest == digest
end
plan = BenchmarkPlan.load
contract.fetch("commands").each do |adapter, command|
  raise "Committed #{adapter} build command differs from the reviewed recipe" unless plan.dig("adapters", adapter, "command") == command
end
contract.fetch("plans", []).each do |declaration|
  declaration.fetch("paths").each do |path|
    selected = BenchmarkPlan.load(File.join(root, path))
    unless selected.dig("adapters", declaration.fetch("adapter"), "command") == declaration.fetch("command")
      raise "Committed build command in #{path} differs from the reviewed recipe"
    end
  end
end
puts "Verified upstream recipe and declared build commands"
