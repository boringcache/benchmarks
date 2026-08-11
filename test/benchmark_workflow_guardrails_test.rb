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

  def test_benchmark_execution_must_not_race_a_moving_source_branch
    with_repo do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
            inputs:
              cli_version: {required: false, type: string}
              buildkit_image: {required: false, type: string}
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - run: git ls-remote https://github.com/example/upstream.git refs/heads/main
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "benchmark execution must use the committed source pin"
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

  def test_inline_canary_inputs_are_allowed
    with_repo do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
            inputs:
              cli_version: {required: false, type: string, default: ""}
              buildkit_image: {required: false, type: string, default: ""}
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
      YAML

      stdout, stderr, status = run_guard(repo_dir)

      assert status.success?, "inline canary inputs failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
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

  def test_adapter_benchmarks_reject_hidden_cache_composition
    with_repo("benchmark-storybook") do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
            inputs:
              cli_version:
                required: false
                type: string
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/setup-node@v6
                with:
                  cache: pnpm
              - uses: actions/cache@v5
                with:
                  path: |
                    .pnpm-store
                    ${{ env.GRADLE_USER_HOME }}
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  mode: turbo
                  cache-profiles: benchmark
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  mode: docker
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "one benchmark lane must use one BoringCache mode"
      assert_includes stderr, "adapter mode turbo must not hide an archive profile"
      assert_includes stderr, "pnpm store must not be hidden inside an adapter comparison"
      assert_includes stderr, "cache only Gradle build-cache directories"
      assert_includes stderr, "runtime setup must not add a hidden dependency cache"
    end
  end

  def test_one_adapter_and_its_matching_build_cache_are_allowed
    with_repo("benchmark-storybook") do |repo_dir|
      write_workflow(repo_dir, <<~YAML)
        on:
          workflow_dispatch:
            inputs:
              cli_version:
                required: false
                type: string
        jobs:
          benchmark:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/cache@v5
                with:
                  path: upstream/.turbo
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  mode: turbo
      YAML

      stdout, stderr, status = run_guard(repo_dir)

      assert status.success?, "pure adapter benchmark failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    end
  end

  def test_benchmark_jobs_must_be_flat_top_level_jobs
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
          nested:
            name: BC / amd64
            uses: ./.github/workflows/reusable-benchmark.yml
          dynamic:
            name: ${{ matrix.label }}
            strategy:
              matrix:
                include:
                  - label: GHA / arm64
            runs-on: ubuntu-latest
            steps:
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "benchmark metrics must be direct top-level jobs"
      assert_includes stderr, "benchmark job names must be flat"
      assert_includes stderr, "benchmark matrix job names must be flat"
    end
  end

  def test_step_level_actions_keep_benchmark_jobs_flat
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
            name: BoringCache amd64 commit
            runs-on: ubuntu-latest
            steps:
              - uses: ./.github/actions/prepare-workload
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
      YAML

      stdout, stderr, status = run_guard(repo_dir)

      assert status.success?, "flat benchmark job failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    end
  end

  def test_large_runner_overrides_are_manual_and_main_only
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
              runner_label:
                required: false
                type: string
        jobs:
          hardcoded:
            runs-on: ubuntu-latest-8-cores
            steps:
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
          unsafe-override:
            runs-on: ${{ inputs.runner_label || 'ubuntu-latest' }}
            steps:
              - run: docker version
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "large runners must be an empty runtime override"
      assert_includes stderr, "runner_label overrides must be restricted to manual main-branch dispatches"
    end
  end

  def test_fresh_and_rolling_entry_points_have_explicit_phases
    with_repo do |repo_dir|
      write_workflow(repo_dir, <<~YAML, "hugo-fresh-benchmark.yml")
        on:
          workflow_dispatch:
            inputs:
              cli_version: {required: false, type: string}
              buildkit_image: {required: false, type: string}
        jobs:
          cold:
            name: BoringCache Hugo cold
            runs-on: ubuntu-latest
            steps:
              - uses: boringcache/one@0123456789012345678901234567890123456789
                with:
                  cli-version: ${{ inputs.cli_version }}
                  managed-buildkit-image: ${{ inputs.buildkit_image }}
                  mode: docker
      YAML
      write_workflow(repo_dir, <<~YAML, "hugo-benchmark.yml")
        on:
          push:
            branches: [main]
        jobs:
          cold:
            name: BoringCache Hugo cold
            runs-on: ubuntu-latest
            steps:
              - run: docker version
          warm:
            name: BoringCache Hugo warm
            runs-on: ubuntu-latest
            steps:
              - run: docker version
      YAML

      _stdout, stderr, status = run_guard(repo_dir)

      refute status.success?
      assert_includes stderr, "fresh benchmarks must run on pull requests"
      assert_includes stderr, "fresh benchmarks must expose direct warm jobs"
      assert_includes stderr, "source-push rolling benchmarks must contain commit jobs only"
    end
  end

  private

  def with_repo(repo_name = "benchmark-hugo")
    Dir.mktmpdir("benchmark-leaf-boundary-") do |repos_dir|
      repo_dir = File.join(repos_dir, repo_name)
      FileUtils.mkdir_p(repo_dir)
      File.write(
        File.join(repo_dir, ".boringcache.toml"),
        "workspace = \"boringcache/#{repo_name}\"\n\n[adapters.docker]\ntag = \"benchmark\"\n"
      )
      yield repo_dir
    end
  end

  def write_workflow(repo_dir, contents, filename = "benchmark.yml")
    workflows_dir = File.join(repo_dir, ".github", "workflows")
    FileUtils.mkdir_p(workflows_dir)
    File.write(File.join(workflows_dir, filename), contents)
  end

  def run_guard(repo_dir)
    Open3.capture3(RbConfig.ruby, SCRIPT, File.dirname(repo_dir))
  end
end
