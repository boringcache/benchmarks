#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
require "digest"

root = BenchmarkPlan::ROOT
source = ARGV.first || File.join(root, "upstream")
contract = JSON.parse(File.read(File.join(root, ARGV[1] || "recipe-contract.json")))
contract.fetch("upstream_files").each do |path, digest|
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
