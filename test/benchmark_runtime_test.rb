# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class BenchmarkRuntimeTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_ruby_setup_uses_the_project_runtime_pin
    assert_match(/^ruby \d+\.\d+\.\d+$/, File.read(File.join(ROOT, ".tool-versions")).strip)
    paths = Dir[File.join(ROOT, ".github", "{actions/**/action,workflows/*}.{yml,yaml}")]
    setups = paths.flat_map do |path|
      document = YAML.safe_load(File.read(path), aliases: true)
      steps = Array(document.dig("runs", "steps")) + Array(document["jobs"]&.values).flat_map { |job| Array(job["steps"]) }
      steps.filter_map { |step| [path, step] if step["uses"].to_s.start_with?("ruby/setup-ruby@") }
    end
    refute_empty setups
    setups.each { |path, step| refute step.fetch("with", {}).key?("ruby-version"), "Read the project runtime pin in #{path}" }
    prepare = YAML.safe_load(File.read(File.join(ROOT, ".github/actions/prepare-case/action.yml")))
    assert_equal ".harness", prepare.dig("runs", "steps", 0, "with", "working-directory")
    canary = YAML.safe_load(File.read(File.join(ROOT, ".github/actions/nightly-canary/action.yml")))
    assert_equal "${{ github.action_path }}/../../..", canary.dig("runs", "steps", 0, "with", "working-directory")
  end
end
