#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

def validate_concurrency(node, path)
  case node
  when Hash
    if (concurrency = node["concurrency"]).is_a?(Hash) && concurrency.key?("queue")
      raise "#{path}: concurrency.queue must be single or max" unless %w[single max].include?(concurrency["queue"])
      raise "#{path}: queue: max cannot cancel running observations" if concurrency["queue"] == "max" && concurrency["cancel-in-progress"] != false
    end
    node.each_value { |value| validate_concurrency(value, path) }
  when Array
    node.each { |value| validate_concurrency(value, path) }
  end
end

Dir[".github/workflows/*.{yml,yaml}"].each do |path|
  validate_concurrency(YAML.safe_load(File.read(path), aliases: true), path)
end

# Actionlint 1.7.12 predates GitHub's queue property. Check that property above
# and retain every other actionlint diagnostic until upstream supports it.
exec(ARGV.fetch(0, "actionlint"), "-ignore", 'unexpected key "queue" for "concurrency" section')
