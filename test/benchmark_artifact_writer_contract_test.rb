# frozen_string_literal: true

require "minitest/autorun"

class BenchmarkArtifactWriterContractTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/canonical/write-benchmark-artifacts.sh", __dir__)
  REPOS_DIR = ENV["BENCHMARK_REPOS_DIR"] || [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ].find { |path| Dir.exist?(path) }

  def test_canonical_writer_accepts_every_option_used_by_benchmark_workflows
    skip "benchmark repos checkout not available" unless REPOS_DIR

    supported = File.read(SCRIPT).scan(/^\s*(--[a-z0-9-]+)\)/).flatten.uniq
    used = Dir.glob(File.join(REPOS_DIR, "benchmark-*", ".github", "**", "*.{yml,yaml}"))
      .flat_map { |path| writer_options(File.readlines(path)) }
      .uniq
      .sort
    unsupported = used - supported

    assert_includes used, "--buildkit-cache-prewarm-seconds"
    assert_empty unsupported, "unsupported write-benchmark-artifacts options: #{unsupported.join(', ')}"
  end

  private

  def writer_options(lines)
    options = []
    capture = false

    lines.each do |line|
      capture = true if line.include?("write-benchmark-artifacts.sh")
      next unless capture

      options.concat(line.scan(/--[a-z0-9-]+/))
      capture = false unless line.rstrip.end_with?("\\")
    end

    options
  end
end
