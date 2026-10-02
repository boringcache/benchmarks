# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/benchmark-cases"

class NativeCaseTest < Minitest::Test
  def with_payload(id)
    item = BenchmarkCases.load_case(id)
    Dir.mktmpdir("native-case-") do |directory|
      FileUtils.cp_r(Dir[File.join(BenchmarkCases::ROOT, "cases", id, "payload", "{*,.[!.]*}")], directory)
      yield item, directory
    end
  end

  def test_fresh_and_rolling_share_the_recipe_but_preserve_publication_behavior
    with_payload("hugo") do |item, directory|
      fresh = NativeCase.write_action(item, directory: directory, lane: "fresh")
      rolling = NativeCase.write_action(item, directory: directory, lane: "rolling")
      assert_equal fresh.dig("runs", "steps", 0, "uses"), rolling.dig("runs", "steps", 0, "uses")
      refute fresh.dig("runs", "steps", 0, "with").key?("push_image")
      assert_equal "true", rolling.dig("runs", "steps", 0, "with", "push_image")
      assert_equal "${{ inputs.cli_version }}", fresh.dig("runs", "steps", 0, "with", "cli_version")
    end
  end

  def test_shared_wrapper_keeps_the_reviewed_toolchain_and_environment
    with_payload("opentelemetry-java") do |item, directory|
      action = NativeCase.write_action(item, directory: directory, lane: "fresh")
      assert_equal "21", action.dig("runs", "steps", 0, "with", "java_version")
      assert_equal "${{ github.workspace }}/.gradle-user-home", action.dig("runs", "steps", 0, "env", "GRADLE_USER_HOME")
    end
  end

  def test_shared_workflow_cannot_dispatch_a_different_case
    item = BenchmarkCases.load_case("hugo-go")
    assert_equal "hugo-go", BenchmarkCases.plan(item).dig("inputs", "case_id")
    assert_raises(BenchmarkCases::Error) { BenchmarkCases.plan(item, inputs: {"case_id" => "storybook"}) }
  end

  def test_unreviewed_recipe_input_and_unsafe_suffix_are_rejected
    with_payload("hugo-go") do |item, directory|
      assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh", suffix: "\nOTHER=value") }
      item["execution"]["native"]["fresh_inputs"]["go_version"] = "${{ inputs.go_version }}"
      assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh") }
      refute File.exist?(File.join(directory, ".github", "actions", "benchmark-phase", "action.yml"))
    end
  end

  def test_product_contract_view_resolves_the_wrapper_without_losing_adapter_or_failure_policy
    provider = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/actions/boringcache/action.yml")))
    step = {"uses" => "./.github/actions/boringcache", "id" => "cache", "with" => {"mode" => "cargo", "trust-policy" => "restore", "fail-on-cache-miss" => "true", "fail-on-cache-error" => "true"}}
    resolved = BenchmarkCases.resolve_provider_steps(step, provider)
    assert_equal provider.dig("runs", "steps", 0, "uses"), resolved["uses"]
    assert_equal "cache", resolved["id"]
    assert_equal "cargo", resolved.dig("with", "mode")
    assert_equal "restore", resolved.dig("with", "trust-policy")
    assert_equal "true", resolved.dig("with", "fail-on-cache-miss")
    assert_equal "true", resolved.dig("with", "fail-on-cache-error")
    assert_raises(BenchmarkCases::Error) { BenchmarkCases.resolve_provider_steps({"uses" => "./.github/actions/boringcache", "with" => {"obsolete" => "true"}}, provider) }
  end
end
