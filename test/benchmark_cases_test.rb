# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/benchmark-cases"

class BenchmarkCasesTest < Minitest::Test
  def with_root
    Dir.mktmpdir("benchmark-cases-") do |root|
      FileUtils.cp_r(File.join(BenchmarkCases::ROOT, "schemas"), root)
      yield root
    end
  end

  def test_new_evaluation_uses_the_common_contract_and_cannot_execute_until_reviewed
    with_root do |root|
      item = BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Can task outputs be reused?", root: root)
      assert_equal "boringcache/benchmarks", item["workspace"]
      assert_equal "evaluation-only", item.dig("reporting", "publication")
      BenchmarkCases.validate([item], root: root)
      error = assert_raises(BenchmarkCases::Error) { BenchmarkCases.plan(item, root: root) }
      assert_includes error.message, "Review the recipe"
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.prepare(item, directory: File.join(root, "workload"), root: root) }
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Can task outputs be reused?", root: root) }
    end
  end

  def test_draft_cannot_remove_its_blocker_without_an_execution_path
    with_root do |root|
      item = BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Can task outputs be reused?", root: root)
      item.fetch("execution")["blockers"] = []
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.validate([item], root: root) }
    end
  end

  def test_rejects_unpinned_sources_and_path_traversal_before_writing
    with_root do |root|
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.create("../outside", repository: "example/upstream", revision: "a" * 40, question: "Reuse?", root: root) }
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.create("example", repository: "example/upstream", revision: "main", question: "Reuse?", root: root) }
      refute Dir.exist?(File.join(root, "cases"))
    end
  end

  def test_source_advancement_preserves_other_reviewed_source_pairs
    with_root do |root|
      item = BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Reuse?", root: root)
      item["execution"]["source_prefix"] = "EXAMPLE"
      item["source"]["pins"] = [{"path" => "payload/benchmark-source.env", "kind" => "env", "revision" => "a" * 40},
        {"path" => "payload/layer-source.env", "kind" => "env", "revision" => "b" * 40}]
      FileUtils.mkdir_p(File.join(root, "cases/example/payload"))
      workload = File.join(root, "workload")
      FileUtils.mkdir_p(workload)
      File.write(File.join(workload, "benchmark-source.env"), "EXAMPLE_SOURCE_REPOSITORY=example/upstream\nEXAMPLE_BASE_SHA=#{'c' * 40}\nEXAMPLE_HEAD_SHA=#{'d' * 40}\n")
      BenchmarkCases.update_source(item, workload, root: root)
      assert_includes item.dig("source", "pins"), {"path" => "payload/layer-source.env", "kind" => "env", "revision" => "b" * 40}
      assert_equal ["b" * 40, "c" * 40, "d" * 40], item.dig("source", "pins").map { |pin| pin["revision"] }
      original = File.read(File.join(root, "cases/example/payload/benchmark-source.env"))
      File.write(File.join(workload, "benchmark-source.env"), original.sub("example/upstream", "other/upstream"))
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.update_source(item, workload, root: root) }
      assert_equal original, File.read(File.join(root, "cases/example/payload/benchmark-source.env"))
    end
  end
end
