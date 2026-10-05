#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
args = {}
OptionParser.new do |parser|
  %w[path phase strategy].each { |name| parser.on("--#{name} VALUE") { |value| args[name] = value } }
end.parse!
payload = JSON.parse(File.read(args.fetch("path")))
raise "Unknown phase or strategy" unless %w[base rolling commit].include?(args["phase"]) && %w[actions-cache boringcache].include?(args["strategy"])
errors, timeouts = payload.values_at("remote_storage_error", "remote_storage_timeout").map(&:to_i)
raise "ccache reported remote errors=#{errors}, timeouts=#{timeouts}" unless errors.zero? && timeouts.zero?
hits = payload.fetch("direct_cache_hit", 0) + payload.fetch("preprocessed_cache_hit", 0)
base = args["phase"] == "base"
raise "Cold ccache build did not report cache misses" if base && payload.fetch("cache_miss", 0) <= 0
raise "Rolling ccache build did not report cache hits" if args["phase"] == "rolling" && hits <= 0
raise "ccache build did not report compilation" if args["phase"] == "commit" && hits + payload.fetch("cache_miss", 0) <= 0
if args["strategy"] == "boringcache"
  if args["phase"] == "commit"
    raise "BoringCache did not report a remote read or write" if payload.fetch("remote_storage_hit", 0) + payload.fetch("remote_storage_write", 0) <= 0
  else
    field = base ? "remote_storage_write" : "remote_storage_hit"
    raise "BoringCache did not report #{field}" if payload.fetch(field, 0) <= 0
  end
end
