# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/benchmark-cadence"
require_relative "../scripts/sync-sources"

class BenchmarkCadenceTest < Minitest::Test
  class Runner < NightlyCanaries::Runner
    attr_reader :dispatches

    def initialize
      @dispatches = []
    end

    def api(path, body: nil)
      if body
        @dispatches << {"path" => path, "body" => body}
        return {"workflow_run_id" => @dispatches.length}
      end
      return {"state" => "active"} if path.include?("/actions/workflows/")
      stable = path.end_with?("/latest")
      release = {"tag_name" => stable ? "v1.40.0" : "vcli-canary-0123456789ab", "draft" => false,
                 "prerelease" => !stable, "published_at" => "2026-10-05T00:00:00Z",
                 "assets" => %w[SHA256SUMS boringcache-linux-amd64 boringcache-linux-arm64 boringcache-macos-universal boringcache-windows-amd64.exe].map { |name| {"name" => name} }}
      stable ? release : [release]
    end
  end

  def test_weekly_and_nightly_dispatch_the_same_workloads_with_exact_release_tags
    targets = BenchmarkCadence.fresh_targets
    runners = %w[stable canary].map do |channel|
      runner = Runner.new
      Dir.mktmpdir do |directory|
        record = runner.dispatch(repository: BenchmarkCases::REPOSITORY, benchmarks: targets,
          channel: channel, output: File.join(directory, "receipt.json"))
        assert_equal "requested", record.fetch("state")
        assert_equal targets.length, record.fetch("runs").length
      end
      runner
    end
    stable, canary = runners.map(&:dispatches)
    assert_equal stable.map { |run| run.fetch("path") }, canary.map { |run| run.fetch("path") }
    stable.zip(canary).each do |weekly, nightly|
      assert_equal "v1.40.0", weekly.dig("body", "inputs", "cli_version")
      assert_equal "vcli-canary-0123456789ab", nightly.dig("body", "inputs", "cli_version")
      assert_equal weekly.dig("body", "inputs").except("cli_version"), nightly.dig("body", "inputs").except("cli_version")
    end
  end

  def test_scheduled_suite_includes_maintained_cases_and_the_new_families
    scheduled = BenchmarkCadence.cases.map { |entry| entry.fetch("case_id") }
    maintained = JSON.parse(File.read(File.join(BenchmarkCases::ROOT, "suites/release.json"))).fetch("cases")
    assert_empty maintained - scheduled
    assert_empty %w[gogs-moon opencut-moon stackstorm-pants executorch-buck2 msgpack-sbt helix-nix zed-nix] - scheduled
    refute_includes scheduled, "pants-jvm"
    refute scheduled.any? { |id| id.start_with?("docker-") }
  end

  def test_shared_workflows_keep_case_and_variant_selectors
    targets = BenchmarkCadence.fresh_targets
    native = targets.select { |item| item.fetch("fresh_workflow") == "reapi-fresh-benchmark.yml" }
    assert_equal %w[executorch-buck2 gogs-moon msgpack-sbt opencut-moon stackstorm-pants], native.map { |item| item.dig("fresh_inputs", "case_id") }.sort
    n8n = targets.select { |item| item.fetch("case_id") == "n8n" }
    assert_equal %w[distroless docker runners turbo], n8n.map { |item| item.dig("fresh_inputs", "variant") }.sort
    obs = targets.select { |item| item.fetch("case_id") == "obs-studio" }
    assert_equal 4, obs.length
    assert_equal 4, NightlyCanaries::Runner.new.targets(obs).length
  end

  def test_source_checks_use_the_same_suite_once_per_case
    ids = BenchmarkCadence.cases.map { |entry| entry.fetch("case_id") }.uniq
    assert_equal ids, BenchmarkCadence.source_cases.map { |item| item.fetch("id") }
    assert_equal ["helix-nix"], BenchmarkCadence.source_cases(case_id: "helix-nix").map { |item| item.fetch("id") }
    assert_raises(BenchmarkCadence::Error) { BenchmarkCadence.source_cases(case_id: "pants-jvm") }
  end

  def test_source_inventory_retains_unchanged_changed_and_blocked_cases
    items = %w[hugo-go gogs-moon helix-nix].map { |id| BenchmarkCases.load_case(id) }
    sync = lambda do |item|
      id = item.fetch("id")
      raise BenchmarkCases::Error, "Source recipe changed" if id == "helix-nix"
      {"case_id" => id, "updated" => id == "hugo-go"}
    end
    Dir.mktmpdir do |directory|
      path = File.join(directory, "sources.json")
      inventory = nil
      capture_io { inventory = SourceSync.propose(items, output: path, sync: sync) }
      assert_equal inventory, JSON.parse(File.read(path))
      assert_equal %w[proposal unchanged blocked], inventory.fetch("records").map { |record| record.fetch("state") }
      assert_equal false, inventory.fetch("records")[1].fetch("requires_case_qualification")
      assert_equal "Source recipe changed", inventory.fetch("records")[2].fetch("error")
    end
  end
end
