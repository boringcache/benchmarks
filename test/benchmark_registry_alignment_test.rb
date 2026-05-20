# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require_relative "../scripts/publish-index"

class BenchmarkRegistryAlignmentTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/check-registry-alignment.rb", __dir__)
  README = File.expand_path("../README.md", __dir__)
  TABLE_SCRIPT = File.expand_path("../scripts/benchmark-table.rb", __dir__)
  COHORT_SCRIPT = File.expand_path("../scripts/benchmark-cohort.rb", __dir__)
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

  def test_readme_lists_all_published_benchmark_repos
    assert_equal published_repos, markdown_benchmark_repos(File.read(README))
  end

  def test_helper_registries_list_all_published_benchmark_repos
    assert_equal published_repos, ruby_hash_values(File.read(TABLE_SCRIPT), "source_repo")
    assert_equal published_repos, ruby_hash_values(File.read(COHORT_SCRIPT), "repo")
  end

  private

  def published_repos
    BENCHMARKS.map { |benchmark| benchmark.fetch("source_repo") }.uniq.sort
  end

  def markdown_benchmark_repos(text)
    text.scan(/^- `([^`]+)`$/).flatten.grep(%r{\Aboringcache/benchmark-}).uniq.sort
  end

  def ruby_hash_values(text, key)
    text.scan(/"#{Regexp.escape(key)}"\s*=>\s*"([^"]+)"/).flatten.grep(%r{\Aboringcache/benchmark-}).uniq.sort
  end
end
