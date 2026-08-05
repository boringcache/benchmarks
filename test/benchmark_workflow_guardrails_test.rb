# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "rbconfig"
require "fileutils"
require "tmpdir"

class BenchmarkWorkflowGuardrailsTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/check-workflow-guardrails.rb", __dir__)
  REPOS_DIR = ENV["BENCHMARK_REPOS_DIR"] || [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ].find { |candidate| Dir.exist?(candidate) }

  def test_current_benchmarks_keep_the_leaf_boundary
    skip "benchmark repositories checkout not available" unless REPOS_DIR

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, SCRIPT, REPOS_DIR)

    assert status.success?, "leaf boundary failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stdout, "benchmark leaf boundary passed"
  end

  def test_minimal_product_run_and_raw_evidence_are_allowed
    with_repo do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
            inputs:
              cli_version:
                required: false
                type: string
              buildkit_image:
                required: false
                type: string
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/checkout@v6
              - name: Run released product
                env:
                  BORINGCACHE_OBSERVABILITY_JSONL_PATH: ${{ runner.temp }}/boringcache.jsonl
                uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
              - name: Retain product evidence
                uses: actions/upload-artifact@v6
                with:
                  path: ${{ runner.temp }}/boringcache.jsonl
      YAML

      stdout, stderr, status = run_guard(repo_dir)

      assert status.success?, "minimal product run failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
      assert_includes stdout, "benchmark leaf boundary passed: 1 repositories"
    end
  end

  def test_product_assertions_installers_and_lifecycle_wrappers_are_rejected
    with_repo do |repo_dir|
      scripts_dir = File.join(repo_dir, "scripts")
      FileUtils.mkdir_p(scripts_dir)
      File.write(File.join(scripts_dir, "install-boringcache-cli.sh"), "#!/usr/bin/env bash\n")
      File.write(File.join(scripts_dir, "assert-boringcache-docker-product-run.sh"), <<~SH)
        #!/usr/bin/env bash
        jq -e '.buildkit.vertex_spans and .cache_errors == 0' cache_session_summary.json
      SH
      File.write(File.join(scripts_dir, "run-boringcache-docker-lane.sh"), <<~SH)
        #!/usr/bin/env bash
        curl http://127.0.0.1:22243/_boringcache/status
      SH
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - run: boringcache docker --tag hugo -- docker buildx build .
              - run: boringcache inspect boringcache/benchmark-hugo hugo --json
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "remove copied CLI installer"
      assert_includes stderr, "remove BoringCache internal assertion helper"
      assert_includes stderr, "remove BoringCache lifecycle wrapper"
      assert_includes stderr, "must retain product evidence without parsing cache-session internals"
      assert_includes stderr, "must not assert BuildKit receipt internals"
      assert_includes stderr, "must not duplicate product cache-error assertions"
      assert_includes stderr, "must use one benchmark product lifecycle instead of secondary cache inspection"
      assert_includes stderr, "must not manage the product proxy lifecycle"
    end
  end

  def test_product_observability_must_be_uploaded_without_a_repo_local_normalizer
    with_repo do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - name: Run released product
                env:
                  BORINGCACHE_OBSERVABILITY_JSONL_PATH: ${{ runner.temp }}/boringcache.jsonl
                run: boringcache cargo -- cargo build --release
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "product-emitted observability must be retained as an unmodified artifact"
    end
  end

  def test_first_class_canary_inputs_are_required_and_must_reach_the_product
    with_repo do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  mode: docker
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "must expose the standard cli_version canary input"
      assert_includes stderr, "must forward inputs.cli_version"
      assert_includes stderr, "must expose the standard buildkit_image canary input"
      assert_includes stderr, "must forward inputs.buildkit_image"
    end
  end

  def test_cli_release_must_not_be_hardcoded
    with_repo do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
            inputs:
              cli_version:
                required: false
                type: string
                default: v1.16.8
              buildkit_image:
                required: false
                type: string
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version || 'v1.16.8' }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "must not give cli_version a pinned release default"
      assert_includes stderr, "must leave the CLI version to the Action default"
    end
  end

  private

  def with_repo
    Dir.mktmpdir("benchmark-leaf-boundary-") do |repos_dir|
      repo_dir = File.join(repos_dir, "benchmark-hugo")
      FileUtils.mkdir_p(repo_dir)
      File.write(
        File.join(repo_dir, ".boringcache.toml"),
        "workspace = \"boringcache/benchmark-hugo\"\n\n[adapters.docker]\ntag = \"hugo\"\n"
      )
      yield repo_dir
    end
  end

  def write_workflow(repo_dir, contents)
    workflows_dir = File.join(repo_dir, ".github", "workflows")
    FileUtils.mkdir_p(workflows_dir)
    File.write(File.join(workflows_dir, "benchmark.yml"), contents)
  end

  def run_guard(repo_dir)
    Open3.capture3(RbConfig.ruby, SCRIPT, File.dirname(repo_dir))
  end
end
