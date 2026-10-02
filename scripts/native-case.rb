# frozen_string_literal: true

require "yaml"
require "json"
require "fileutils"

module NativeCase
  class Error < StandardError; end
  INPUTS = %w[strategy phase cache_lane benchmark_id cli_version buildkit_image cli_platform].freeze

  def self.validate(item, payload:)
    recipe = item.dig("execution", "native")
    return unless recipe

    path = File.join(payload, recipe.fetch("action"), "action.yml")
    raise Error, "Missing native case action #{recipe.fetch('action')}" unless File.file?(path)
    action = YAML.safe_load(File.read(path), aliases: true)
    raise Error, "Native case action must be composite" unless action.dig("runs", "using") == "composite"
    declared = action.fetch("inputs")
    %w[fresh rolling].each do |lane|
      settings = recipe.fetch("#{lane}_inputs")
      unknown = settings.keys - declared.keys
      raise Error, "Unknown #{lane} action inputs: #{unknown.join(', ')}" unless unknown.empty?
      raise Error, "Declare static #{lane} recipe inputs; use shared runtime inputs for canaries" if settings.values.any? { |value| value.include?("${{") }
      required = declared.select { |_, spec| spec["required"] && !spec.key?("default") }.keys
      missing = required - settings.keys - INPUTS
      raise Error, "Missing #{lane} action inputs: #{missing.join(', ')}" unless missing.empty?
    end
    raise Error, "Native comparison requires BoringCache and Actions Cache arms" unless item.dig("comparison", "providers").sort == %w[actions-cache boringcache]
    recipe
  end

  def self.write_action(item, directory:, lane:, suffix: "")
    recipe = validate(item, payload: directory)
    raise Error, "This case does not use the shared native comparison" unless recipe
    raise Error, "Use fresh or rolling for the native lane" unless %w[fresh rolling].include?(lane)
    raise Error, "Use an empty suffix or a lowercase suffix beginning with a hyphen" unless suffix.match?(/\A(?:-[a-z0-9]+(?:-[a-z0-9]+)*)?\z/)
    benchmark_id = recipe.fetch("benchmark_id") + suffix
    declared = YAML.safe_load(File.read(File.join(directory, recipe.fetch("action"), "action.yml")), aliases: true).fetch("inputs")
    settings = recipe.fetch("#{lane}_inputs").merge(INPUTS.to_h { |name| [name, "${{ inputs.#{name} }}"] }.select { |name, _| declared.key?(name) })
    settings["cache_lane"] = lane
    document = {"name" => "Declared benchmark phase", "description" => "Executes the reviewed native case recipe.",
      "inputs" => INPUTS.to_h { |name| [name, {"required" => %w[strategy phase benchmark_id].include?(name), "default" => ""}] },
      "runs" => {"using" => "composite", "steps" => [{"uses" => "./#{recipe.fetch('action')}", "with" => settings, "env" => recipe.fetch("environment", {})}]}}
    path = File.join(directory, ".github", "actions", "benchmark-phase", "action.yml")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, YAML.dump(document))
    File.open(ENV.fetch("GITHUB_ENV"), "a") { |file| file.puts("BENCHMARK_ID=#{benchmark_id}") } if ENV["GITHUB_ENV"]
    document
  end
end
