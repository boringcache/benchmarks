#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "docker-case-contract"
args = {}
OptionParser.new do |parser|
  parser.on("--case ID") { |value| args["case"] = value }
  parser.on("--source PATH") { |value| args["source"] = value }
end.parse!
Dir[File.join(BenchmarkPlan::ROOT, "cases", "*.json")].each do |path|
  item = JSON.parse(File.read(path))
  DockerCaseContract.validate(item, File.join(BenchmarkPlan::ROOT, "plans", item.fetch("id")))
end
if args["case"] || args["source"]
  raise "Use --case and --source together" unless args["case"] && args["source"]
  item = JSON.parse(File.read(File.join(BenchmarkPlan::ROOT, "cases", "#{args.fetch('case')}.json")))
  workflow = File.join(args.fetch("source"), item.fetch("source").fetch("workflow"))
  raise "Pinned source has no declared upstream workflow" unless File.file?(workflow)
  anchor = item.fetch("source").fetch("anchor", "docker")
  raise "Pinned workflow no longer contains #{anchor}" unless File.read(workflow).downcase.include?(anchor.downcase)
end
puts "Verified Docker recipes and source anchors"
