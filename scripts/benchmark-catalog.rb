# frozen_string_literal: true

require_relative "benchmark-cases"

module BenchmarkCatalog
  def self.build(root: BenchmarkCases::ROOT)
    inventory_path = File.join(root, "migration", "evidence.json")
    exports = File.file?(inventory_path) ? JSON.parse(File.read(inventory_path)).fetch("exports") : []
    evidence = exports.to_h { |entry| [[entry.fetch("repository"), entry.fetch("run_id").to_s], entry] }
    series = Dir[File.join(root, "results", "*", "*", "series.json")].sort.map do |path|
      entry(File.dirname(path), root: root, evidence: evidence)
    end
    {"schema_version" => 1, "repository" => BenchmarkCases::REPOSITORY,
      "scope" => "Canonical series; historical index and reviewed website selections remain separate",
      "series" => series}
  end

  def self.entry(directory, root:, evidence:)
    path = directory.delete_prefix(root + "/")
    case_id, series_id = path.split("/").last(2)
    base = {"case_id" => case_id, "series_id" => series_id, "plan_path" => "#{path}/series.json"}
    plan = BenchmarkSeries.load(directory)
    raise BenchmarkSeries::Error, "Series identity differs from its directory" unless plan.values_at("case_id", "series_id") == [case_id, series_id]
    BenchmarkCases.load_case(case_id, root)
    report = BenchmarkSeries.report(directory, write: false)
    receipts = Dir[File.join(directory, "dispatches", "*.json")].sort.map do |file|
      receipt = JSON.parse(File.read(file))
      raise BenchmarkSeries::Error, "Dispatch receipt belongs to another case or repository" unless receipt.values_at("case_id", "repository") == [case_id, BenchmarkCases::REPOSITORY]
      receipt.slice("case_id", "repository", "workflow", "lane", "inputs", "ref", "state", "requested_at", "run_id", "run_url")
    end
    run_ids = (report.fetch("records").map { |record| record.dig("github", "run_id").to_s } +
      report.fetch("completions").map { |completion| completion.fetch("run_id") } +
      receipts.filter_map { |receipt| receipt["run_id"]&.to_s }).reject(&:empty?).uniq
    failed = !report.fetch("failures").empty? || !report.fetch("failed_completions").empty?
    state = if failed
      "failed"
    elsif report.fetch("complete") && report.fetch("execution_verified")
      "completed"
    elsif !report.fetch("records").empty? || !report.fetch("completions").empty?
      "incomplete"
    elsif !receipts.empty?
      "requested"
    else
      "planned"
    end
    report_file = File.join(directory, "report.json")
    report_state = if !File.file?(report_file)
      "missing"
    elsif JSON.parse(File.read(report_file)) == report
      "current"
    else
      "stale"
    end
    archives = run_ids.filter_map { |id| evidence[[BenchmarkCases::REPOSITORY, id]] }.map do |archive|
      archive.slice("repository", "run_id", "inventory_state", "verified_files", "gaps", "scope",
        "unavailable_workflow_evidence", "release_url", "bundle_url", "bundle_bytes", "sha256", "publication_verification")
    end
    base.merge(plan.slice("lane", "variant", "sample_count", "comparison", "source", "plan_sha256", "definition_sha256"),
      "state" => state, "publication" => report.fetch("publication"),
      "valid_for_comparison" => report.fetch("valid_for_comparison"),
      "execution_verified" => report.fetch("execution_verified"),
      "methodology_issues" => report.fetch("methodology_issues"),
      "missing_observations" => report.fetch("missing"), "summaries" => report.fetch("summaries"),
      "dispatches" => receipts,
      "completions" => report.fetch("completions"),
      "report_state" => report_state, "report_path" => report_state == "current" ? "#{path}/report.json" : nil,
      "evidence" => archives, "runs_without_archives" => run_ids - archives.map { |archive| archive.fetch("run_id").to_s })
  rescue BenchmarkSeries::Error, BenchmarkCases::Error, JSON::ParserError, KeyError => error
    base.merge("state" => "invalid", "publication" => "unreviewed", "valid_for_comparison" => false,
      "execution_verified" => false, "error" => error.message)
  end
end
