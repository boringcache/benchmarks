# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "json"
require_relative "../scripts/depot-cache"
require_relative "../scripts/benchmark-cases"
require_relative "../scripts/benchmark-series"
require_relative "../scripts/rolling-monitor"

class DepotCacheTest < Minitest::Test
  def test_other_providers_do_not_inherit_depot_native_cache_credentials
    Dir.mktmpdir do |directory|
      env = {"BENCHMARK_RUNNER_CLASS" => "depot-ubuntu-24.04-4", "GITHUB_ENV" => File.join(directory, "env"),
        "TURBO_TOKEN" => "private-token", "GOCACHEPROG" => "depot gocache"}
      settings = DepotCache.prepare(provider: "boringcache", mode: "go", phase: "publish", env: env)
      assert_equal "", settings.fetch("TURBO_TOKEN")
      assert_equal "", settings.fetch("GOCACHEPROG")
      refute_includes File.read(env.fetch("GITHUB_ENV")), "private-token"
    end
  end

  def test_depot_actions_api_rejects_a_github_cache_endpoint
    Dir.mktmpdir do |directory|
      env = {"BENCHMARK_RUNNER_CLASS" => "depot-ubuntu-24.04-4", "GITHUB_ENV" => File.join(directory, "env"),
        "ACTIONS_CACHE_URL" => "https://cache.actions.githubusercontent.com"}
      assert_raises(DepotCache::Error) { DepotCache.prepare(provider: "depot-actions-cache", mode: "archive", phase: "publish", env: env) }
      refute File.exist?(env.fetch("GITHUB_ENV"))
    end
  end

  def test_native_cache_requires_a_supported_tool_and_credentials
    assert_raises(DepotCache::Error) { DepotCache.environment("go", env: {}) }
    assert_raises(DepotCache::Error) { DepotCache.environment("buck2", env: {"DEPOT_TOKEN" => "private-token"}) }
    assert_raises(DepotCache::Error) { DepotCache.environment("turbo", env: {"DEPOT_TOKEN" => "private-token"}) }
    assert_equal "team", DepotCache.environment("turbo", env: {"DEPOT_TOKEN" => "private-token", "DEPOT_ORGANIZATION_ID" => "", "TURBO_TEAM" => "team"}).fetch("TURBO_TEAM")
    settings = DepotCache.environment("sccache", env: {"DEPOT_CACHE_TOKEN" => "job-token", "DEPOT_TOKEN" => "configured-token"})
    assert_equal "job-token", settings.fetch("SCCACHE_WEBDAV_TOKEN")
    assert_equal "job-token", settings.fetch("DEPOT_TOKEN")
    assert_raises(DepotCache::Error) { DepotCache.environment("go", env: {"DEPOT_CACHE_TOKEN" => "invalid\ntoken"}) }
  end

  def test_depot_actions_api_records_the_endpoint_host_without_credentials
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        env = {"BENCHMARK_RUNNER_CLASS" => "depot-ubuntu-24.04-4", "GITHUB_ENV" => "env",
          "ACTIONS_RESULTS_URL" => "https://actions-cache.depot.dev/private-path?token=private-token"}
        assert_raises(DepotCache::Error) { DepotCache.prepare(provider: "actions-cache", mode: "archive", phase: "publish", env: env) }
        DepotCache.prepare(provider: "depot-actions-cache", mode: "archive", phase: "publish", env: env)
        contents = File.read(".depot-cache/configuration.json")
        assert_equal "actions-cache.depot.dev", JSON.parse(contents).fetch("endpoint_host")
        refute_includes contents, "private-token"
        refute_includes contents, "private-path"
      end
    end
  end

  def test_container_credentials_are_shell_quoted_and_private
    Dir.mktmpdir do |directory|
      path = File.join(directory, "tool-cache-env")
      token = "token with '$ and ; characters"
      DepotCache.write_tool_secret("turbo", path: path, env: {"DEPOT_TOKEN" => token, "TURBO_TEAM" => "team"})
      assert_equal 0o600, File.stat(path).mode & 0o777
      output, status = Open3.capture2("bash", "-c", 'source "$1"; printf "%s" "$TURBO_TOKEN"', "benchmark", path)
      assert status.success?
      assert_equal token, output
    end
  end

  def test_gradle_replay_disables_publication_and_keeps_credentials_out_of_files
    Dir.mktmpdir do |directory|
      DepotCache.configure("gradle", phase: "warm", env: {"DEPOT_TOKEN" => "private-token", "GRADLE_USER_HOME" => directory})
      script = File.read(File.join(directory, "init.d/benchmark-cache-policy.gradle"))
      assert_includes script, "push = false"
      assert_includes script, "local { enabled = false }"
      refute_includes script, "private-token"
    end
  end

  def test_maven_uses_the_reviewed_extension_and_an_environment_token_reference
    Dir.mktmpdir do |directory|
      settings = DepotCache.configure("maven", phase: "warm", root: directory, env: {"DEPOT_TOKEN" => "private-token"})
      config = File.read(File.join(directory, "upstream/.mvn/maven-build-cache-config.xml"))
      assert_includes config, 'saveToRemote="false"'
      credentials = File.read(File.join(directory, ".depot-cache/maven-settings.xml"))
      assert_includes credentials, '${env.DEPOT_TOKEN}'
      refute_includes credentials, "private-token"
      assert_includes settings.fetch("MAVEN_ARGS"), "--settings"
      assert_includes File.read(File.join(directory, "upstream/.mvn/extensions.xml")), "<version>1.3.0</version>"
    end
  end

  def test_maven_preserves_the_pinned_upstream_extension_and_other_extensions
    Dir.mktmpdir do |directory|
      path = File.join(directory, "upstream/.mvn/extensions.xml")
      FileUtils.mkdir_p(File.dirname(path))
      original = '<extensions><extension><artifactId>maven-profiler</artifactId><version>3.3</version></extension><extension><groupId>org.apache.maven.extensions</groupId><artifactId>maven-build-cache-extension</artifactId><version>1.2.3</version></extension></extensions>'
      File.write(path, original)
      DepotCache.configure("maven", phase: "publish", root: directory, env: {"DEPOT_TOKEN" => "private-token"})
      assert_equal original, File.read(path)
    end
  end

  def test_actions_api_validation_runs_with_the_javascript_runtime_environment
    path = File.join(BenchmarkCases::ROOT, ".github/actions/select-cache-provider/action.yml")
    steps = YAML.safe_load_file(path).fetch("runs").fetch("steps")
    api = steps.find { |step| step["if"] == "inputs.provider == 'depot-actions-cache'" }
    assert_match(/\Aactions\/github-script@[0-9a-f]{40}\z/, api.fetch("uses"))
    assert_equal "await exec.exec('ruby', ['./scripts/depot-cache.rb']);", api.dig("with", "script")
  end

  def test_native_depot_plans_do_not_claim_an_isolated_cold_cache_or_change_variants
    item = BenchmarkCases.load_case("n8n")
    inputs = {"provider" => "depot-cache", "runner_label" => "depot-ubuntu-24.04-4"}
    assert_raises(NativeCase::Error) { BenchmarkCases.plan(item, variant: "turbo", inputs: inputs) }
    assert_raises(NativeCase::Error) { BenchmarkCases.plan(item, lane: "rolling", variant: "docker", inputs: inputs) }
    assert_raises(NativeCase::Error) { BenchmarkCases.plan(item, lane: "rolling", variant: "turbo", inputs: inputs.merge("runner_label" => "ubuntu-latest")) }
    assert_equal "depot-cache", BenchmarkCases.plan(item, lane: "rolling", variant: "turbo", inputs: inputs).dig("inputs", "provider")
    item = BenchmarkCases.load_case("executorch-buck2")
    assert_raises(NativeCase::Error) { BenchmarkCases.plan(item, lane: "rolling", inputs: inputs) }
  end

  def test_reviewed_native_suite_keeps_exact_source_and_provider_selections
    suite = JSON.parse(File.read(File.join(BenchmarkCases::ROOT, "suites/depot-cache.json")))
    assert_equal 12, suite.fetch("selections").length
    suite.fetch("selections").each do |selection|
      plan = BenchmarkCases.plan(BenchmarkCases.load_case(selection.fetch("case_id")), workflow: selection.fetch("workflow"), inputs: selection.fetch("inputs"))
      assert_equal "rolling", plan.fetch("lane")
      assert_equal "depot-cache", plan.dig("inputs", "provider")
    end
    assert_equal "unmeasured", suite.fetch("cache_isolation")
  end

  def test_single_provider_series_declares_only_that_provider_without_changing_the_case
    item = BenchmarkCases.load_case("posthog")
    Dir.mktmpdir do |directory|
      plan = BenchmarkSeries.create(item, directory: File.join(directory, "series"), series: "provider-test", lane: "fresh", samples: 1,
        workflow_inputs: {"provider" => "boringcache"})
      assert_equal ["boringcache"], plan.dig("comparison", "providers")
      assert_equal %w[boringcache actions-cache], item.dig("comparison", "providers")
    end
  end

  def test_rolling_monitor_validates_the_selected_native_provider_with_unmeasured_isolation
    item = BenchmarkCases.load_case("gogs-moon")
    record = {"benchmark" => "gogs-moon", "strategy" => "depot-cache", "phase" => "commit", "observation" => "seed",
      "case" => {"case_id" => "gogs-moon", "comparison" => item.fetch("comparison")}, "source" => {"sha" => "a" * 40},
      "github" => {}, "verification" => {"passed" => true}, "cache" => {"hit" => true}, "cache_provider" => {"isolation" => "unmeasured"}}
    runner = Object.new
    runner.define_singleton_method(:api) { |*| {"status" => "completed", "conclusion" => "success", "run_attempt" => 1} }
    runner.define_singleton_method(:phase_evidence) { |*, **| [record] }
    run = {"id" => 42, "repository" => "boringcache/benchmarks", "workflow" => "reapi-rolling-benchmark.yml",
      "inputs" => {"provider" => "depot-cache", "observation" => "seed"}}
    assert_equal "success", RollingMonitor.check_run(item, run, proposal: {"head_sha" => "a" * 40}, runner: runner).fetch("state")
    record["cache_provider"]["isolation"] = "declared-cache-key"
    assert_equal "evidence-missing-or-invalid", RollingMonitor.check_run(item, run, proposal: {"head_sha" => "a" * 40}, runner: runner).fetch("state")
  end
end
