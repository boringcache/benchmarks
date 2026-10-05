#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "optparse"
require_relative "benchmark-cases"
require_relative "benchmark-cadence"

module SourceSync
  def self.propose(items, output:, sync: BenchmarkCases.method(:sync_source))
    inventory = {"schema_version" => 1, "records" => [], "publication" => "requires-review"}
    BenchmarkCases.write_json(output, inventory)
    items.each do |item|
      record = begin
        blockers = item.dig("execution", "blockers").to_a
        raise BenchmarkCases::Error, blockers.join("; ") unless blockers.empty?
        proposal = sync.call(item)
        proposal.merge("state" => proposal.fetch("updated") ? "proposal" : "unchanged",
          "requires_case_qualification" => proposal.fetch("updated"))
      rescue BenchmarkCases::Error => error
        {"case_id" => item.fetch("id"), "state" => "blocked", "error" => error.message}
      end
      inventory.fetch("records") << record
      BenchmarkCases.write_json(output, inventory)
      puts "#{record.fetch('case_id')}: #{record.fetch('state')}"
      $stdout.flush
    end
    inventory
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  OptionParser.new do |parser|
    parser.on("--case ID") { |value| options[:case] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
  end.parse!
  abort "Use --output for the proposal inventory" unless options[:output]
  items = BenchmarkCadence.source_cases(case_id: options[:case])
  inventory = SourceSync.propose(items, output: options.fetch(:output))
  BenchmarkCases.validate
  exit(inventory.fetch("records").any? { |record| record["state"] == "blocked" } ? 1 : 0)
end
