# frozen_string_literal: true

require_relative "benchmark-cases"
require_relative "benchmark-storage"
require_relative "fresh-report"
require_relative "project-runs"

module ProjectReport
  def self.build(directory)
    values = Dir[File.join(directory, "**", "*.json")].filter_map do |path|
      value = JSON.parse(File.read(path))
      value if value.is_a?(Hash)
    end
    storage = values.select { |value| value["kind"] == "post-publication-storage" }
    values = values.flat_map { |value| value["runs"].is_a?(Array) ? value.fetch("runs") : [value] }
    phases = values.select { |value| value["benchmark"] && value["phase"] && value.dig("case", "case_id") }
    phases.uniq.map { |value| BenchmarkStorage.apply(value, storage) }
  end

  def self.observations(records, selections:, project:, lane:, jobs: [], run_url:)
    ProjectRuns.matrix(selections, case_id: project, lane: lane).values.flat_map { |matrix| matrix.fetch("include") }.flat_map do |selection|
      item = BenchmarkCases.load_case(ProjectRuns.selection_case(selection))
      inputs = selection.fetch("inputs")
      plan = BenchmarkCases.plan(item, workflow: selection.fetch("workflow"), inputs: inputs)
      providers = item.dig("comparison", "providers")
      if selection.fetch("workflow").start_with?("obs-studio-obs-")
        providers = [selection.fetch("workflow").include?("actions-cache") ? "actions-cache" : "boringcache"]
      end
      variant = inputs["variant"] || inputs["cache_tool"]
      phases = records.select { |record| record.dig("case", "case_id") == item.fetch("id") && (!variant || record["variant"].to_s == variant.to_s) }
      if selection.fetch("workflow") == "native-fresh-benchmark.yml"
        recipe = NativeCase.resolve(item.dig("execution", "native"), variant)
        benchmark = recipe.fetch("benchmark_id") + inputs.fetch("benchmark_id_suffix", "")
        phases = phases.select { |record| record["benchmark"] == benchmark }
        selected_jobs = jobs.select { |job| job.fetch("name").start_with?("#{selection.fetch('label')} /") }
        FreshReport.reconcile(FreshReport.expected(item.fetch("id"), provider: inputs.fetch("provider", "both")), jobs: selected_jobs, records: phases, run_url: run_url)
          .map { |value| value.merge("variant" => variant || item.fetch("id"), "runner_class" => inputs.fetch("runner_label", "ubuntu-latest")) }
      else
        providers.product(plan.fetch("phases")).map do |provider, phase|
          matches = phases.select { |record| record.values_at("strategy", "phase") == [provider, phase] }
          raise BenchmarkCases::Error, "Duplicate project phase evidence" if matches.length > 1
          value = matches.first
          {"variant" => variant || item.fetch("id"), "strategy" => provider, "phase" => phase,
            "state" => value ? "recorded" : "missing", "verification" => value&.dig("verification", "passed") || "unrecorded",
            "timing" => value&.fetch("timing") || {}, "storage_bytes" => value&.dig("cache", "storage_bytes"), "phase_record" => value}
        end
      end
    end
  end

  def self.markdown(observations, project:)
    lines = ["## #{project} measurements", "", "| Workload | Runner | Provider | Phase | State | Output verified | Build (s) | Cache + build (s) | Storage (bytes) |", "| --- | --- | --- | --- | --- | --- | ---: | ---: | ---: |"]
    observations.sort_by { |value| [value["variant"].to_s, value["runner_class"].to_s, value["strategy"], value["phase"]] }.each do |value|
      lines << "| #{value['variant'] || project} | #{value['runner_class'] || 'unrecorded'} | #{value['strategy']} | #{value['phase']} | #{value['state']} | #{value['verification']} | #{value.dig('timing', 'build_seconds') || 'unmeasured'} | #{value.dig('timing', 'total_seconds') || value.dig('timing', 'build_and_reuse_seconds') || 'unmeasured'} | #{value['storage_bytes'] || 'unmeasured'} |"
    end
    lines += ["", "Publication: unreviewed. Storage without a measurement: unmeasured.", ""]
    lines.join("\n")
  end
end

if $PROGRAM_NAME == __FILE__
  require_relative "nightly-canaries"
  records = ProjectReport.build("project-evidence")
  jobs = NightlyCanaries::Runner.new.jobs(ENV.fetch("GITHUB_REPOSITORY"), ENV.fetch("GITHUB_RUN_ID"), ENV.fetch("GITHUB_RUN_ATTEMPT"))
  run_url = "https://github.com/#{ENV.fetch('GITHUB_REPOSITORY')}/actions/runs/#{ENV.fetch('GITHUB_RUN_ID')}"
  observations = ProjectReport.observations(records, selections: JSON.parse(ENV.fetch("SELECTIONS")),
    project: ENV.fetch("CASE_ID"), lane: ENV.fetch("LANE"), jobs: jobs, run_url: run_url)
  BenchmarkCases.write_json("project-results/measurements.json", {"schema_version" => 1, "records" => records, "observations" => observations, "publication" => "unreviewed"})
  File.open(ENV.fetch("GITHUB_STEP_SUMMARY"), "a") { |file| file.write(ProjectReport.markdown(observations, project: ENV.fetch("CASE_ID"))) }
end
