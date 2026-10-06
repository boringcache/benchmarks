#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"

options = {"load" => "false", "push" => "false"}
OptionParser.new do |parser|
  %w[image strategy load push].each do |name|
    parser.on("--#{name} VALUE") { |value| options[name] = value }
  end
end.parse!
raise "Unexpected arguments" unless ARGV.empty?
%w[load push].each do |name|
  raise "--#{name} must be true or false" unless %w[true false].include?(options.fetch(name))
end
raise "Choose either push or load" if options["load"] == "true" && options["push"] == "true"
strategy = options.fetch("strategy")
raise "Unknown Docker provider" unless %w[boringcache actions-cache depot-actions-cache depot-cache].include?(strategy)

verified = options["load"] == "true" || options["push"] == "true"
if verified
  image = if strategy == "boringcache"
    command = BenchmarkPlan.command("docker")
    index = command.index("--tag") or raise "Docker plan has no output tag"
    command.fetch(index + 1)
  else
    options.fetch("image")
  end
  raise "Output image is empty" if image.empty?
  command = options["load"] == "true" ? ["docker", "image", "inspect", image] : ["docker", "buildx", "imagetools", "inspect", image]
  _output, errors, status = Open3.capture3(*command)
  raise "Cannot verify Docker output #{image}: #{errors}" unless status.success?
end
BenchmarkPlan.write_output("verified", verified)
