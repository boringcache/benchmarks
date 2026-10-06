# frozen_string_literal: true

require_relative "benchmark-cases"
require_relative "benchmark-storage"

module FreshReport
  PROVIDERS = {"actions-cache" => "GitHub Actions", "boringcache" => "BoringCache"}.freeze
  STATES = {"success" => "succeeded", "failure" => "failed", "cancelled" => "cancelled", "skipped" => "skipped", "timed_out" => "failed"}.freeze

  def self.expected(case_id, provider: "both")
    raise BenchmarkCases::Error, "Unknown native provider #{provider}" unless provider == "both" || PROVIDERS.key?(provider)
    selected = provider == "both" ? PROVIDERS : PROVIDERS.slice(provider)
    selected.flat_map do |provider, label|
      %w[cold warm].map { |phase| {"case_id" => case_id, "strategy" => provider, "phase" => phase, "job_name" => "#{label} #{case_id} #{phase}"} }
    end
  end

  def self.reconcile(expected, jobs:, records: [], outcomes: [], run_url:)
    expected.map do |slot|
      matches = records.select { |record| record.values_at("strategy", "phase") == slot.values_at("strategy", "phase") }
      raise BenchmarkCases::Error, "Duplicate phase evidence" if matches.length > 1
      record = matches.first
      outcome = outcomes.find { |value| value.values_at("strategy", "phase") == slot.values_at("strategy", "phase") }
      job = jobs.find { |value| value.fetch("name") == slot.fetch("job_name") || value.fetch("name").end_with?(" / #{slot.fetch('job_name')}") }
      if !job && slot["phase"] == "warm"
        # GitHub can skip a matrix before expanding its provider jobs.
        job = jobs.find do |value|
          value["conclusion"] == "skipped" && (value["name"] == "warm" || value["name"].end_with?(" / warm"))
        end
      end
      conclusion = job && job["conclusion"]
      state = STATES[conclusion] || (job && job["status"] != "completed" ? job["status"] : "missing")
      # A successful job without its original phase record has missing evidence.
      state = "missing" if state == "succeeded" && !record
      if state == "succeeded" && slot["phase"] == "warm" && record["mode"] == "nx" && record.dig("cache", "hit") != true
        state = "cache-reuse-unverified"
      end
      timing = record&.fetch("timing", nil) || outcome&.fetch("timing", nil) || {}
      verified = record ? record.dig("verification", "passed") : outcome&.fetch("verification", nil)
      errors = Array(job && job["steps"]).select { |step| %w[failure cancelled].include?(step["conclusion"]) }
        .map { |step| {"step" => step.fetch("name"), "conclusion" => step.fetch("conclusion")} }
      slot.merge("state" => state, "job_conclusion" => conclusion, "timing" => timing,
        "verification" => verified.nil? ? "unrecorded" : verified,
        "storage_bytes" => record&.dig("cache", "storage_bytes"), "errors" => errors,
        "phase_record" => record, "outcome" => outcome, "evidence_links" => [job && job["html_url"], run_url].compact.uniq)
    end
  end

  def self.record_outcome(env = ENV)
    phase = env.fetch("BENCHMARK_PHASE") == "publish" ? "cold" : env.fetch("BENCHMARK_PHASE")
    phase = "commit" if env["BENCHMARK_LANE"] == "rolling"
    partial = File.file?("benchmark-partial.json") ? JSON.parse(File.read("benchmark-partial.json")) : {}
    value = {"strategy" => env.fetch("BENCHMARK_PROVIDER"), "phase" => phase,
      "case_id" => env.fetch("BENCHMARK_CASE_ID"), "benchmark_id" => env.fetch("BENCHMARK_ID"), "variant" => env.fetch("BENCHMARK_VARIANT", ""),
      "run_id" => env["GITHUB_RUN_ID"], "run_attempt" => env["GITHUB_RUN_ATTEMPT"],
      "step_outcome" => env.fetch("BENCHMARK_OUTCOME"), "timing" => partial.fetch("timing", {}),
      "verification" => partial["verification"]}
    BenchmarkCases.write_json("benchmark-outcome/outcome.json", value)
  end

  def self.report(item, input_dir:, output_dir:, jobs:, run_url:, variant: nil, suffix: "", provider: "both")
    recipe = NativeCase.resolve(item.dig("execution", "native"), variant)
    benchmark = recipe.fetch("benchmark_id") + suffix
    if ENV["GITHUB_ENV"]
      File.open(ENV.fetch("GITHUB_ENV"), "a") do |file|
        file.puts("BENCHMARK_ID=#{benchmark}")
        file.puts("BENCHMARK_VARIANT_SUFFIX=#{variant ? "-#{variant}" : ""}")
      end
    end
    payloads = Dir[File.join(input_dir, "**", "*.json")].map { |path| JSON.parse(File.read(path)) }
    records = payloads.select { |value| value.is_a?(Hash) && value["benchmark"] == benchmark && value["phase"] && value["lane"] == "fresh" }
    if ENV["GITHUB_RUN_ID"]
      records.select! { |value| value.dig("github", "run_id").to_s == ENV["GITHUB_RUN_ID"] && value.dig("github", "run_attempt").to_s == ENV.fetch("GITHUB_RUN_ATTEMPT") }
    end
    records.each do |record|
      unless record.dig("case", "case_id") == item.fetch("id") && record["variant"].to_s == variant.to_s
        raise BenchmarkCases::Error, "Phase evidence belongs to another case or variant"
      end
    end
    outcomes = payloads.select do |value|
      value.is_a?(Hash) && value.key?("step_outcome") && value["benchmark_id"] == benchmark && value["variant"].to_s == variant.to_s
    end
    if ENV["GITHUB_RUN_ID"]
      outcomes.select! { |value| value["run_id"].to_s == ENV["GITHUB_RUN_ID"] && value["run_attempt"].to_s == ENV.fetch("GITHUB_RUN_ATTEMPT") }
    end
    records = records.map { |record| BenchmarkStorage.apply(record, payloads.select { |value| value.is_a?(Hash) && value["kind"] == "post-publication-storage" }) }
    observations = reconcile(expected(item.fetch("id"), provider: provider), jobs: jobs, records: records, outcomes: outcomes, run_url: run_url)
    manifest = {"schema_version" => 1, "case_id" => item.fetch("id"), "variant" => variant,
      "run_url" => run_url, "observations" => observations}
    BenchmarkCases.write_json(File.join(output_dir, "run-manifest.json"), manifest)
    # Preserve the canonical lane files for existing readers when measurements exist.
    unless records.empty?
      Dir.mktmpdir("fresh-phases-") do |directory|
        records.each_with_index { |record, index| BenchmarkCases.write_json(File.join(directory, "#{index}.json"), record) }
        BenchmarkReport.summarize("input_dir" => directory, "output_dir" => output_dir,
          "title" => "#{item.fetch('id')} fresh measurements", "baseline_strategy" => provider == "both" ? "actions-cache" : provider)
      end
    end
    lines = ["## #{item.fetch('id')} fresh run", "", "[Original run](#{run_url})", "",
      "| Provider | Phase | State | Output verified | Build | Cache + build | Storage bytes |",
      "| --- | --- | --- | --- | ---: | ---: | ---: |"]
    observations.each do |value|
      lines << "| #{value['strategy']} | #{value['phase']} | #{value['state']} | #{value['verification']} | #{BenchmarkReport.seconds(value.dig('timing', 'build_seconds'))} | #{BenchmarkReport.seconds(value.dig('timing', 'total_seconds'))} | #{value['storage_bytes'] || 'unmeasured'} |"
    end
    lines += ["", "Job and post-step failures remain failures even when output verification completed. Missing measurements are unmeasured.", ""]
    content = lines.join("\n")
    File.write(File.join(output_dir, "run-report.md"), content)
    File.open(ENV["GITHUB_STEP_SUMMARY"], "a") { |file| file.write(content) } if ENV["GITHUB_STEP_SUMMARY"]
    manifest
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV.shift == "outcome"
    FreshReport.record_outcome
  else
    require_relative "nightly-canaries"
    runner = NightlyCanaries::Runner.new
    repository, run_id, attempt = ENV.values_at("GITHUB_REPOSITORY", "GITHUB_RUN_ID", "GITHUB_RUN_ATTEMPT")
    jobs = runner.jobs(repository, run_id, attempt)
    FreshReport.report(BenchmarkCases.load_case(ENV.fetch("CASE_ID")), input_dir: "phase-evidence", output_dir: "benchmark-results",
      jobs: jobs, run_url: "https://github.com/#{repository}/actions/runs/#{run_id}",
      variant: ENV.fetch("VARIANT", "").then { |value| value.empty? ? nil : value }, suffix: ENV.fetch("BENCHMARK_SUFFIX", ""),
      provider: ENV.fetch("PROVIDER", "both"))
  end
end
