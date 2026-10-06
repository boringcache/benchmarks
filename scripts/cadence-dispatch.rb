#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "benchmark-cadence"

# The parent validates the entire suite and resolves one release before the
# matrix starts. Each child records its request independently, including errors.
module CadenceDispatch
  class Error < StandardError; end

  def self.materialize(record, directory:)
    record.fetch("runs").flat_map { |run| ProjectRuns.expand(run) }.each do |run|
      series = run.fetch("series")
      raise Error, "Scheduled series digest differs from its plan" unless series.fetch("plan_sha256") == BenchmarkSeries.digest(series)
      %w[case_id series_id].each do |key|
        raise Error, "Invalid scheduled #{key}" unless series.fetch(key).match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
      end
      workflow = run.fetch("workflow")
      raise Error, "Invalid scheduled workflow" unless workflow.match?(/\A[a-z0-9-]+\.yml\z/)
      target = File.join(directory, series.fetch("case_id"), series.fetch("series_id"))
      receipt = {"schema_version" => 1, "case_id" => series.fetch("case_id"), "repository" => run.fetch("repository"),
        "workflow" => workflow, "lane" => series.fetch("lane"), "ref" => record.fetch("ref"), "state" => run.fetch("state"),
        "requested_at" => record["created_at"],
        "inputs" => run.fetch("inputs").merge("cli_version" => record.fetch("cli_version")),
        "run_id" => run["id"], "run_url" => run["url"], "harness_sha" => run.fetch("harness_sha"), "error" => run["error"]}
      {"series.json" => series, "dispatches/1-#{workflow}.json" => receipt}.each do |name, value|
        path = File.join(target, name)
        raise Error, "Retained scheduled record differs: #{path}" if File.file?(path) && JSON.parse(File.read(path)) != value
        BenchmarkCases.write_json(path, value)
      end
      BenchmarkSeries.report(target)
    end
  end

  def self.matrix(plan)
    raise Error, "Expected a validated dispatch plan" unless plan.fetch("state") == "planned"
    plan.fetch("runs").flat_map { |run| ProjectRuns.expand(run) }.each do |run|
      next unless run["series"]
      series = run.fetch("series")
      identity = JSON.parse(run.fetch("inputs").fetch("expected_identity"))
      unless series.fetch("plan_sha256") == BenchmarkSeries.digest(series) &&
          identity == {"harness_sha" => run.fetch("harness_sha"), "case_id" => series.fetch("case_id"), "definition_sha256" => series.fetch("definition_sha256")} &&
          run.dig("inputs", "series_id") == series.fetch("series_id") && run.dig("inputs", "sample") == "1" &&
          series.fetch("workflow_inputs") == run.fetch("inputs").except("series_id", "sample", "expected_identity").merge("cli_version" => plan.fetch("cli_version"))
        raise Error, "Scheduled request differs from its frozen series"
      end
    end
    {"include" => plan.fetch("runs").each_with_index.map do |run, index|
      {"index" => index, "label" => NightlyCanaries::Runner.new.workload_name(run)}
    end}
  end

  def self.pin(plan, run_id:, runner: NightlyCanaries::Runner.new)
    matrix(plan)
    raise Error, "Invalid cadence run ID" unless run_id.to_s.match?(/\A[1-9][0-9]*\z/)
    selections = plan.fetch("runs").flat_map { |run| ProjectRuns.expand(run) }
    hashes = selections.map { |run| run.fetch("harness_sha") }.uniq
    raise Error, "The batch must use one exact harness commit" unless hashes.length == 1 && hashes.first.match?(/\A[0-9a-f]{40}\z/)
    reference = "benchmark-#{run_id}"
    path = "repos/#{BenchmarkCases::REPOSITORY}/git/ref/tags/#{reference}"
    existing = begin
      runner.api(path)
    rescue NightlyCanaries::Error => error
      raise unless error.message.include?("HTTP 404")
      nil
    end
    if existing
      raise Error, "Cadence reference already points to another harness" unless existing.dig("object", "sha") == hashes.first
    else
      runner.api("repos/#{BenchmarkCases::REPOSITORY}/git/refs",
        body: {"ref" => "refs/tags/#{reference}", "sha" => hashes.first})
    end
    raise Error, "Cadence reference did not retain the planned harness" unless runner.api(path).dig("object", "sha") == hashes.first
    plan.merge("ref" => reference)
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
      %w[harness_sha series selections].each do |key|
        raise Error, "Dispatch receipt #{key} differs from the plan" unless run[key] == expected[key]
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
    parser.on("--pin RUN_ID") { |value| options[:pin] = value }
    parser.on("--matrix") { options[:matrix] = true }
    parser.on("--index N", Integer) { |value| options[:index] = value }
    parser.on("--receipts PATH") { |value| options[:receipts] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--summary PATH") { |value| options[:summary] = value }
    parser.on("--dry-run") { options[:dry_run] = true }
    parser.on("--materialize DIRECTORY") { |value| options[:materialize] = value }
  end.parse!
  begin
    plan = JSON.parse(File.read(options.fetch(:plan)))
    if options[:pin]
      BenchmarkCases.write_json(options.fetch(:plan), CadenceDispatch.pin(plan, run_id: options.fetch(:pin)))
    elsif options[:materialize]
      CadenceDispatch.materialize(plan, directory: options.fetch(:materialize))
    elsif options[:matrix]
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
  rescue CadenceDispatch::Error, NightlyCanaries::Error, BenchmarkCases::Error, BenchmarkSeries::Error, KeyError, JSON::ParserError => error
    abort error.message
  end
end
