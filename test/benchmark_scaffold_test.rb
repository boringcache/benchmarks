# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/benchmark-cases"

class BenchmarkScaffoldTest < Minitest::Test
  def test_second_go_workload_uses_existing_workflows_and_shared_actions
    Dir.mktmpdir do |root|
      %w[schemas scripts .github bin Gemfile.lock .tool-versions].each { |path| FileUtils.cp_r(File.join(BenchmarkCases::ROOT, path), root) }
      workflows = Dir[File.join(root, ".github/workflows/*")]
      item = BenchmarkCases.create("another-go", repository: "example/another-go", revision: "a" * 40,
        question: "How does this workload reuse Go build outputs?", shape: "go", tool_version: "1.27.0", root: root)
      BenchmarkCases.validate([item], root: root)
      assert_equal workflows, Dir[File.join(root, ".github/workflows/*")]
      assert_empty Dir[File.join(root, "cases/another-go/payload/.github/**/*")]
      assert_equal ".github/actions/go-benchmark", item.dig("execution", "native", "action")
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.plan(item, root: root) }
      payload = File.join(root, "cases/another-go/payload")
      _, errors, status = Open3.capture3(RbConfig.ruby, File.join(payload, "scripts/verify-output.rb"))
      refute status.success?
      assert_includes errors, "Implement and review"
      item.fetch("execution").delete("blockers")
      BenchmarkCases.write_json(File.join(root, "cases/another-go/case.json"), item)
      assert_equal "native-fresh-benchmark.yml", BenchmarkCases.plan(item, root: root).fetch("workflow")
      target = File.join(root, "prepared")
      BenchmarkCases.prepare(item, directory: target, native_lane: "fresh", root: root)
      action = YAML.safe_load_file(File.join(target, ".github/actions/benchmark-phase/action.yml"))
      assert_equal "./.github/actions/go-benchmark", action.dig("runs", "steps", 0, "uses")
      assert_equal "1.27.0", action.dig("runs", "steps", 0, "with", "go_version")
      contract = JSON.parse(File.read(File.join(target, "recipe-contract.json")))
      plan = TomlRB.load_file(File.join(target, ".boringcache.toml"))
      assert_equal contract.dig("commands", "go"), plan.dig("adapters", "go", "command")
      assert File.file?(File.join(target, ".github/actions/native-cache-benchmark/action.yml"))
    end
  end

  def test_scaffold_rejects_unknown_shapes_and_unpinned_tools_without_creating_a_case
    Dir.mktmpdir do |root|
      [{shape: "unknown", tool_version: "1.27.0"}, {shape: "go"}, {shape: "go", tool_version: "latest"}].each do |options|
        assert_raises(BenchmarkCases::Error) do
          BenchmarkCases.create("example", repository: "example/repo", revision: "a" * 40, question: "Reuse?", root: root, **options)
        end
        refute File.exist?(File.join(root, "cases/example"))
      end
    end
  end

  def test_shared_phase_checks_outputs_after_timing_and_records_partial_failures_without_verifying_them
    action = YAML.safe_load_file(File.join(BenchmarkCases::ROOT, ".github/actions/native-cache-benchmark/action.yml"))
    steps = action.dig("runs", "steps")
    timer = steps.find { |step| step["id"] == "build_timing" }
    verify = steps.find { |step| step["id"] == "verify" }
    report = steps.find { |step| step["name"] == "Write the benchmark phase evidence" }
    assert_operator steps.index(timer), :<, steps.index(verify)
    assert_operator steps.index(verify), :<, steps.index(report)
    assert_includes timer.fetch("if"), "always()"
    assert_nil report["if"]
    partial = steps.find { |step| step["name"] == "Retain available timing and verification state" }
    assert_equal "always()", partial["if"]
    Dir.mktmpdir do |directory|
      _, error, status = Open3.capture3({"BUILD_SECONDS" => "5", "SETUP_SECONDS" => "2", "VERIFIED" => "skipped"},
        "bash", "-c", partial.fetch("run"), chdir: directory)
      assert status.success?, error
      value = JSON.parse(File.read(File.join(directory, "benchmark-partial.json")))
      assert_equal false, value.fetch("verification")
      assert_equal({"build_seconds" => 5.0, "restore_or_setup_seconds" => 2.0}, value.fetch("timing"))
    end
  end
end
