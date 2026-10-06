#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
profile, path = ARGV
path ||= File.join(BenchmarkPlan::ROOT, ".boringcache.toml")
raise "Unknown Deno Cargo cache profile: #{profile}" unless %w[cargo-product sccache-only compiler-only].include?(profile)
text = File.read(path)
needle = 'profiles = ["cargo-product"]'
raise "Expected one default Cargo profile selection" unless text.scan(Regexp.new(Regexp.escape(needle))).length == 1
text = text.sub(needle, "profiles = [#{JSON.generate(profile)}]").gsub('"lane=cargo-product"', JSON.generate("lane=#{profile}"))
engine = ENV.fetch("COMPILER_CACHE", "sccache")
raise "Unknown compiler cache: #{engine}" unless %w[sccache kache mbx].include?(engine)
text = text.sub("[adapters.cargo]", "[adapters.cargo]\ncompiler-cache = #{JSON.generate(engine)}")
TomlRB.parse(text)
File.write(path, text)
puts "Selected Deno Cargo cache profile: #{profile}"
