#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
surface, run_id, attempt = ARGV.shift(3)
raise "Use ccache or xcode with a numeric run ID and attempt" unless %w[ccache xcode].include?(surface) && [run_id, attempt].all? { |value| value&.match?(/\A\d+\z/) }
path = ".boringcache.toml"
OptionParser.new { |parser| parser.on("--plan PATH") { |value| path = value } }.parse!
plan = BenchmarkPlan.load(path)
plan.fetch("adapters").fetch(surface)["tag"] = "obs-studio-#{surface}-r#{run_id}-a#{attempt}"
File.write(path, TomlRB.dump(plan))
