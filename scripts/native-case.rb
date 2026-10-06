# frozen_string_literal: true

require "yaml"
require "json"
require "fileutils"

module NativeCase
  class Error < StandardError; end
  INPUTS = %w[strategy phase cache_lane cache_scope benchmark_id cli_version buildkit_image cli_platform report_variant].freeze

  def self.action_path(recipe, payload:, shared_root: File.expand_path("..", __dir__))
    local = File.join(payload, recipe.fetch("action"), "action.yml")
    return local if File.file?(local)
    File.join(shared_root, recipe.fetch("action"), "action.yml")
  end

  def self.validate(item, payload:, shared_root: File.expand_path("..", __dir__))
    recipe = item.dig("execution", "native")
    return unless recipe

    selected = recipe.fetch("variants", {}).keys
    selected = [nil] if selected.empty?
    selected.each { |variant| validate_recipe(resolve(recipe, variant), payload: payload, variant: variant, shared_root: shared_root) }
    raise Error, "Native comparison requires BoringCache and Actions Cache arms" unless item.dig("comparison", "providers").sort == %w[actions-cache boringcache]
    recipe
  end

  def self.resolve(recipe, variant)
    variants = recipe.fetch("variants", {})
    return recipe if variants.empty? && variant.to_s.empty?
    raise Error, "This case does not declare native variants" if variants.empty?
    raise Error, "Select a native variant: #{variants.keys.join(', ')}" unless variants.key?(variant)
    selected = variants.fetch(variant)
    resolved = recipe.reject { |key, _| key == "variants" }.merge(selected)
    %w[fresh_inputs rolling_inputs environment].each do |key|
      resolved[key] = recipe.fetch(key, {}).merge(selected.fetch(key, {}))
    end
    inherited = recipe.fetch("provider_flags", {})
    overrides = selected.fetch("provider_flags", {})
    resolved["provider_flags"] = (inherited.keys | overrides.keys).to_h do |provider|
      [provider, inherited.fetch(provider, {}).merge(overrides.fetch(provider, {}))]
    end
    resolved
  end

  def self.validate_recipe(recipe, payload:, variant:, shared_root: File.expand_path("..", __dir__))
    path = action_path(recipe, payload: payload, shared_root: shared_root)
    raise Error, "Missing native case action #{recipe.fetch('action')}" unless File.file?(path)
    action = YAML.safe_load(File.read(path), aliases: true)
    raise Error, "Native case action must be composite" unless action.dig("runs", "using") == "composite"
    declared = action.fetch("inputs")
    raise Error, "Native variants require the action's report_variant input" if variant && !declared.key?("report_variant")
    %w[fresh rolling].each do |lane|
      settings = recipe.fetch("#{lane}_inputs")
      unknown = settings.keys - declared.keys
      raise Error, "Unknown #{lane} action inputs: #{unknown.join(', ')}" unless unknown.empty?
      raise Error, "Declare static #{lane} recipe inputs; use shared runtime inputs for canaries" if settings.values.any? { |value| value.include?("${{") }
      required = declared.select { |_, spec| spec["required"] && !spec.key?("default") }.keys
      missing = required - settings.keys - INPUTS
      raise Error, "Missing #{lane} action inputs: #{missing.join(', ')}" unless missing.empty?
    end
    recipe.fetch("provider_flags", {}).each do |provider, flags|
      raise Error, "Unknown native provider #{provider}" unless %w[actions-cache boringcache].include?(provider)
      flags.each do |name, value|
        raise Error, "Provider flags cannot change shared runtime inputs" if INPUTS.include?(name)
        raise Error, "Provider flags require declared boolean action inputs" unless declared.key?(name) && %w[true false].include?(value)
        %w[fresh rolling].each do |lane|
          fallback = recipe.fetch("#{lane}_inputs").fetch(name, declared.fetch(name).fetch("default", ""))
          raise Error, "Provider flag #{name} has no boolean fallback" unless %w[true false].include?(fallback)
        end
      end
    end
    recipe
  end

  def self.action_steps(recipe, payload:, shared_root:, seen: [])
    path = action_path(recipe, payload: payload, shared_root: shared_root)
    raise Error, "Recursive native action: #{path}" if seen.include?(path)
    action = YAML.safe_load_file(path, aliases: true)
    Array(action.dig("runs", "steps")).flat_map do |step|
      nested = step["uses"].to_s
      if nested.start_with?("./.github/actions/")
        [step, *action_steps({"action" => nested.delete_prefix("./")}, payload: payload, shared_root: shared_root, seen: seen + [path])]
      else
        [step]
      end
    end
  end

  def self.verify_report(recipe, payload:, lane:, shared_root: File.expand_path("..", __dir__))
    action = YAML.safe_load_file(action_path(recipe, payload: payload, shared_root: shared_root), aliases: true)
    reports = action_steps(recipe, payload: payload, shared_root: shared_root).filter_map do |step|
      command = step["run"].to_s
      command if command.match?(/benchmark-report\.rb\s+phase\b/)
    end
    unless !reports.empty? && reports.all? { |command| command.match?(/(?:\A|[\s(])--verified-output(?=[\s)]|\z)/) }
      raise Error, "Selected native action does not report verified output; add and review its output check before execution"
    end
    if action.fetch("inputs").key?("load_image") && recipe.fetch("#{lane}_inputs").fetch("load_image", "false") != "true"
      raise Error, "Native Docker comparison requires load_image=true; publication and cache-only lanes remain diagnostic"
    end
  end

  def self.benchmark_id(recipe, suffix: "")
    raise Error, "Use an empty suffix or a lowercase suffix beginning with a hyphen" unless suffix.match?(/\A(?:-[a-z0-9]+(?:-[a-z0-9]+)*)?\z/)
    recipe.fetch("benchmark_id") + suffix
  end

  def self.write_action(item, directory:, lane:, suffix: "", variant: nil)
    variant = nil if variant.to_s.empty?
    base = validate(item, payload: directory)
    raise Error, "This case does not use the shared native comparison" unless base
    recipe = resolve(base, variant)
    raise Error, "Use fresh or rolling for the native lane" unless %w[fresh rolling].include?(lane)
    benchmark_id = self.benchmark_id(recipe, suffix: suffix)
    action = YAML.safe_load_file(action_path(recipe, payload: directory), aliases: true)
    declared = action.fetch("inputs")
    settings = recipe.fetch("#{lane}_inputs").merge(INPUTS.to_h { |name| [name, "${{ inputs.#{name} }}"] }.select { |name, _| declared.key?(name) })
    settings["cache_lane"] = lane
    settings["report_variant"] = variant.to_s if declared.key?("report_variant")
    overrides = recipe.fetch("provider_flags", {})
    overrides.values.flat_map(&:keys).uniq.each do |name|
      fallback = settings.fetch(name) { declared.fetch(name).fetch("default") }
      actions = overrides.fetch("actions-cache", {}).fetch(name, fallback)
      boringcache = overrides.fetch("boringcache", {}).fetch(name, fallback)
      settings[name] = "${{ inputs.strategy == 'actions-cache' && '#{actions}' || '#{boringcache}' }}"
    end
    document = {"name" => "Declared benchmark phase", "description" => "Executes the reviewed native case recipe.",
      "inputs" => INPUTS.to_h { |name| [name, {"required" => %w[strategy phase benchmark_id].include?(name), "default" => ""}] },
      "runs" => {"using" => "composite", "steps" => [{"id" => "phase", "uses" => "./#{recipe.fetch('action')}", "with" => settings, "env" => recipe.fetch("environment", {})}]}}
    document.fetch("runs").fetch("steps").concat([
      {"name" => "Record phase outcome", "if" => "always()", "shell" => "bash",
       "env" => {"BENCHMARK_PHASE" => "${{ inputs.phase }}", "BENCHMARK_LANE" => lane,
         "BENCHMARK_PROVIDER" => "${{ inputs.strategy }}", "BENCHMARK_OUTCOME" => "${{ steps.phase.outcome }}",
         "BENCHMARK_CASE_ID" => item.fetch("id"), "BENCHMARK_ID" => benchmark_id, "BENCHMARK_VARIANT" => variant.to_s},
       "run" => "ruby .harness/scripts/fresh-report.rb outcome"},
      {"name" => "Retain phase outcome", "if" => "always()",
       "uses" => "actions/upload-artifact@b7c566a772e6b6bfb58ed0dc250532a479d7789f",
       "with" => {"name" => "outcome-#{benchmark_id}#{variant ? "-#{variant}" : ""}-${{ inputs.strategy }}-#{lane}-${{ inputs.phase }}",
         "path" => "benchmark-outcome/", "if-no-files-found" => "error"}}
    ])
    if action.fetch("outputs", {}).key?("cache_scope")
      document["outputs"] = {"cache_scope" => {"description" => "Published cache cohort", "value" => "${{ steps.phase.outputs.cache_scope }}"}}
    end
    path = File.join(directory, ".github", "actions", "benchmark-phase", "action.yml")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, YAML.dump(document))
    if ENV["GITHUB_ENV"]
      File.open(ENV.fetch("GITHUB_ENV"), "a") do |file|
        file.puts("BENCHMARK_ID=#{benchmark_id}")
        file.puts("BENCHMARK_VARIANT_SUFFIX=#{variant ? "-#{variant}" : ""}")
      end
    end
    document
  end
end
