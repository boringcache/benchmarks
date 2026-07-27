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

  def test_required_boringcache_seed_must_fail_at_the_save_boundary
    Dir.mktmpdir("benchmark-workflow-guardrails-") do |repos_dir|
      workflows_dir = File.join(repos_dir, "benchmark-storybook", ".github", "workflows")
      FileUtils.mkdir_p(workflows_dir)
      workflow_path = File.join(workflows_dir, "storybook-benchmark.yml")
      File.write(workflow_path, <<~YAML)
        on:
          workflow_dispatch:
        jobs:
          seed-cache:
            steps:
              - uses: boringcache/one@v1
                with:
                  mode: nx
          warm:
            needs: seed-cache
            steps:
              - run: yarn build
      YAML

      _stdout, stderr, status = Open3.capture3(SCRIPT, repos_dir)

      refute status.success?
      assert_includes stderr, "benchmark-storybook/.github/workflows/storybook-benchmark.yml"
      assert_includes stderr, "must enable save-on-pull-request for the fresh lane"
      assert_includes stderr, "must set fail-on-cache-error for the fresh lane"

      File.write(workflow_path, <<~YAML)
        on:
          workflow_dispatch:
        jobs:
          seed-cache:
            steps:
              - uses: boringcache/one@v1
                with:
                  mode: nx
                  save-on-pull-request: ${{ inputs.cache_lane == 'fresh' }}
                  fail-on-cache-error: ${{ inputs.cache_lane == 'fresh' }}
          warm:
            needs: seed-cache
            steps:
              - run: yarn build
      YAML

      stdout, stderr, status = Open3.capture3(SCRIPT, repos_dir)

      assert status.success?, "workflow guardrails failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
      assert_includes stdout, "benchmark workflow guardrails passed"
    end
  end
end
