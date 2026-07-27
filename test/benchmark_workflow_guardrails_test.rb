# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "fileutils"
require "tmpdir"

class BenchmarkWorkflowGuardrailsTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/check-workflow-guardrails.rb", __dir__)
  REPOS_DIR = ENV["BENCHMARK_REPOS_DIR"] || [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ].find { |path| Dir.exist?(path) }

  def test_benchmark_workflows_keep_product_guardrails
    skip "benchmark repos checkout not available" unless REPOS_DIR

    stdout, stderr, status = Open3.capture3(SCRIPT, REPOS_DIR)
    assert status.success?, "workflow guardrails failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stdout, "benchmark workflow guardrails passed"
  end

  def test_ecr_runtime_support_is_rejected_but_historical_docs_are_ignored
    Dir.mktmpdir("benchmark-workflow-guardrails-") do |repos_dir|
      workflows_dir = File.join(repos_dir, "benchmark-hugo", ".github", "workflows")
      actions_dir = File.join(repos_dir, "benchmark-hugo", ".github", "actions", "docker-benchmark")
      docs_dir = File.join(repos_dir, "benchmark-hugo", "docs")
      FileUtils.mkdir_p(workflows_dir)
      FileUtils.mkdir_p(actions_dir)
      FileUtils.mkdir_p(docs_dir)
      File.write(File.join(workflows_dir, "hugo-benchmark.yml"), <<~YAML)
        on:
          workflow_dispatch:
        jobs:
          ecr-cache:
            name: ECR
            steps:
              - name: ECR
                with:
                  strategy: ecr-cache
      YAML
      File.write(File.join(actions_dir, "action.yml"), "runs:\n  using: composite\n  steps:\n    - uses: aws-actions/amazon-ecr-login@v2\n")
      File.write(File.join(docs_dir, "ecr-history.md"), "Historical ECR benchmark evidence.\n")

      _stdout, stderr, status = Open3.capture3(SCRIPT, repos_dir)

      refute status.success?
      assert_includes stderr, "benchmark-hugo/.github/workflows/hugo-benchmark.yml"
      assert_includes stderr, "benchmark-hugo/.github/actions/docker-benchmark/action.yml"
      assert_includes stderr, "ECR runtime support is retired"
      refute_includes stderr, "docs/ecr-history.md"
    end
  end

  def test_cache_interface_and_public_boundary_are_locked
    Dir.mktmpdir("benchmark-cache-interface-") do |repos_dir|
      repo_dir = File.join(repos_dir, "benchmark-hugo")
      workflows_dir = File.join(repo_dir, ".github", "workflows")
      FileUtils.mkdir_p(workflows_dir)
      File.write(File.join(repo_dir, ".boringcache.toml"), "workspace = \"boringcache/benchmark-hugo\"\n")
      File.write(File.join(repo_dir, "README.md"), "Synced from the monorepo with BORINGCACHE_API_TOKEN.\n")
      File.write(File.join(workflows_dir, "hugo-benchmark.yml"), <<~YAML)
        on:
          workflow_dispatch:
        jobs:
          benchmark:
            steps:
              - uses: boringcache/one@v1
                with:
                  setup: mise
                  mode: nx-proxy
                  workspace: boringcache/benchmark-hugo
      YAML

      _stdout, stderr, status = Open3.capture3(SCRIPT, repos_dir)

      refute status.success?
      assert_includes stderr, "retired token BORINGCACHE_API_TOKEN"
      assert_includes stderr, "private publishing detail \"synced from the monorepo\""
      assert_includes stderr, "use reviewed Action SHA"
      assert_includes stderr, "setup must be none"
      assert_includes stderr, "mode \"nx-proxy\" is not canonical"
      assert_includes stderr, "retired Action inputs workspace"
    end
  end
end
