#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "benchmark-cases"

begin
  cases = BenchmarkCases.validate
  by_id = cases.to_h { |item| [item.fetch("id"), item] }
  suites = Dir[File.join(BenchmarkCases::ROOT, "suites", "*.json")].to_h { |path| [File.basename(path, ".json"), JSON.parse(File.read(path))] }
  errors = []
  suites.each do |name, suite|
    next unless suite.is_a?(Hash)
    Array(suite["cases"]).each do |id|
      item = by_id[id]
      errors << "#{name}: unknown case #{id}" unless item
      errors << "#{name}: retained case #{id} cannot execute" if item && item["kind"] == "retained"
    end
  end
  published = suites.fetch("published")
  published.each do |row|
    next if row["source_repo"] == "boringcache/benchmark-discourse"
    id = row.fetch("case_id")
    item = by_id[id]
    errors << "Published entry #{row.fetch('benchmark')}: unknown case #{id}" unless item
    errors << "#{id}: current execution must use boringcache/benchmarks" unless row["source_repo"] == BenchmarkCases::REPOSITORY
    paths = item&.dig("execution", "workflows")&.map { |entry| File.basename(entry.fetch("path")) } || []
    %w[workflow fresh_workflow].each do |field|
      errors << "#{id}: unregistered #{row[field]}" if row[field] && !paths.include?(row[field])
    end
  end
  ids = published.map { |row| row.fetch("benchmark") }
  errors << "Duplicate published benchmark IDs" unless ids.uniq.length == ids.length
  raise BenchmarkCases::Error, errors.join("\n") unless errors.empty?
  puts "benchmark registry aligned: #{cases.length} cases, #{published.length} published entries"
rescue BenchmarkCases::Error, KeyError, JSON::ParserError => error
  abort error.message
end
