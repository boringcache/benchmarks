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
    Array(suite["cases"]).each do |entry|
      id = entry.is_a?(Hash) ? entry.fetch("case_id") : entry
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
    next unless item && row["fresh_workflow"]
    entry = item.dig("execution", "workflows").find { |candidate| File.basename(candidate.fetch("path")) == row.fetch("fresh_workflow") }
    next unless entry
    if entry.fetch("lane") != "fresh"
      errors << "#{id}: fresh callers must select a reviewed fresh workflow, not a diagnostic matrix"
      next
    end
    inputs = row.fetch("fresh_inputs", {})
    unless inputs.is_a?(Hash) && inputs.all? { |name, value| name.is_a?(String) && value.is_a?(String) } && !inputs.key?("cli_version")
      errors << "#{id}: fresh selectors must be string inputs without cli_version"
      next
    end
    inputs = {"case_id" => id}.merge(inputs) if row.fetch("fresh_workflow").start_with?("native-")
    variant = inputs[entry["variant_input"]]
    if entry["variants"] && !entry.fetch("variants").include?(variant)
      errors << "#{id}: fresh caller must select an explicit reviewed variant"
      next
    end
    begin
      BenchmarkCases.plan(item, lane: "fresh", workflow: row.fetch("fresh_workflow"), inputs: inputs, variant: variant)
    rescue BenchmarkCases::Error, NativeCase::Error => error
      errors << "#{id}: #{error.message}"
    end
  end
  ids = published.map { |row| row.fetch("benchmark") }
  errors << "Duplicate published benchmark IDs" unless ids.uniq.length == ids.length
  raise BenchmarkCases::Error, errors.join("\n") unless errors.empty?
  puts "benchmark registry aligned: #{cases.length} cases, #{published.length} published entries"
rescue BenchmarkCases::Error, KeyError, JSON::ParserError => error
  abort error.message
end
