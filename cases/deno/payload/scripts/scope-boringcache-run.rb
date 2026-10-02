#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"

scope = ARGV.fetch(0)
profile = ARGV.fetch(1, "cargo-product")
raise "Expected a lowercase benchmark cache scope" unless scope.match?(/\A[a-z0-9][a-z0-9._-]+\z/)
raise "Unknown Deno Cargo cache profile: #{profile}" unless %w[cargo-product sccache-only compiler-only].include?(profile)
scope = "#{scope}-#{profile}" unless profile == "cargo-product"
path = File.join(BenchmarkPlan::ROOT, ".boringcache.toml")
text = File.read(path)
%w[deno-cargo-registry-cache deno-cargo-registry-index deno-cargo-git-db deno-cargo-target deno-rust-cache].each do |tag|
  original = "tag = #{JSON.generate("#{tag}-local")}"
  raise "Expected one local #{tag} tag" unless text.scan(Regexp.new(Regexp.escape(original))).length == 1
  text = text.sub(original, "tag = #{JSON.generate("#{tag}-#{scope}")}")
end
TomlRB.parse(text)
File.write(path, text)
puts "Scoped Deno #{profile} cache tags to #{scope}"
