#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
raise "Use LABEL EVIDENCE_PATH pairs" if ARGV.empty? || ARGV.length.odd?
lines = ["## Cargo rebuild set", ""]
ARGV.each_slice(2) do |label, path|
  unless File.file?(path)
    lines << "- `#{label}`: evidence missing at #{path}"
    next
  end
  evidence = JSON.parse(File.read(path))
  mode = evidence.dig("phases", "restore", "mode_evidence") || {}
  native = mode["native_tool"] || {}
  lines << "- `#{label}`:"
  lines << "  - elapsed: #{mode['elapsed_seconds'].round}s" if mode["elapsed_seconds"]
  lines << "  - target snapshot restored: `#{mode['target_cache_hit']}`" unless mode["target_cache_hit"].nil?
  lines << "  - compiler cache: disabled" if mode.dig("cargo_cache", "compiler_cache") == "none"
  lines << "  - Cargo units compiled: #{native['compile_requests_executed'] || native['compile_requests']} (#{native['compile_requests']} compile requests)" if native["compile_requests"]
  lines << "  - sccache: #{native['cache_hits']} hits / #{native['cache_misses']} misses (#{format('%.1f', native.fetch('hit_rate', 0))}% hit rate)" if native["cache_hits"]
  lines << "  - sccache write errors: #{native['cache_write_errors']}" if native["cache_write_errors"].to_i.positive?
end
report = lines.join("\n") + "\n"
puts report
File.open(ENV["GITHUB_STEP_SUMMARY"], "a") { |file| file.write(report) } if ENV["GITHUB_STEP_SUMMARY"]
