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

  def test_source_matrix_selects_each_case_once_and_rejects_unknown_cases
    script = File.join(BenchmarkCases::ROOT, "scripts/sync-sources.rb")
    output, status = Open3.capture2e(RbConfig.ruby, script, "--matrix")
    assert status.success?, output
    ids = JSON.parse(output).fetch("case_id")
    assert_equal BenchmarkCadence.source_cases.map { |item| item.fetch("id") }, ids
    assert_equal ids.uniq, ids
    output, status = Open3.capture2e(RbConfig.ruby, script, "--matrix", "--case", "helix-nix")
    assert status.success?, output
    assert_equal({"case_id" => ["helix-nix"]}, JSON.parse(output))
    output, status = Open3.capture2e(RbConfig.ruby, script, "--matrix", "--case", "unknown")
    refute status.success?
    assert_includes output, "not in the scheduled suite"
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

  def test_native_rolling_paths_verify_outputs_for_every_scheduled_variant
    %w[hugo chroma duckgres linkerd2 immich mastodon posthog n8n].each do |id|
      targets = BenchmarkCadence.rolling_targets(case_id: id)
      selections = BenchmarkCadence.cases.select { |entry| entry.fetch("case_id") == id }
      assert_equal selections.length, targets.length, id
      assert targets.all? { |target| target.fetch("workflow") == "native-rolling-benchmark.yml" }
      assert_equal selections.map { |entry| entry["variant"] }, targets.map { |target| target.dig("inputs", "variant") }
    end
    %w[gogs-moon opencut-moon stackstorm-pants executorch-buck2 msgpack-sbt helix-nix zed-nix].each do |id|
      targets = BenchmarkCadence.rolling_targets(case_id: id)
      assert_equal 1, targets.length
      assert_equal id, targets.first.dig("inputs", "case_id")
      assert_equal "rolling", targets.first.fetch("lane")
    end
  end

  def test_schedules_require_explicit_cutover_and_monitor_all_central_cadences
    %w[weekly-fresh canary source-sync].each do |name|
      workflow = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/workflows/#{name}.yml")))
      job = workflow.fetch("jobs").values.first
      assert_equal "github.event_name == 'workflow_dispatch' || vars.BENCHMARK_CADENCE_ACTIVE == 'true'", job.fetch("if")
    end
    workflow = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/workflows/nightly-canaries.yml")))
    step = workflow.dig("jobs", "results", "steps").find { |item| item["name"] == "Check repository canaries" }
    refute_includes step.fetch("run"), 'scripts/nightly-canaries.rb --collect'
    assert_includes step.fetch("run"), 'scripts/rolling-monitor.rb'
    assert_includes step.fetch("run"), 'daily weekly'
    assert_includes step.fetch("run"), 'scripts/benchmark-cadence.rb --collect'
  end

  def test_incompatible_cli_stops_the_entire_dispatch_and_retains_a_failed_receipt
    runner = Runner.new
    preflight = ->(version, runs) { BenchmarkCadence.verify_cli(version, runs, probe: ->(*) { "--port PORT" }) }
    Dir.mktmpdir do |directory|
      path = File.join(directory, "receipt.json")
      error = assert_raises(BenchmarkCadence::Error) do
        runner.dispatch(repository: BenchmarkCases::REPOSITORY, benchmarks: BenchmarkCadence.fresh_targets,
          channel: "stable", output: path, preflight: preflight)
      end
      assert_includes error.message, "native moon"
      assert_empty runner.dispatches
      receipt = JSON.parse(File.read(path))
      assert_equal "dispatch-failed", receipt.fetch("state")
      assert_equal 34, receipt.fetch("runs").length
      assert receipt.fetch("runs").all? { |run| run.fetch("state") == "planned" }
    end
  end

  def test_cli_capability_probe_is_required_for_reapi_but_not_other_targets
    runs = [{"workflow" => "reapi-fresh-benchmark.yml"}]
    assert_nil BenchmarkCadence.verify_cli("v1.34.0", runs, probe: ->(_version, tool) { "Usage: boringcache #{tool}" })
    assert_nil BenchmarkCadence.verify_cli("v1.33.0", [{"workflow" => "native-fresh-benchmark.yml"}],
      probe: ->(*) { flunk "No REAPI capability is needed" })
  end
end
