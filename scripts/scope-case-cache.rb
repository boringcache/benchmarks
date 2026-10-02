#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "toml-rb"

root = File.expand_path("..", __dir__)
scope = ARGV.fetch(0, "")
abort "Expected a lowercase benchmark cache scope" unless scope.match?(/\A[a-z0-9][a-z0-9._-]+\z/)
context = JSON.parse(File.read(File.join(root, "benchmark-context.json")))
mappings = context.fetch("execution").fetch("cache_tags")
path = File.join(root, ".boringcache.toml")
text = File.read(path)
mappings.each do |original, template|
  needle = "tag = #{JSON.generate(original)}"
  abort "Expected one declared #{original} tag" unless text.scan(Regexp.new(Regexp.escape(needle))).length == 1
  text = text.sub(needle, "tag = #{JSON.generate(template.sub('{scope}', scope))}")
end
TomlRB.parse(text)
File.write(path, text)
puts "Applied the declared case cache scope #{scope}"
