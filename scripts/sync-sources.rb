#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "optparse"
require_relative "benchmark-cases"

options = {}
OptionParser.new do |parser|
  parser.on("--case ID") { |value| options[:case] = value }
  parser.on("--output PATH") { |value| options[:output] = value }
end.parse!
raise "Use --output for the proposal inventory" unless options[:output]
items = options[:case] ? [BenchmarkCases.load_case(options[:case])] : BenchmarkCases.documents
items = items.select { |item| item.dig("execution", "sync") != "fixed" && item.dig("execution", "sync") && item.dig("execution", "blockers").to_a.empty? }
records = items.map do |item|
  begin
    BenchmarkCases.sync_source(item).merge("state" => "proposal", "requires_case_qualification" => true)
  rescue BenchmarkCases::Error => error
    {"case_id" => item.fetch("id"), "state" => "blocked", "error" => error.message}
  end
end
BenchmarkCases.validate
BenchmarkCases.write_json(options.fetch(:output), {"schema_version" => 1, "records" => records, "publication" => "requires-review"})
puts "Prepared #{records.length} source proposals; #{records.count { |record| record['state'] == 'blocked' }} blocked"
exit(records.any? { |record| record["state"] == "blocked" } ? 1 : 0)
