#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "benchmark-cases"
require_relative "nightly-canaries"
require_relative "benchmark-cli"
require_relative "project-runs"
require_relative "benchmark-baseline"

module BenchmarkCadence
  class Error < StandardError; end

  def self.freeze_runs(version, runs, root: BenchmarkCases::ROOT, cadence: "fresh", series_prefix: "cadence-#{ENV.fetch('GITHUB_RUN_ID', Time.now.utc.strftime('%Y%m%d%H%M%S'))}")
    sha = BenchmarkCases.command("git", "rev-parse", "HEAD", chdir: root).strip
    tracked = BenchmarkCases.command("git", "status", "--porcelain", "--untracked-files=no", chdir: root)
    raise Error, "Commit harness changes before planning scheduled runs" unless tracked.empty?
    targets = fresh_targets(root: root)
    series = {}
    runs.each_with_index do |run, index|
      target = targets.find do |entry|
        entry.fetch("fresh_workflow") == run.fetch("workflow") && entry.fetch("fresh_inputs") == run.fetch("inputs")
      end
      raise Error, "Scheduled target differs from the selected suite" unless target
      item = BenchmarkCases.load_case(target.fetch("case_id"), root)
      selection = BenchmarkCases.plan(item, workflow: run.fetch("workflow"), inputs: run.fetch("inputs"), root: root)
      workflow = item.dig("execution", "workflows").find { |entry| File.basename(entry.fetch("path")) == run.fetch("workflow") }
      variant = workflow["variant_input"] && run.fetch("inputs")[workflow.fetch("variant_input")]
      identity = {"harness_sha" => sha, "case_id" => item.fetch("id"), "definition_sha256" => BenchmarkCases.definition_sha256(item, root: root)}
      key = [item.fetch("id"), variant, selection.fetch("phases"), run.fetch("inputs")]
      series[key] ||= Dir.mktmpdir("scheduled-series-") do |directory|
        BenchmarkSeries.create(item, directory: File.join(directory, "series"),
          series: "#{series_prefix}-#{index + 1}", lane: "fresh", samples: 1, variant: variant,
          definition_sha256: identity.fetch("definition_sha256"), phases: selection.fetch("phases"),
          workflow_inputs: run.fetch("inputs").merge("cli_version" => version, "cadence" => cadence))
      end
      run["series"] = series.fetch(key)
      run["harness_sha"] = sha
      run["inputs"] = run.fetch("inputs").merge("cadence" => cadence, "series_id" => run.fetch("series").fetch("series_id"),
        "sample" => "1", "expected_identity" => JSON.generate(identity))
    end
  end

  def self.cases(root: BenchmarkCases::ROOT)
    suite = JSON.parse(File.read(File.join(root, "suites/scheduled.json")))
    raise Error, "Unsupported scheduled suite version" unless suite.fetch("schema_version") == 1
    entries = suite.fetch("cases")
    raise Error, "Scheduled cases must be unique" unless entries.uniq == entries
    entries.each do |entry|
      raise Error, "Use case_id, an optional variant, lanes and workflow inputs" unless (entry.keys - %w[case_id variant lanes inputs]).empty?
      lanes = entry.fetch("lanes", %w[fresh rolling])
      raise Error, "Scheduled lanes must select fresh or rolling" unless lanes.is_a?(Array) && !lanes.empty? && (lanes - %w[fresh rolling]).empty? && lanes.uniq == lanes
      settings = entry.fetch("inputs", {})
      raise Error, "Scheduled workflow inputs must be strings" unless settings.is_a?(Hash) && settings.all? { |key, value| key.is_a?(String) && value.is_a?(String) }
      BenchmarkCases.load_case(entry.fetch("case_id"), root)
    end
    entries
  end

  def self.fresh_targets(root: BenchmarkCases::ROOT, case_id: nil)
    cases(root: root).select { |entry| entry.fetch("lanes", %w[fresh rolling]).include?("fresh") && (!case_id || entry.fetch("case_id") == case_id) }.flat_map do |entry|
      item = BenchmarkCases.load_case(entry.fetch("case_id"), root)
      workflows = item.fetch("execution").fetch("workflows").select { |workflow| workflow.fetch("lane") == "fresh" }
      raise Error, "#{item.fetch('id')} has no fresh workflow" if workflows.empty?
      workflows.map do |workflow|
        plan = BenchmarkCases.plan(item, lane: "fresh", workflow: File.basename(workflow.fetch("path")), variant: entry["variant"], inputs: entry.fetch("inputs", {}), root: root)
        {"source_repo" => BenchmarkCases::REPOSITORY, "case_id" => item.fetch("id"),
         "fresh_workflow" => plan.fetch("workflow"), "fresh_inputs" => plan.fetch("inputs")}
      end
    end
  end

  def self.active_cases(value = ENV.fetch("BENCHMARK_ACTIVE_CASES", "[]"), root: BenchmarkCases::ROOT)
    ids = JSON.parse(value.empty? ? "[]" : value)
    known = cases(root: root).map { |entry| entry.fetch("case_id") }.uniq
    raise Error, "BENCHMARK_ACTIVE_CASES must list scheduled case IDs" unless ids.is_a?(Array) && ids.all? { |id| known.include?(id) } && ids.uniq == ids
    ids
  rescue JSON::ParserError
    raise Error, "BENCHMARK_ACTIVE_CASES must be a JSON array"
  end

  def self.source_cases(root: BenchmarkCases::ROOT, case_id: nil)
    ids = cases(root: root).map { |entry| entry.fetch("case_id") }.uniq
    raise Error, "#{case_id} is not in the scheduled suite" if case_id && !ids.include?(case_id)
    ids.select { |id| !case_id || id == case_id }.map { |id| BenchmarkCases.load_case(id, root) }
  end

  def self.source_project(case_id, root: BenchmarkCases::ROOT)
    selected = source_cases(root: root, case_id: case_id).fetch(0)
    source_cases(root: root).select { |item| item.dig("source", "repository") == selected.dig("source", "repository") }
  end

  def self.rolling_targets(root: BenchmarkCases::ROOT, case_id:, inputs: {}, item: nil)
    source_cases(root: root, case_id: case_id)
    item ||= BenchmarkCases.load_case(case_id, root)
    workflows = item.fetch("execution").fetch("workflows").select { |workflow| workflow.fetch("lane") == "rolling" }
    if (selected = item.dig("execution", "rolling_workflow"))
      workflows.select! { |workflow| workflow.fetch("path") == selected }
    end
    raise Error, "#{case_id} has no rolling workflow" if workflows.empty?
    cases(root: root).select { |entry| entry.fetch("case_id") == case_id && entry.fetch("lanes", %w[fresh rolling]).include?("rolling") }.flat_map do |entry|
      workflows.map do |workflow|
        BenchmarkCases.plan(item, lane: "rolling", workflow: File.basename(workflow.fetch("path")),
          variant: entry["variant"], inputs: entry.fetch("inputs", {}).merge(inputs), root: root)
      end
    end.uniq
  end

  def self.verify_cli(version, runs, probe: method(:cli_help))
    return unless runs.any? { |run| run.fetch("workflow").start_with?("reapi-") }
    %w[moon pants buck2 sbt].each do |tool|
      help = probe.call(version, tool)
      unless help.include?("Usage: boringcache #{tool}")
        raise Error, "#{version} does not support native #{tool} required by the REAPI cases; no builds dispatched"
      end
    end
    nil
  end

  def self.cli_help(version, command)
    require_relative "reapi-setup"
    platform = RbConfig::CONFIG.fetch("host_os")
    asset = if platform.include?("darwin")
      "boringcache-macos-universal"
    elsif platform.include?("linux")
      "boringcache-linux-#{RbConfig::CONFIG.fetch('host_cpu').match?(/aarch64|arm64/) ? 'arm64' : 'amd64'}"
    else
      raise Error, "CLI capability inspection requires Linux or macOS"
    end
    Dir.mktmpdir("benchmark-cli-") do |directory|
      binary = File.join(directory, "boringcache")
      ReapiSetup.download("boringcache/cli", version, asset, "boringcache", destination: binary)
      BenchmarkCases.command(binary, command, "--help")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  selection = BenchmarkCLI.selection
  options = {ref: "main", channel: selection.fetch("channel"), version: selection.fetch("version")}
  OptionParser.new do |parser|
    parser.on("--active-only") { options[:active_only] = true }
    parser.on("--check") { options[:check] = true }
    parser.on("--collect") { options[:collect] = true }
    parser.on("--case ID") { |value| options[:case_id] = value }
    parser.on("--channel CHANNEL") { |value| options[:channel] = value == "configured" ? selection.fetch("channel") : value }
    parser.on("--version TAG") { |value| options[:version] = value.empty? ? selection.fetch("version") : value }
    parser.on("--cadence CADENCE") { |value| options[:cadence] = value }
    parser.on("--ref REF") { |value| options[:ref] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--summary PATH") { |value| options[:summary] = value }
    parser.on("--dry-run") { options[:dry_run] = true }
  end.parse!
  begin
    targets = BenchmarkCadence.fresh_targets(case_id: options.delete(:case_id))
    if options.delete(:active_only) && ENV["BENCHMARK_CADENCE_ACTIVE"] != "true"
      targets.select! { |target| BenchmarkCadence.active_cases.include?(target.fetch("case_id")) }
    end
    raise BenchmarkCadence::Error, "No scheduled cases selected" if targets.empty?
    if options.delete(:collect)
      exit(NightlyCanaries::Runner.new.collect(summary: options.fetch(:summary), output: options[:output],
        channel: options.fetch(:channel), expected_version: options.fetch(:version), cadence: options.fetch(:cadence, "daily"), benchmarks: targets,
        baseline: BenchmarkBaseline.selection) ? 0 : 1)
    elsif options.delete(:check)
      puts "Validated #{targets.length} scheduled fresh workflows"
    else
      raise BenchmarkCadence::Error, "Use stable or canary" unless %w[stable canary].include?(options[:channel])
      raise BenchmarkCadence::Error, "Inspect the previous receipt before retrying a dispatch" if ENV.fetch("GITHUB_RUN_ATTEMPT", "1").to_i > 1 && !options[:dry_run]
      cadence = options.delete(:cadence) || "fresh"
      raise BenchmarkCadence::Error, "Use nightly or fresh cadence" unless %w[nightly fresh].include?(cadence)
      NightlyCanaries::Runner.new.dispatch(repository: BenchmarkCases::REPOSITORY, benchmarks: targets,
        preflight: ->(version, runs) { BenchmarkCadence.verify_cli(version, runs); BenchmarkCadence.freeze_runs(version, runs, cadence: cadence); runs.replace(ProjectRuns.group(runs, lane: "fresh")) }, **options)
    end
  rescue BenchmarkCadence::Error, BenchmarkCases::Error, NightlyCanaries::Error, KeyError => error
    abort error.message
  end
end
