# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "open3"
require "rbconfig"
require "toml-rb"
require "json"
require "fileutils"

class BenchmarkCaseScriptsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def with_case(id)
    Dir.mktmpdir("benchmark-recipe-") do |directory|
      FileUtils.cp_r(Dir[File.join(ROOT, "cases", id, "payload", "{*,.[!.]*}")], directory)
      FileUtils.mkdir_p(File.join(directory, "scripts"))
      %w[benchmark-plan activate-docker-plan run-benchmark-plan verify-upstream-recipe scope-case-cache prepare-source].each do |name|
        FileUtils.cp(File.join(ROOT, "scripts", "#{name}.rb"), File.join(directory, "scripts", "#{name}.rb"))
      end
      item = JSON.parse(File.read(File.join(ROOT, "cases", id, "case.json")))
      File.write(File.join(directory, "benchmark-context.json"), JSON.generate({"case_id" => id, "execution" => item.fetch("execution")}))
      yield directory
    end
  end

  def run_script(directory, name, *args)
    Open3.capture3(RbConfig.ruby, File.join(directory, "scripts", "#{name}.rb"), *args, chdir: directory)
  end

  def test_mastodon_streaming_does_not_acquire_server_tool_cache
    with_case("mastodon") do |directory|
      _, error, status = run_script(directory, "activate-docker-plan", "--workload", "streaming", "--tool-cache", "false",
        "--source-sha", "a" * 40, "--prerelease", "nightly.2026-10-02", "--push", "false")
      assert status.success?, error
      docker = TomlRB.load_file(File.join(directory, ".boringcache.toml")).dig("adapters", "docker")
      assert_includes docker["command"], "upstream/streaming/Dockerfile"
      refute docker.key?("tool-cache")
      refute_includes docker["command"], "--push"
    end
  end

  def test_invalid_mastodon_projection_leaves_plan_unchanged
    with_case("mastodon") do |directory|
      path = File.join(directory, ".boringcache.toml")
      original = File.read(path)
      _, _, status = run_script(directory, "activate-docker-plan", "--workload", "streaming", "--tool-cache", "true", "--push", "false")
      refute status.success?
      assert_equal original, File.read(path)
    end
  end

  def test_immich_scopes_both_tags_and_preserves_workspace_and_command
    with_case("immich") do |directory|
      path = File.join(directory, ".boringcache.toml")
      original = TomlRB.load_file(path)
      _, error, status = run_script(directory, "scope-case-cache", "screening-01")
      assert status.success?, error
      plan = TomlRB.load_file(path)
      assert_equal "boringcache/benchmarks", plan["workspace"]
      assert_equal "screening-01-docker", plan.dig("adapters", "docker", "tag")
      assert_equal "screening-01-ccache", plan.dig("adapters", "ccache", "tag")
      assert_equal original.dig("adapters", "docker", "command"), plan.dig("adapters", "docker", "command")
    end
  end

  def test_obs_scope_changes_only_the_selected_adapter_identity
    with_case("obs-studio") do |directory|
      path = File.join(directory, ".boringcache.toml")
      original = TomlRB.load_file(path)
      _, error, status = run_script(directory, "scope_boringcache_plan", "ccache", "123", "2")
      assert status.success?, error
      actual = TomlRB.load_file(path)
      assert_equal "obs-studio-ccache-r123-a2", actual.dig("adapters", "ccache", "tag")
      original["adapters"]["ccache"]["tag"] = actual["adapters"]["ccache"]["tag"]
      assert_equal original, actual
    end
  end

  def test_reviewed_recipe_rejects_changed_upstream_files
    with_case("hugo-go") do |directory|
      source = File.join(directory, "upstream")
      FileUtils.mkdir_p(File.join(source, ".github", "workflows"))
      File.write(File.join(source, ".github", "workflows", "test.yml"), "changed workflow\n")
      _, error, status = run_script(directory, "verify-upstream-recipe")
      refute status.success?
      assert_includes error, "Upstream recipe changed"
    end
  end

  def test_deno_profile_selects_exactly_one_declared_profile
    with_case("deno") do |directory|
      path = File.join(directory, ".boringcache.toml")
      _, error, status = run_script(directory, "select-deno-cargo-profile", "compiler-only")
      assert status.success?, error
      plan = TomlRB.load_file(path)
      assert_equal ["compiler-only"], plan.dig("adapters", "cargo", "profiles")
      before = File.read(path)
      _, _, status = run_script(directory, "select-deno-cargo-profile", "unknown")
      refute status.success?
      assert_equal before, File.read(path)
    end
  end

  def test_zed_layer_cohort_is_shared_within_a_run_and_fresh_for_a_new_attempt
    with_case("zed") do |directory|
      source = File.join(directory, "upstream")
      FileUtils.mkdir_p(source)
      _, error, status = Open3.capture3("git", "init", source)
      assert status.success?, error
      run = lambda do |lane, attempt|
        _, error, status = Open3.capture3({"GITHUB_RUN_ID" => "123", "GITHUB_RUN_ATTEMPT" => attempt, "BENCHMARK_SERIES_ID" => "screening", "BENCHMARK_SAMPLE" => "1"},
          RbConfig.ruby, File.join(directory, "scripts", "activate-cargo-plan.rb"), lane, "primary", chdir: directory)
        assert status.success?, error
        TomlRB.load_file(File.join(source, ".boringcache.toml"))
      end
      cold = run.call("cold", "1")
      target = run.call("target-only", "1")
      assert_equal cold.dig("entries", "zed-target", "tag"), target.dig("entries", "zed-target", "tag")
      assert_equal "none", target.dig("adapters", "cargo", "compiler-cache")
      retry_plan = run.call("cold", "2")
      refute_equal cold.dig("entries", "zed-target", "tag"), retry_plan.dig("entries", "zed-target", "tag")
      assert_equal "boringcache/benchmarks", retry_plan["workspace"]
    end
  end
end
