require "minitest/autorun"
require "tmpdir"
require_relative "../../scripts/registry-benchmark"

class RegistryBenchmarkTest < Minitest::Test
  def setup
    @config = JSON.parse(File.read(File.expand_path("../../registry/posthog.json", __dir__)))
    @env = { "GITHUB_RUN_ID" => "123", "GITHUB_REPOSITORY" => "boringcache/benchmarks" }
  end

  def test_a_failed_transfer_is_recorded_and_not_verified
    transfer = RegistryBenchmark.new("ghcr", "push", config: @config, env: @env)
    transfer.define_singleton_method(:prepare) {}
    transfer.define_singleton_method(:capture) { |*| "test" }
    transfer.define_singleton_method(:command) { [RbConfig.ruby, "-e", "exit 3"] }
    transfer.define_singleton_method(:verified?) { raise "failed transfer was verified" }
    Dir.mktmpdir("registry-transfer") do |dir|
      Dir.chdir(dir) do
        assert_equal 1, transfer.run
        record = JSON.parse(File.read("registry-results/ghcr-push.json"))
        assert_equal 3, record["exit_status"]
        assert_equal false, record["output_ok"]
        assert_operator record["seconds"], :>, 0
      end
    end
  end

  def test_a_successful_command_with_the_wrong_image_fails_the_measurement
    transfer = RegistryBenchmark.new("ghcr", "pull", config: @config, env: @env)
    transfer.define_singleton_method(:prepare) {}
    transfer.define_singleton_method(:capture) { |*| "test" }
    transfer.define_singleton_method(:command) { [RbConfig.ruby, "-e", "exit 0"] }
    transfer.define_singleton_method(:verified?) { false }
    Dir.mktmpdir("registry-transfer") do |dir|
      Dir.chdir(dir) do
        assert_equal 1, transfer.run
        record = JSON.parse(File.read("registry-results/ghcr-pull.json"))
        assert_equal 0, record["exit_status"]
        assert_equal false, record["output_ok"]
      end
    end
  end

  def test_pull_rejects_a_runner_with_existing_images
    transfer = RegistryBenchmark.new("ghcr", "pull", config: @config, env: @env)
    transfer.define_singleton_method(:capture) { |*| "existing-image" }
    error = assert_raises(RuntimeError) { transfer.run }
    assert_equal "pull requires a runner with no local images", error.message
  end

  def test_rerun_is_rejected_before_the_registry_is_contacted
    transfer = RegistryBenchmark.new("ghcr", "push", config: @config, env: @env.merge("GITHUB_RUN_ATTEMPT" => "2"))
    error = assert_raises(RuntimeError) { transfer.run }
    assert_match "cannot be retried", error.message
  end
end
