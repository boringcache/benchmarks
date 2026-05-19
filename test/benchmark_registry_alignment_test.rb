# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class BenchmarkRegistryAlignmentTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/check-registry-alignment.rb", __dir__)
  REPOS_DIR = [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ].find { |path| Dir.exist?(path) }

  def test_aggregate_registry_matches_local_benchmark_repos
    skip "benchmark repos checkout not available" unless REPOS_DIR

    stdout, stderr, status = Open3.capture3(SCRIPT, REPOS_DIR)
    assert status.success?, "registry alignment failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stdout, "benchmark registry aligned"
  end
end
