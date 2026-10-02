#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'benchmark-plan'
scope = ARGV.fetch(0)
raise 'Expected a lowercase benchmark cache scope' unless scope.match?(/\A[a-z0-9][a-z0-9._-]+\z/)
path = File.join(BenchmarkPlan::ROOT, '.boringcache.toml')
text = File.read(path)
{'immich-docker-local' => "#{scope}-docker", 'immich-ccache-local' => "#{scope}-ccache"}.each do |original, tag|
  needle = "tag = #{JSON.generate(original)}"
  raise "Expected one local #{original} tag" unless text.scan(Regexp.new(Regexp.escape(needle))).length == 1
  text = text.sub(needle, "tag = #{JSON.generate(tag)}")
end
TomlRB.parse(text)
File.write(path, text)
puts "Scoped BoringCache adapter tags to #{scope}"
