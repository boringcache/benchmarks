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
    assert_equal 22, ids.length
    assert_equal BenchmarkCadence.source_cases.map { |item| item.dig("source", "repository") }.uniq.sort,
      ids.map { |id| BenchmarkCases.load_case(id).dig("source", "repository") }.sort
    assert_includes ids, "hugo"
    assert_includes ids, "zed"
    assert_equal ids.uniq, ids
    output, status = Open3.capture2e(RbConfig.ruby, script, "--matrix", "--case", "helix-nix")
    assert status.success?, output
    assert_equal({"case_id" => ["helix-nix"]}, JSON.parse(output))
    output, status = Open3.capture2e(RbConfig.ruby, script, "--matrix", "--case", "hugo-go")
    assert status.success?, output
    assert_equal({"case_id" => ["hugo"]}, JSON.parse(output))
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
    %w[weekly-fresh canary].each do |name|
      workflow = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/workflows/#{name}.yml")))
      job = workflow.fetch("jobs").values.first
      assert_equal "github.event_name == 'workflow_dispatch' || vars.BENCHMARK_CADENCE_ACTIVE == 'true' || vars.BENCHMARK_ACTIVE_CASES != '' && vars.BENCHMARK_ACTIVE_CASES != '[]'", job.fetch("if")
    end
    source = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/workflows/source-sync.yml")))
    refute source.dig("jobs", "select").key?("if"), "Upstream inspection must continue while automatic dispatch is paused"
    controller = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/workflows/source-case.yml")))
    assert_equal "needs.inspect.outputs.changed == 'true' && (vars.BENCHMARK_CADENCE_ACTIVE == 'true' || contains(fromJSON(vars.BENCHMARK_ACTIVE_CASES || '[]'), inputs.case_id)) && github.ref_name == 'main'", controller.dig("jobs", "publish", "if")
    workflow = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/workflows/nightly-canaries.yml")))
    refute workflow.dig("jobs", "results").key?("if"), "Monitoring must continue while automatic dispatch is paused"
    assert_equal({"contents" => "read", "actions" => "read"}, workflow.fetch("permissions"))
    assert_equal "${{ vars.BENCHMARK_ACTIVE_CASES }}", workflow.dig("jobs", "results", "env", "BENCHMARK_ACTIVE_CASES")
    step = workflow.dig("jobs", "results", "steps").find { |item| item["name"] == "Check repository canaries" }
    refute_includes step.fetch("run"), 'scripts/nightly-canaries.rb --collect'
    assert_includes step.fetch("run"), 'scripts/rolling-monitor.rb'
    assert_includes step.fetch("run"), 'daily weekly'
    assert_includes step.fetch("run"), 'scripts/benchmark-cadence.rb --collect'
    assert_includes step.fetch("run"), 'args+=(--active-only)'
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
      assert_equal BenchmarkCadence.fresh_targets.length, receipt.fetch("runs").length
      assert receipt.fetch("runs").all? { |run| run.fetch("state") == "planned" }
    end
  end

  def test_posthog_runner_selections_are_shared_by_fresh_and_rolling_cadence
    screened = JSON.parse(File.read(File.join(BenchmarkCases::ROOT, "cases/posthog/runner-screen-selections.json"))).map { |row| row.fetch("inputs") }
    fresh = BenchmarkCadence.fresh_targets(case_id: "posthog").map { |row| row.fetch("fresh_inputs") }.select { |inputs| inputs["provider"] == "boringcache" }
    rolling = BenchmarkCadence.rolling_targets(case_id: "posthog").map { |row| row.fetch("inputs") }.select { |inputs| inputs["provider"] == "boringcache" }
    assert_equal screened, fresh
    assert_equal screened, rolling.map { |inputs| inputs.except("cache_scope") }
    assert_equal 4, fresh.map { |inputs| inputs.fetch("benchmark_id_suffix") }.uniq.length
  end

  def test_native_depot_cache_stays_in_rolling_without_claiming_cold_isolation
    fresh = BenchmarkCadence.fresh_targets(case_id: "posthog")
    refute fresh.any? { |row| row.dig("fresh_inputs", "provider") == "depot-cache" }
    assert_equal 4, fresh.count { |row| row.dig("fresh_inputs", "provider") == "depot-actions-cache" }
    rolling = BenchmarkCadence.rolling_targets(case_id: "posthog")
    native = rolling.select { |row| row.dig("inputs", "provider") == "depot-cache" }
    assert_equal 2, native.length
    assert_equal ["combined"], native.map { |row| row.dig("inputs", "variant") }.uniq
    assert_equal 12, ProjectRuns.matrix(rolling, case_id: "posthog", lane: "rolling").fetch("native-rolling-benchmark.yml").fetch("include").length
  end

  def test_active_cases_reject_unknown_and_duplicate_cases
    assert_equal ["posthog"], BenchmarkCadence.active_cases('["posthog"]')
    assert_empty BenchmarkCadence.active_cases("")
    ['{"posthog":true}', '["unknown"]', '["posthog","posthog"]', 'not-json'].each do |value|
      assert_raises(BenchmarkCadence::Error) { BenchmarkCadence.active_cases(value) }
    end
  end

  def test_cli_capability_probe_is_required_for_reapi_but_not_other_targets
    runs = [{"workflow" => "reapi-fresh-benchmark.yml"}]
    assert_nil BenchmarkCadence.verify_cli("v1.34.0", runs, probe: ->(_version, tool) { "Usage: boringcache #{tool}" })
    assert_nil BenchmarkCadence.verify_cli("v1.33.0", [{"workflow" => "native-fresh-benchmark.yml"}],
      probe: ->(*) { flunk "No REAPI capability is needed" })
  end
end
