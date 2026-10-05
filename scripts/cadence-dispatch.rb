#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "benchmark-cadence"

# The parent validates the entire suite and resolves one release before the
# matrix starts. Each child records its request independently, including errors.
module CadenceDispatch
  class Error < StandardError; end

  def self.matrix(plan)
    raise Error, "Expected a validated dispatch plan" unless plan.fetch("state") == "planned"
    {"include" => plan.fetch("runs").each_with_index.map do |run, index|
      {"index" => index, "label" => NightlyCanaries::Runner.new.workload_name(run)}
    end}
  end

  def self.dispatch(plan, index:, output:, runner: NightlyCanaries::Runner.new)
    raise Error, "Inspect the previous receipt before retrying a dispatch" if ENV.fetch("GITHUB_RUN_ATTEMPT", "1").to_i > 1
    matrix(plan)
    raise Error, "Invalid dispatch target index" unless index.is_a?(Integer) && index >= 0 && index < plan.fetch("runs").length
    run = plan.fetch("runs").fetch(index).dup
    record = plan.except("runs").merge("runs" => [run], "target_index" => index, "state" => "dispatching")
    # A lost HTTP response cannot establish whether GitHub accepted the request.
    run["state"] = "requesting"
    runner.write(output, record)
    result = runner.api("repos/#{run.fetch('repository')}/actions/workflows/#{run.fetch('workflow')}/dispatches",
      body: {"ref" => plan.fetch("ref"), "inputs" => run.fetch("inputs").merge("cli_version" => plan.fetch("cli_version")), "return_run_details" => true})
    id = result["workflow_run_id"]
    raise Error, "Dispatch returned no run ID; inspect the retained request before retrying" unless id.is_a?(Integer) && id.positive?
    run.merge!("id" => id, "url" => "https://github.com/#{run.fetch('repository')}/actions/runs/#{id}", "state" => "requested")
    record["state"] = "requested"
    runner.write(output, record)
    record
  rescue StandardError => error
    if record
      run["state"] = "request-unknown" unless run["id"]
      run["error"] = error.message
      record.merge!("state" => "dispatch-failed", "error" => error.message)
      runner.write(output, record)
    end
    raise
  end

  def self.combine(plan, receipts, dry_run: false)
    matrix(plan)
    result = Marshal.load(Marshal.dump(plan))
    seen = []
    receipts.each do |receipt|
      index = receipt.fetch("target_index")
      raise Error, "Duplicate or invalid dispatch receipt" unless index.is_a?(Integer) && index >= 0 && index < result.fetch("runs").length && !seen.include?(index)
      seen << index
      %w[cli_version channel ref].each do |key|
        raise Error, "Dispatch receipt #{key} differs from the plan" unless receipt.fetch(key) == plan.fetch(key)
      end
      raise Error, "Expected one target per receipt" unless receipt.fetch("runs").length == 1
      run = receipt.fetch("runs").first
      expected = plan.fetch("runs").fetch(index)
      %w[repository workflow inputs].each do |key|
        raise Error, "Dispatch receipt target differs from the plan" unless run.fetch(key) == expected.fetch(key)
      end
      if run["state"] == "requested"
        raise Error, "Requested run lacks its GitHub ID" unless run["id"].is_a?(Integer) && run["id"].positive?
      end
      result.fetch("runs")[index] = run
    end
    result["state"] = if dry_run && receipts.empty?
      "planned"
    elsif result.fetch("runs").all? { |run| run["state"] == "requested" }
      "requested"
    else
      "dispatch-failed"
    end
    result
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  OptionParser.new do |parser|
    parser.on("--plan PATH") { |value| options[:plan] = value }
    parser.on("--matrix") { options[:matrix] = true }
    parser.on("--index N", Integer) { |value| options[:index] = value }
    parser.on("--receipts PATH") { |value| options[:receipts] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--summary PATH") { |value| options[:summary] = value }
    parser.on("--dry-run") { options[:dry_run] = true }
  end.parse!
  begin
    plan = JSON.parse(File.read(options.fetch(:plan)))
    if options[:matrix]
      puts JSON.generate(CadenceDispatch.matrix(plan))
    elsif options.key?(:index)
      CadenceDispatch.dispatch(plan, index: options.fetch(:index), output: options.fetch(:output))
    else
      receipts = Dir.glob(File.join(options.fetch(:receipts), "**/target-*.json")).sort.map { |path| JSON.parse(File.read(path)) }
      record = CadenceDispatch.combine(plan, receipts, dry_run: options[:dry_run])
      runner = NightlyCanaries::Runner.new
      runner.write(options.fetch(:output), record)
      runner.write_summary(options[:summary], record)
      exit(record.fetch("state") == "dispatch-failed" ? 1 : 0)
    end
  rescue CadenceDispatch::Error, NightlyCanaries::Error, KeyError, JSON::ParserError => error
    abort error.message
  end
end
