# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require "open3"
require "tmpdir"

class BenchmarkReportContractTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/check-report-contract.rb", __dir__)
  CANONICAL = File.expand_path("../scripts/canonical/benchmark-report.py", __dir__)
  REPOS_DIR = ENV["BENCHMARK_REPOS_DIR"] || [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ].find { |path| Dir.exist?(path) }

  def test_every_summarized_lane_is_retained
    skip "benchmark repos checkout not available" unless REPOS_DIR

    stdout, stderr, status = Open3.capture3(SCRIPT, REPOS_DIR)
    assert status.success?, "report contract failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stdout, "benchmark report contract aligned"
  end

  def test_a_result_file_the_report_never_writes_fails
    _, stderr, status = run_against(uploaded: "acme-boringcache-rolling.json")

    refute status.success?
    assert_includes stderr, "retains acme-boringcache-rolling.json, which no benchmark job in this workflow produces"
  end

  def test_a_lane_the_report_never_retains_fails
    _, stderr, status = run_against(uploaded: nil)

    refute status.success?
    assert_includes stderr, "produce acme-docker-boringcache-rolling.json, which the report never retains"
  end

  def test_an_artifact_named_apart_from_its_result_fails
    _, stderr, status = run_against(artifact_name: "benchmark-acme-rolling")

    refute status.success?
    assert_includes stderr, "must match its result file as \"benchmark-acme-docker-boringcache-rolling\""
  end

  def test_a_canary_dispatch_that_loses_its_result_fails
    _, stderr, status = run_against(suffixed: false)

    refute status.success?
    assert_includes stderr, "a benchmark_id_suffix dispatch produces acme-docker-canary-boringcache-rolling.json"
  end

  def test_a_summarize_call_that_passes_an_unread_flag_fails
    _, stderr, status = run_against(summarize_flags: "--benchmark acme-docker ")

    refute status.success?
    assert_includes stderr, "summarize reads every benchmark in its input directory; drop --benchmark"
  end

  def test_a_reporter_that_drifts_from_canonical_fails
    _, stderr, status = run_against(reporter: "print('drifted')\n")

    refute status.success?
    assert_includes stderr, "has drifted from scripts/canonical/benchmark-report.py"
  end

  private

  def run_against(uploaded: :default, artifact_name: nil, suffixed: true, reporter: nil, summarize_flags: "")
    Dir.mktmpdir do |root|
      repo = File.join(root, "benchmark-acme")
      FileUtils.mkdir_p(File.join(repo, ".github", "workflows"))
      FileUtils.mkdir_p(File.join(repo, ".github", "actions", "acme-docker-benchmark"))
      FileUtils.mkdir_p(File.join(repo, "scripts"))
      File.write(File.join(repo, "scripts", "benchmark-report.py"), reporter || File.read(CANONICAL))
      File.write(File.join(repo, ".github", "actions", "acme-docker-benchmark", "action.yml"), action_yaml)
      File.write(File.join(repo, ".github", "workflows", "acme-benchmark.yml"), workflow_yaml(
        uploaded: uploaded == :default ? "acme-docker#{suffixed ? SUFFIX : ""}-boringcache-rolling.json" : uploaded,
        artifact_name: artifact_name,
        summarize_flags: summarize_flags
      ))
      Open3.capture3(SCRIPT, root)
    end
  end

  SUFFIX = "${{ inputs.benchmark_id_suffix }}"

  def action_yaml
    <<~YAML
      name: "Run acme benchmark phase"
      inputs:
        benchmark_id: {required: true}
        strategy: {required: true}
        cache_lane: {required: true}
        phase: {required: true}
      runs:
        using: composite
        steps:
          - shell: bash
            run: python3 ./scripts/benchmark-report.py phase --benchmark x --strategy y --lane rolling --phase commit --mode docker --build-seconds 1
    YAML
  end

  def workflow_yaml(uploaded:, artifact_name:, summarize_flags: "")
    retain = uploaded.nil? ? [] : [
      "      - uses: actions/upload-artifact@v6",
      "        with:",
      "          name: #{artifact_name || "benchmark-#{uploaded.sub(/\.json\z/, "")}"}",
      "          path: benchmark-results/#{uploaded}",
      "          if-no-files-found: error"
    ]

    [
      <<~YAML.chomp,
        name: "Acme Benchmark"
        on:
          workflow_dispatch:
            inputs:
              benchmark_id_suffix: {required: false, type: string, default: ""}
        jobs:
          commit:
            runs-on: ubuntu-latest
            steps:
              - uses: ./.github/actions/acme-docker-benchmark
                with:
                  strategy: boringcache
                  cache_lane: rolling
                  phase: publish
                  benchmark_id: ${{ format('acme-docker{0}', inputs.benchmark_id_suffix) }}
          report:
            needs: commit
            runs-on: ubuntu-latest
            steps:
              - uses: actions/download-artifact@v6
                with:
                  pattern: phase-*
                  path: phase-evidence
              - run: python3 ./scripts/benchmark-report.py summarize #{summarize_flags}--title Acme --input-dir phase-evidence --output-dir benchmark-results
      YAML
      *retain
    ].join("\n") + "\n"
  end
end
