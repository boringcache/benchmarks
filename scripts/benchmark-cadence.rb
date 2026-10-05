#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "benchmark-cases"
require_relative "nightly-canaries"

module BenchmarkCadence
  class Error < StandardError; end

  def self.cases(root: BenchmarkCases::ROOT)
    suite = JSON.parse(File.read(File.join(root, "suites/scheduled.json")))
    raise Error, "Unsupported scheduled suite version" unless suite.fetch("schema_version") == 1
    entries = suite.fetch("cases")
    raise Error, "Scheduled cases must be unique" unless entries.uniq == entries
    entries.each do |entry|
      raise Error, "Use case_id and an optional variant" unless (entry.keys - %w[case_id variant]).empty?
      BenchmarkCases.load_case(entry.fetch("case_id"), root)
    end
    entries
  end

  def self.fresh_targets(root: BenchmarkCases::ROOT, case_id: nil)
    cases(root: root).select { |entry| !case_id || entry.fetch("case_id") == case_id }.flat_map do |entry|
      item = BenchmarkCases.load_case(entry.fetch("case_id"), root)
      workflows = item.fetch("execution").fetch("workflows").select { |workflow| workflow.fetch("lane") == "fresh" }
      raise Error, "#{item.fetch('id')} has no fresh workflow" if workflows.empty?
      workflows.map do |workflow|
        plan = BenchmarkCases.plan(item, lane: "fresh", workflow: File.basename(workflow.fetch("path")), variant: entry["variant"], root: root)
        {"source_repo" => BenchmarkCases::REPOSITORY, "case_id" => item.fetch("id"),
         "fresh_workflow" => plan.fetch("workflow"), "fresh_inputs" => plan.fetch("inputs")}
      end
    end
  end

  def self.source_cases(root: BenchmarkCases::ROOT, case_id: nil)
    ids = cases(root: root).map { |entry| entry.fetch("case_id") }.uniq
    raise Error, "#{case_id} is not in the scheduled suite" if case_id && !ids.include?(case_id)
    ids.select { |id| !case_id || id == case_id }.map { |id| BenchmarkCases.load_case(id, root) }
  end
end

if $PROGRAM_NAME == __FILE__
  options = {ref: "main"}
  OptionParser.new do |parser|
    parser.on("--check") { options[:check] = true }
    parser.on("--collect") { options[:collect] = true }
    parser.on("--case ID") { |value| options[:case_id] = value }
    parser.on("--channel CHANNEL") { |value| options[:channel] = value }
    parser.on("--version TAG") { |value| options[:version] = value }
    parser.on("--ref REF") { |value| options[:ref] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--summary PATH") { |value| options[:summary] = value }
    parser.on("--dry-run") { options[:dry_run] = true }
  end.parse!
  begin
    targets = BenchmarkCadence.fresh_targets(case_id: options.delete(:case_id))
    raise BenchmarkCadence::Error, "No scheduled cases selected" if targets.empty?
    if options.delete(:collect)
      exit(NightlyCanaries::Runner.new.collect(summary: options.fetch(:summary), benchmarks: targets) ? 0 : 1)
    elsif options.delete(:check)
      puts "Validated #{targets.length} scheduled fresh workflows"
    else
      raise BenchmarkCadence::Error, "Use stable or canary" unless %w[stable canary].include?(options[:channel])
      raise BenchmarkCadence::Error, "Inspect the previous receipt before retrying a dispatch" if ENV.fetch("GITHUB_RUN_ATTEMPT", "1").to_i > 1 && !options[:dry_run]
      NightlyCanaries::Runner.new.dispatch(repository: BenchmarkCases::REPOSITORY, benchmarks: targets, **options)
    end
  rescue BenchmarkCadence::Error, BenchmarkCases::Error, NightlyCanaries::Error, KeyError => error
    abort error.message
  end
end
