# frozen_string_literal: true

require "json"

module ProjectRuns
  def self.group(runs, lane:, case_id: nil)
    runs.group_by { |run| case_id || run.dig("series", "case_id") || run.dig("inputs", "case_id") }.flat_map do |id, selections|
      supported = selections.all? do |run|
        run.fetch("workflow") == "native-#{lane}-benchmark.yml" ||
          (lane == "fresh" && run.fetch("workflow").start_with?("obs-studio-obs-"))
      end
      next selections unless id && selections.length > 1 && supported
      [{"repository" => selections.first.fetch("repository"), "workflow" => "project-#{lane}.yml",
        "inputs" => {"case_id" => id, **(lane == "fresh" ? {"cadence" => selections.first.dig("inputs", "cadence") || "fresh"} : {}), "selections" => JSON.generate(selections.map { |run| run.slice("workflow", "inputs") })},
        "state" => selections.first.fetch("state", "planned"), "selections" => selections}]
    end
  end

  def self.expand(run)
    Array(run["selections"] || [run]).map do |selection|
      selection.merge(run.slice("id", "url", "state", "source_sha")).merge("project_grouped" => !!run["selections"])
    end
  end

  def self.matrix(selections, case_id:, lane:)
    raise "Use fresh or rolling" unless %w[fresh rolling].include?(lane)
    raise "Expected at least one project selection" unless selections.is_a?(Array) && !selections.empty? && selections.length <= 12
    allowed = ["native-#{lane}-benchmark.yml"]
    allowed += %w[obs-studio-obs-actions-cache.yml obs-studio-obs-boringcache.yml] if lane == "fresh" && case_id == "obs-studio"
    values = selections.map do |selection|
      workflow, inputs = selection.values_at("workflow", "inputs")
      raise "Unregistered project workflow" unless allowed.include?(workflow)
      raise "Project inputs must be strings" unless inputs.is_a?(Hash) && inputs.all? { |key, value| key.is_a?(String) && value.is_a?(String) }
      raise "Selection belongs to another project" if workflow.start_with?("native-") && inputs["case_id"] != case_id
      {"workflow" => workflow, "label" => inputs["variant"] || inputs["cache_tool"] || case_id, "inputs" => inputs}
    end
    raise "Duplicate project selection" unless values.uniq.length == values.length
    values.group_by { |value| value.fetch("workflow") }.transform_values { |rows| {"include" => rows} }
  end
end
