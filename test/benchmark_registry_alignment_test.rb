# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require_relative "../scripts/publish-index"

class BenchmarkRegistryAlignmentTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/check-registry-alignment.rb", __dir__)
  README = File.expand_path("../README.md", __dir__)
  TABLE_SCRIPT = File.expand_path("../scripts/benchmark-table.rb", __dir__)
  COHORT_SCRIPT = File.expand_path("../scripts/benchmark-cohort.rb", __dir__)
  REPOS_DIR = ENV["BENCHMARK_REPOS_DIR"] || [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ].find { |path| Dir.exist?(path) }

  def test_aggregate_registry_matches_cases_and_suites
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, SCRIPT)
    assert status.success?, "registry alignment failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stdout, "benchmark registry aligned"
  end

  def test_helper_registries_list_all_published_benchmark_repos
    [TABLE_SCRIPT, COHORT_SCRIPT].each do |script|
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-rjson", "-e", 'load ARGV.fetch(0); puts JSON.generate(BENCHMARKS)', script)
      assert status.success?, stderr
      rows = JSON.parse(stdout)
      assert_equal published_repos, rows.map { |row| row.fetch("source_repo") }.uniq.sort
      assert_equal BENCHMARKS.map { |row| row.fetch("benchmark") }, rows.map { |row| row.fetch("benchmark") }
    end
  end

  def test_readme_links_execution_and_publication_contracts
    readme = File.read(README)

    assert_includes readme, "cases/"
    assert_includes readme, "docs/process.md"
    assert_includes readme, "[product benchmark page](https://boringcache.com/benchmarks)"
    assert_includes readme, "[`data/latest/report.md`](data/latest/report.md)"
    assert_includes readme, "[`data/latest/index.json`](data/latest/index.json)"
    assert_includes readme, "[`data/latest/providers.json`](data/latest/providers.json)"
  end

  private

  def published_repos
    BENCHMARKS.map { |benchmark| benchmark.fetch("source_repo") }.uniq.sort
  end

  def ruby_hash_values(text, key)
    text.scan(/"#{Regexp.escape(key)}"\s*=>\s*"([^"]+)"/).flatten.grep(%r{\Aboringcache/benchmark-}).uniq.sort
  end
end
