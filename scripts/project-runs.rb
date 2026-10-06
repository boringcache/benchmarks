# frozen_string_literal: true

require "json"

module ProjectRuns
  def self.group(runs, lane:, case_id: nil)
    runs.group_by { |run| case_id || project(selection_case(run)) }.flat_map do |id, selections|
      if lane == "rolling" && selections.length > 1 && selections.all? { |run| run.fetch("workflow") == "obs-rolling-benchmark.yml" }
        inputs = selections.map { |run| run.fetch("inputs").except("cache_tool") }.uniq
        raise "OBS rolling selections must share their source and cache scope" unless inputs.length == 1
        next [selections.first.merge("inputs" => inputs.first.merge("cache_tool" => "all"), "selections" => selections)]
      end
      supported = selections.all? do |run|
        run.fetch("workflow") == "native-#{lane}-benchmark.yml" ||
          (lane == "fresh" && %w[nix-fresh-benchmark.yml zed-zed-cargo-product.yml].include?(run.fetch("workflow"))) ||
          (lane == "fresh" && run.fetch("workflow").start_with?("obs-studio-obs-")) ||
          (lane == "rolling" && %w[nix-rolling-benchmark.yml zed-zed-cargo-rolling-auto.yml].include?(run.fetch("workflow")))
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

  def self.selection_case(selection)
    selection.dig("series", "case_id") || selection.dig("inputs", "case_id") ||
      {"zed-zed-cargo-product.yml" => "zed", "zed-zed-cargo-rolling-auto.yml" => "zed", "obs-studio-obs-actions-cache.yml" => "obs-studio", "obs-studio-obs-boringcache.yml" => "obs-studio", "obs-rolling-benchmark.yml" => "obs-studio"}.fetch(selection.fetch("workflow"))
  end

  def self.project(id)
    item = JSON.parse(File.read(File.expand_path("../cases/#{id}/case.json", __dir__)))
    item.dig("source", "repository").split("/").last
  end

  def self.matrix(selections, case_id:, lane:)
    raise "Use fresh or rolling" unless %w[fresh rolling].include?(lane)
    raise "Expected at least one project selection" unless selections.is_a?(Array) && !selections.empty? && selections.length <= 12
    allowed = ["native-#{lane}-benchmark.yml"]
    allowed += %w[nix-fresh-benchmark.yml zed-zed-cargo-product.yml] if lane == "fresh" && case_id == "zed"
    allowed += %w[obs-studio-obs-actions-cache.yml obs-studio-obs-boringcache.yml] if lane == "fresh" && case_id == "obs-studio"
    allowed += %w[nix-rolling-benchmark.yml zed-zed-cargo-rolling-auto.yml] if lane == "rolling" && case_id == "zed"
    values = selections.map do |selection|
      workflow, inputs = selection.values_at("workflow", "inputs")
      raise "Unregistered project workflow" unless allowed.include?(workflow)
      raise "Project inputs must be strings" unless inputs.is_a?(Hash) && inputs.all? { |key, value| key.is_a?(String) && value.is_a?(String) }
      id = selection_case(selection)
      raise "Invalid case ID" unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
      raise "Selection belongs to another project" unless project(id) == case_id
      label = workflow == "zed-zed-cargo-rolling-auto.yml" ? "cargo" : inputs["variant"] || inputs["cache_tool"] || inputs["cache_layer"] || id
      label = "#{label} #{inputs.fetch('runner_label')}" unless inputs.fetch("runner_label", "").empty?
      {"workflow" => workflow, "label" => label, "inputs" => inputs}
    end
    raise "Duplicate project selection" unless values.uniq.length == values.length
    native = values.select { |value| value.fetch("workflow") == "native-#{lane}-benchmark.yml" }
    identities = native.map do |value|
      inputs = value.fetch("inputs")
      %w[case_id variant benchmark_id_suffix].map { |name| inputs.fetch(name, "") }
    end
    raise "Project selections must use distinct benchmark suffixes for the same case and variant" unless identities.uniq.length == identities.length
    values.group_by { |value| value.fetch("workflow") }.transform_values { |rows| {"include" => rows} }
  end
end
