# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/cadence-dispatch"

class CadenceDispatchTest < Minitest::Test
  def plan
    {"state" => "planned", "cli_version" => "vcli-canary-0123456789ab", "channel" => "canary", "ref" => "main",
     "runs" => %w[immich posthog].map { |id| {"repository" => "boringcache/benchmarks", "workflow" => "native-fresh-benchmark.yml", "inputs" => {"case_id" => id}, "state" => "planned"} }}
  end

  def dispatch(index, response: {"workflow_run_id" => 123})
    Dir.mktmpdir do |directory|
      path = File.join(directory, "receipt.json")
      runner = NightlyCanaries::Runner.new
      request = lambda do |endpoint, body:|
        assert_equal "requesting", JSON.parse(File.read(path)).dig("runs", 0, "state")
        assert_equal "repos/boringcache/benchmarks/actions/workflows/native-fresh-benchmark.yml/dispatches", endpoint
        assert_equal plan.fetch("cli_version"), body.dig("inputs", "cli_version")
        assert_equal plan.dig("runs", index, "inputs", "case_id"), body.dig("inputs", "case_id")
        response
      end
      runner.stub(:api, request) do
        begin
          result = CadenceDispatch.dispatch(plan, index: index, output: path, runner: runner)
          assert_equal result, JSON.parse(File.read(path))
          result
        rescue CadenceDispatch::Error
          JSON.parse(File.read(path))
        end
      end
    end
  end

  def test_pin_creates_and_verifies_one_reference_without_moving_main
    value = plan
    value.fetch("runs").each { |run| run["harness_sha"] = "a" * 40 }
    existing = nil
    mutations = []
    runner = NightlyCanaries::Runner.new
    runner.stub(:api, ->(path, body: nil) {
      if body
        mutations << [path, body]
        existing = {"object" => {"sha" => body.fetch("sha")}}
      else
        raise NightlyCanaries::Error, "HTTP 404" unless existing
        existing
      end
    }) do
      pinned = CadenceDispatch.pin(value, run_id: "42", runner: runner)
      assert_equal "benchmark-42", pinned.fetch("ref")
      assert_equal "main", value.fetch("ref")
      assert_equal pinned, CadenceDispatch.pin(value, run_id: "42", runner: runner)
    end
    assert_equal [["repos/boringcache/benchmarks/git/refs", {"ref" => "refs/tags/benchmark-42", "sha" => "a" * 40}]], mutations
  end

  def test_pin_rejects_a_different_existing_harness_without_mutation
    value = plan
    value.fetch("runs").each { |run| run["harness_sha"] = "a" * 40 }
    runner = NightlyCanaries::Runner.new
    runner.stub(:api, ->(_path, body: nil) {
      flunk "No ref may be changed" if body
      {"object" => {"sha" => "b" * 40}}
    }) { assert_raises(CadenceDispatch::Error) { CadenceDispatch.pin(value, run_id: "42", runner: runner) } }
  end

  def test_independent_dispatch_receipts_combine_in_declared_order
    first, second = dispatch(0), dispatch(1, response: {"workflow_run_id" => 456})
    combined = CadenceDispatch.combine(plan, [second, first])
    assert_equal "requested", combined.fetch("state")
    assert_equal [123, 456], combined.fetch("runs").map { |run| run.fetch("id") }
    assert_equal "planned", plan.fetch("state")
    assert_equal [0, 1], CadenceDispatch.matrix(plan).fetch("include").map { |row| row.fetch("index") }
  end

  def test_ambiguous_request_and_missing_target_are_retained
    unknown = dispatch(0, response: {})
    assert_equal "dispatch-failed", unknown.fetch("state")
    assert_equal "request-unknown", unknown.dig("runs", 0, "state")
    combined = CadenceDispatch.combine(plan, [unknown])
    assert_equal "dispatch-failed", combined.fetch("state")
    assert_equal %w[request-unknown planned], combined.fetch("runs").map { |run| run.fetch("state") }
  end

  def test_failed_request_does_not_remove_successful_sibling
    failed = dispatch(0, response: {})
    success = dispatch(1)
    combined = CadenceDispatch.combine(plan, [failed, success])
    assert_equal "dispatch-failed", combined.fetch("state")
    assert_equal %w[request-unknown requested], combined.fetch("runs").map { |run| run.fetch("state") }
  end

  def test_duplicate_mismatched_and_incomplete_receipts_cannot_claim_success
    receipt = dispatch(0)
    assert_raises(CadenceDispatch::Error) { CadenceDispatch.combine(plan, [receipt, receipt]) }
    wrong_version = receipt.merge("cli_version" => "v1.33.0")
    assert_raises(CadenceDispatch::Error) { CadenceDispatch.combine(plan, [wrong_version]) }
    wrong_index = receipt.merge("target_index" => 1)
    assert_raises(CadenceDispatch::Error) { CadenceDispatch.combine(plan, [wrong_index]) }
    assert_equal "dispatch-failed", CadenceDispatch.combine(plan, [receipt]).fetch("state")
    assert_equal "planned", CadenceDispatch.combine(plan, [], dry_run: true).fetch("state")
    assert_raises(CadenceDispatch::Error) { CadenceDispatch.matrix(plan.merge("state" => "dispatch-failed")) }
  end
end
