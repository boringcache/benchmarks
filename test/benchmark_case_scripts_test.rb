# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "open3"
require "rbconfig"
require "toml-rb"
require "json"
require "digest"
require "fileutils"
require "yaml"

class BenchmarkCaseScriptsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_grpc_requests_the_same_reviewed_outputs_for_every_provider
    with_case("grpc") do |directory|
      tools = File.join(directory, "upstream/tools")
      FileUtils.mkdir_p(tools)
      executable = File.join(tools, "bazel")
      File.write(executable, "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$BAZEL_ARGUMENTS\"\n")
      File.chmod(0o755, executable)
      output = File.join(directory, "arguments")
      command = JSON.parse(File.read(File.join(directory, "recipe-contract.json"))).dig("commands", "bazel")
      assert_includes command, "--remote_download_outputs=toplevel"
      environment = {"BAZEL_OUTPUT_USER_ROOT" => File.join(directory, "output-root"),
        "BAZEL_OUTPUT_BASE" => File.join(directory, "output-base"), "BAZEL_DISK_CACHE" => File.join(directory, "disk-cache"),
        "BAZEL_ARGUMENTS" => output, "BUILDBUDDY_API_KEY" => "test-key", "BUILDBUDDY_REMOTE_INSTANCE_NAME" => "test-series"}
      %w[boringcache actions-cache buildbuddy nativelink].each do |provider|
        _, errors, status = Open3.capture3(environment.merge("BAZEL_CACHE_STRATEGY" => provider,
          "NATIVELINK_INSTANCE" => "test-series", "NATIVELINK_PHASE" => "warm",
          "BUILDBUDDY_REMOTE_UPLOAD_LOCAL_RESULTS" => "false"), RbConfig.ruby,
          File.join(directory, "scripts/run-grpc-bazel-build.rb"), chdir: directory)
        assert status.success?, errors
        arguments = File.readlines(output, chomp: true)
        assert_equal command.drop(2), arguments.last(command.length - 2), provider
        assert_equal ["--remote_download_outputs=toplevel"], arguments.grep(/--remote_download/), provider
        if %w[buildbuddy nativelink].include?(provider)
          assert_includes arguments, "--remote_upload_local_results=false"
          assert_includes arguments, "--remote_instance_name=test-series"
        end
      end
      File.unlink(output)
      _, errors, status = Open3.capture3(environment.merge("BAZEL_CACHE_STRATEGY" => "buildbuddy",
        "BUILDBUDDY_REMOTE_INSTANCE_NAME" => ""), RbConfig.ruby,
        File.join(directory, "scripts/run-grpc-bazel-build.rb"), chdir: directory)
      refute status.success?
      assert_includes errors, "BUILDBUDDY_REMOTE_INSTANCE_NAME must not be empty"
      refute File.exist?(output)
    end
  end

  def test_grpc_uses_one_scope_for_each_sample_and_retains_only_rolling_seeds
    with_case("grpc") do |directory|
      steps = YAML.safe_load_file(File.join(directory, ".github/actions/grpc-bazel-benchmark/action.yml")).dig("runs", "steps")
      script = steps.find { |step| step["id"] == "scope" }.fetch("run")
      # Source provenance follows scope selection and is unrelated to cache identity.
      script = script.split(/^source_url=/).first
      output = File.join(directory, "scope-output")
      env = {"PATH" => "#{File.dirname(RbConfig.ruby)}:#{ENV.fetch('PATH')}", "GITHUB_OUTPUT" => output,
        "BENCHMARK_ID" => "grpc-bazel", "CACHE_LANE" => "fresh", "BENCHMARK_SERIES_ID" => "scope-01",
        "BENCHMARK_SAMPLE" => "1", "GITHUB_RUN_ID" => "123", "GITHUB_RUN_ATTEMPT" => "1", "GITHUB_REF_NAME" => "main"}
      plan = File.binread(File.join(directory, ".boringcache.toml"))
      run = lambda do |changes|
        File.binwrite(File.join(directory, ".boringcache.toml"), plan)
        File.write(output, "")
        stdout, stderr, status = Open3.capture3(env.merge(changes), "bash", "-c", script, chdir: directory)
        assert status.success?, "#{stdout}\n#{stderr}"
        File.readlines(output).to_h { |line| line.strip.split("=", 2) }
      end
      cold = run.call("PHASE" => "publish")
      assert_equal cold, run.call("PHASE" => "warm")
      assert_equal cold.fetch("cohort"), cold.fetch("buildbuddy_instance")
      assert_equal "ac-#{cold.fetch('cohort')}-cold", cold.fetch("gha_key")
      refute_equal cold.fetch("cohort"), run.call("BENCHMARK_SAMPLE" => "2").fetch("cohort")
      refute_equal cold.fetch("cohort"), run.call("GITHUB_RUN_ATTEMPT" => "2").fetch("cohort")
      first = run.call("CACHE_LANE" => "rolling")
      second = run.call("CACHE_LANE" => "rolling", "BENCHMARK_SAMPLE" => "2", "GITHUB_RUN_ID" => "124")
      assert_equal first.fetch("cohort"), second.fetch("cohort")
      refute_equal first.fetch("gha_key"), second.fetch("gha_key")
      refute_equal first.fetch("cohort"), run.call("CACHE_LANE" => "rolling", "BENCHMARK_SERIES_ID" => "scope-02").fetch("cohort")
    end
  end

  def test_grpc_checks_both_binaries_after_timing_and_before_recording_verification
    with_case("grpc") do |directory|
      steps = YAML.safe_load_file(File.join(directory, ".github/actions/grpc-bazel-benchmark/action.yml")).dig("runs", "steps")
      phase_artifact = steps.find { |step| step["name"] == "Retain the benchmark phase evidence" }
      assert_equal "benchmark-results/*.json", phase_artifact.dig("with", "path")
      install = steps.index { |step| step["name"] == "Install pinned NativeLink" }
      assert_operator steps.index { |step| step["id"] == "setup_timer" }, :<, install
      assert_operator install, :<, steps.index { |step| step["id"] == "build_timer" }
      check = steps.find { |step| step["id"] == "output_verification" }
      report = steps.find { |step| step["name"] == "Write the benchmark phase evidence" }
      assert_operator steps.index { |step| step["id"] == "build_timing" }, :<, steps.index(check)
      assert_operator steps.index(check), :<, steps.index(report)
      assert_includes report.fetch("run"), "--verified-output"
      target = File.join(directory, "upstream/bazel-bin/examples/cpp/csm")
      FileUtils.mkdir_p(target)
      %w[client server].each do |name|
        path = File.join(target, "csm_greeter_#{name}")
        File.write(path, "#!/bin/sh\nexit 0\n")
        File.chmod(0o755, path)
      end
      _, errors, status = Open3.capture3("bash", "-c", check.fetch("run"), chdir: directory)
      assert status.success?, errors
      File.unlink(File.join(target, "csm_greeter_server"))
      _, _, status = Open3.capture3("bash", "-c", check.fetch("run"), chdir: directory)
      refute status.success?
    end
  end

  def test_grpc_declares_every_comparison_arm_and_limits_its_provider_credential
    item = JSON.parse(File.read(File.join(ROOT, "cases", "grpc", "case.json")))
    item.fetch("execution").fetch("workflows").each do |entry|
      workflow = YAML.safe_load(File.read(File.join(ROOT, entry.fetch("path"))), aliases: true)
      refute workflow.fetch("env").key?("BUILDBUDDY_API_KEY")
      workflow.fetch("jobs").each_value do |job|
        next unless job.dig("strategy", "matrix", "include")
        providers = job.dig("strategy", "matrix", "include").map { |row| row.fetch("strategy") }
        assert_equal item.dig("comparison", "providers").sort, providers.sort
        assert_equal "${{ matrix.strategy == 'buildbuddy' && secrets.BUILDBUDDY_API_KEY || '' }}", job.dig("env", "BUILDBUDDY_API_KEY")
      end
    end
  end

  def with_case(id)
    Dir.mktmpdir("benchmark-recipe-") do |directory|
      FileUtils.cp_r(Dir[File.join(ROOT, "cases", id, "payload", "{*,.[!.]*}")], directory)
      FileUtils.mkdir_p(File.join(directory, "scripts"))
      %w[benchmark-plan benchmark-phase activate-docker-plan verify-docker-output run-benchmark-plan verify-upstream-recipe scope-case-cache prepare-source].each do |name|
        FileUtils.cp(File.join(ROOT, "scripts", "#{name}.rb"), File.join(directory, "scripts", "#{name}.rb"))
      end
      item = JSON.parse(File.read(File.join(ROOT, "cases", id, "case.json")))
      File.write(File.join(directory, "benchmark-context.json"), JSON.generate({"case_id" => id, "execution" => item.fetch("execution")}))
      yield directory
    end
  end

  def run_script(directory, name, *args)
    Open3.capture3(RbConfig.ruby, File.join(directory, "scripts", "#{name}.rb"), *args, chdir: directory)
  end

  def test_docker_output_projection_loads_each_native_image_without_publication
    %w[chroma duckgres hugo linkerd2 n8n mastodon posthog immich].each do |id|
      with_case(id) do |directory|
        action = YAML.safe_load(File.read(File.join(directory, ".github", "actions", "#{id}-docker-benchmark", "action.yml")))
        activate = action.dig("runs", "steps").find { |step| step["name"] == "Activate the BoringCache Docker plan" }
        environment = {"PATH" => "#{File.dirname(RbConfig.ruby)}:#{ENV.fetch('PATH')}",
          "LOAD_IMAGE" => "true", "PUSH_IMAGE" => "false", "IMAGE" => "example/image:local", "SOURCE_SHA" => "a" * 40, "SOURCE_TAG" => "test",
          "DOCKERFILE" => id == "n8n" ? "upstream/docker/images/n8n/Dockerfile" : "upstream/Dockerfile", "NODE_VERSION" => "26.7.0",
          "COMPILER_CACHE" => "sccache", "WORKLOAD" => "server", "TOOL_CACHE" => "false", "PRERELEASE" => "nightly.2026-10-03", "PLATFORM" => "linux/amd64",
          "MOUNT_CACHE" => "false", "NO_CACHE" => "false", "SOURCEMAP_SECRET" => "false", "BUILD_ID" => "123", "SOURCE_REF" => "main"}
        _, errors, status = Open3.capture3(environment, "bash", "-c", activate.fetch("run"), chdir: directory)
        assert status.success?, errors
        command = TomlRB.load_file(File.join(directory, ".boringcache.toml")).dig("adapters", "docker", "command")
        assert_includes command, "--load"
        refute_includes command, "--push"
        before = File.read(File.join(directory, ".boringcache.toml"))
        _, errors, status = run_script(directory, "activate-docker-plan", "--load", "true", "--push", "true", "--image", "example/image")
        refute status.success?
        assert_includes errors, "Choose either push or load"
        assert_equal before, File.read(File.join(directory, ".boringcache.toml"))
      end
    end
  end

  def test_docker_output_check_uses_each_provider_image_and_rejects_failed_inspection
    with_case("hugo") do |directory|
      executable = File.join(directory, "docker")
      File.write(executable, "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$DOCKER_ARGUMENTS\"\nexit \"$INSPECT_STATUS\"\n")
      File.chmod(0o755, executable)
      arguments = File.join(directory, "docker-arguments")
      output = File.join(directory, "outputs")
      environment = {"PATH" => "#{directory}:#{ENV.fetch('PATH')}", "DOCKER_ARGUMENTS" => arguments,
        "INSPECT_STATUS" => "0", "GITHUB_OUTPUT" => output}
      script = File.join(directory, "scripts", "verify-docker-output.rb")
      %w[boringcache actions-cache].each do |provider|
        _, errors, status = Open3.capture3(environment, RbConfig.ruby, script, "--strategy", provider, "--load", "true", "--image", "example/actions:local")
        assert status.success?, errors
        expected = provider == "boringcache" ? "hugo-benchmark:local" : "example/actions:local"
        assert_equal ["image", "inspect", expected], File.readlines(arguments, chomp: true)
        assert_includes File.read(output), "verified=true"
      end
      File.delete(arguments)
      File.delete(output)
      _, errors, status = Open3.capture3(environment, RbConfig.ruby, script, "--strategy", "actions-cache", "--load", "false", "--push", "false")
      assert status.success?, errors
      refute File.exist?(arguments)
      assert_equal "verified=false\n", File.read(output)
      File.delete(output)
      _, errors, status = Open3.capture3(environment.merge("INSPECT_STATUS" => "1"), RbConfig.ruby, script,
        "--strategy", "actions-cache", "--load", "true", "--image", "example/missing:local")
      refute status.success?
      assert_includes errors, "Cannot verify Docker output"
      refute File.exist?(output)
    end
  end

  def test_hugo_loaded_image_disables_attestations_and_keeps_the_publication_recipe
    %w[true false].each do |load|
      with_case("hugo") do |directory|
        _, errors, status = run_script(directory, "activate-docker-plan", "--load", load)
        assert status.success?, errors
        command = TomlRB.load_file(File.join(directory, ".boringcache.toml")).dig("adapters", "docker", "command")
        assert_equal load == "true" ? "false" : "mode=max", command.fetch(command.index("--provenance") + 1)
        assert_equal load == "true" ? "false" : "true", command.fetch(command.index("--sbom") + 1)
        action = YAML.safe_load(File.read(File.join(directory, ".github/actions/hugo-docker-benchmark/action.yml")))
        build = action.dig("runs", "steps").find { |step| step["id"] == "provider_build" }.fetch("with")
        assert_equal "${{ inputs.load_image != 'true' && 'mode=max' || 'false' }}", build.fetch("provenance")
        assert_equal "${{ inputs.load_image != 'true' }}", build.fetch("sbom")
      end
    end
  end

  def test_posthog_no_cache_option_preserves_its_declared_boolean_value
    with_case("posthog") do |directory|
      %w[false true].each do |value|
        _, errors, status = run_script(directory, "activate-docker-plan", "--dockerfile", "upstream/Dockerfile",
          "--platform", "linux/amd64", "--no-cache", value)
        assert status.success?, errors
        command = TomlRB.load_file(File.join(directory, ".boringcache.toml")).dig("adapters", "docker", "command")
        assert_equal value == "true", command.include?("--no-cache")
      end
      before = File.read(File.join(directory, ".boringcache.toml"))
      _, _, status = run_script(directory, "activate-docker-plan", "--no-cache", "unknown")
      refute status.success?
      assert_equal before, File.read(File.join(directory, ".boringcache.toml"))
    end
  end

  def test_clean_source_replay_checks_the_pin_before_removing_untracked_files
    with_case("hugo") do |directory|
      source = File.join(directory, "upstream")
      FileUtils.mkdir_p(source)
      [directory, source].each do |path|
        _, errors, status = Open3.capture3("git", "init", path)
        assert status.success?, errors
      end
      File.write(File.join(source, "source.txt"), "pinned source\n")
      _, errors, status = Open3.capture3("git", "-C", source, "add", "source.txt")
      assert status.success?, errors
      _, errors, status = Open3.capture3("git", "-C", source, "-c", "user.name=Benchmark test", "-c", "user.email=test@localhost",
        "-c", "commit.gpgsign=false", "commit", "-m", "Pin source")
      assert status.success?, errors
      sha, _, status = Open3.capture3("git", "-C", source, "rev-parse", "HEAD")
      assert status.success?
      untracked = File.join(source, "untracked.txt")
      File.write(untracked, "retain on mismatched pin\n")
      ["a" * 40, sha.strip].each do |pin|
        _, errors, status = Open3.capture3("git", "-C", directory, "update-index", "--add", "--cacheinfo", "160000,#{pin},upstream")
        assert status.success?, errors
        _, errors, status = run_script(directory, "prepare-source", "warm1")
        if pin == sha.strip
          assert status.success?, errors
          refute File.exist?(untracked)
          assert_equal "pinned source\n", File.read(File.join(source, "source.txt"))
        else
          refute status.success?
          assert_includes errors, "differs from the declared source pin"
          assert File.exist?(untracked)
        end
      end
    end
  end

  def test_mastodon_streaming_does_not_acquire_server_tool_cache
    with_case("mastodon") do |directory|
      _, error, status = run_script(directory, "activate-docker-plan", "--workload", "streaming", "--tool-cache", "false",
        "--source-sha", "a" * 40, "--prerelease", "nightly.2026-10-02", "--push", "false")
      assert status.success?, error
      docker = TomlRB.load_file(File.join(directory, ".boringcache.toml")).dig("adapters", "docker")
      assert_includes docker["command"], "upstream/streaming/Dockerfile"
      refute docker.key?("tool-cache")
      refute_includes docker["command"], "--push"
    end
  end

  def test_invalid_mastodon_projection_leaves_plan_unchanged
    with_case("mastodon") do |directory|
      path = File.join(directory, ".boringcache.toml")
      original = File.read(path)
      _, _, status = run_script(directory, "activate-docker-plan", "--workload", "streaming", "--tool-cache", "true", "--push", "false")
      refute status.success?
      assert_equal original, File.read(path)
    end
  end

  def test_immich_scopes_both_tags_and_preserves_workspace_and_command
    with_case("immich") do |directory|
      path = File.join(directory, ".boringcache.toml")
      original = TomlRB.load_file(path)
      _, error, status = run_script(directory, "scope-case-cache", "screening-01")
      assert status.success?, error
      plan = TomlRB.load_file(path)
      assert_equal "boringcache/benchmarks", plan["workspace"]
      assert_equal "screening-01-docker", plan.dig("adapters", "docker", "tag")
      assert_equal "screening-01-ccache", plan.dig("adapters", "ccache", "tag")
      assert_equal original.dig("adapters", "docker", "command"), plan.dig("adapters", "docker", "command")
    end
  end

  def test_obs_scope_changes_only_the_selected_adapter_identity
    with_case("obs-studio") do |directory|
      path = File.join(directory, ".boringcache.toml")
      original = TomlRB.load_file(path)
      _, error, status = run_script(directory, "scope_boringcache_plan", "ccache", "123", "2")
      assert status.success?, error
      actual = TomlRB.load_file(path)
      assert_equal "obs-studio-ccache-r123-a2", actual.dig("adapters", "ccache", "tag")
      original["adapters"]["ccache"]["tag"] = actual["adapters"]["ccache"]["tag"]
      assert_equal original, actual
    end
  end

  def test_reviewed_recipe_rejects_changed_upstream_files
    with_case("hugo-go") do |directory|
      source = File.join(directory, "upstream")
      FileUtils.mkdir_p(File.join(source, ".github", "workflows"))
      File.write(File.join(source, ".github", "workflows", "test.yml"), "changed workflow\n")
      _, error, status = run_script(directory, "verify-upstream-recipe")
      refute status.success?
      assert_includes error, "Upstream recipe changed"
    end
  end

  def test_continuous_obs_report_keeps_an_absent_cache_hit_unmeasured
    with_case("obs-studio") do |directory|
      FileUtils.cp(File.join(ROOT, "scripts/canonical/benchmark-report.rb"), File.join(directory, "scripts/benchmark-report.rb"))
      _, error, status = run_script(directory, "write_phase_result", "--surface", "xcode",
        "--strategy", "boringcache", "--phase", "rolling", "--continuous", "--cache-hit", "",
        "--source-sha", "a" * 40, "--restore-seconds", "0", "--build-seconds", "3")
      assert status.success?, error
      native = JSON.parse(File.read(File.join(directory, "benchmark-results/xcode-boringcache-rolling.json")))
      assert_equal "unmeasured", native.dig("classification", "cache_import_status")
      record = JSON.parse(File.read(File.join(directory, "benchmark-results/obs-studio-boringcache-xcode-rolling-commit.json")))
      assert_nil record.dig("cache", "hit")
      assert_equal 3.0, record.dig("timing", "build_seconds")
    end
  end

  def test_selected_recipe_contract_checks_each_declared_plan
    with_case("zed") do |directory|
      source = File.join(directory, "upstream")
      FileUtils.mkdir_p(source)
      File.write(File.join(source, "recipe.txt"), "reviewed recipe\n")
      command = ["cargo", "build", "--release"]
      paths = %w[primary.toml remote.toml]
      paths.each { |path| File.write(File.join(directory, path), "[adapters.cargo]\ncommand = #{JSON.generate(command)}\n") }
      contract = {"upstream_files" => {"recipe.txt" => Digest::SHA256.file(File.join(source, "recipe.txt")).hexdigest},
        "commands" => {}, "plans" => [{"adapter" => "cargo", "paths" => paths, "command" => command}]}
      File.write(File.join(directory, "selected-recipe.json"), JSON.generate(contract))
      _, error, status = run_script(directory, "verify-upstream-recipe", source, "selected-recipe.json")
      assert status.success?, error
      File.write(File.join(directory, "remote.toml"), "[adapters.cargo]\ncommand = [\"cargo\", \"check\"]\n")
      _, error, status = run_script(directory, "verify-upstream-recipe", source, "selected-recipe.json")
      refute status.success?
      assert_includes error, "remote.toml differs from the reviewed recipe"
    end
  end

  def test_parent_recipe_exception_is_limited_to_its_exact_revision_and_file_set
    with_case("hugo-go") do |directory|
      source = File.join(directory, "upstream")
      FileUtils.mkdir_p(source)
      git = ->(*args) { Open3.capture2e("git", "-C", source, "-c", "user.name=Benchmark test", "-c", "user.email=benchmark@localhost", "-c", "commit.gpgsign=false", *args) }
      _, status = git.call("init")
      assert status.success?
      File.write(File.join(source, "recipe.txt"), "parent recipe\n")
      git.call("add", ".")
      _, status = git.call("commit", "-m", "Parent recipe")
      assert status.success?
      revision, = git.call("rev-parse", "HEAD")
      parent = {"recipe.txt" => Digest::SHA256.hexdigest("parent recipe\n")}
      contract = {"upstream_files" => {"recipe.txt" => Digest::SHA256.hexdigest("new recipe\n")},
        "upstream_files_by_revision" => {revision.strip => parent}, "commands" => {}}
      path = File.join(directory, "recipe-contract.json")
      File.write(path, JSON.generate(contract))
      _, error, status = run_script(directory, "verify-upstream-recipe")
      assert status.success?, error
      git.call("commit", "--allow-empty", "-m", "Another revision")
      _, error, status = run_script(directory, "verify-upstream-recipe")
      refute status.success?
      assert_includes error, "Upstream recipe changed"
      File.write(File.join(source, "recipe.txt"), "new recipe\n")
      _, error, status = run_script(directory, "verify-upstream-recipe")
      assert status.success?, error
      current, = git.call("rev-parse", "HEAD")
      contract["upstream_files_by_revision"] = {current.strip => {}}
      File.write(path, JSON.generate(contract))
      _, error, status = run_script(directory, "verify-upstream-recipe")
      refute status.success?
      assert_includes error, "changes the reviewed file set"
    end
  end

  def test_prepared_snapshot_recipe_uses_only_its_verified_upstream_parent
    with_case("hugo-go") do |directory|
      git = ->(*args) { Open3.capture2e("git", "-C", directory, "-c", "user.name=Benchmark test", "-c", "user.email=benchmark@localhost", "-c", "commit.gpgsign=false", *args) }
      git.call("init")
      File.write(File.join(directory, "recipe.txt"), "parent recipe\n")
      git.call("add", ".")
      _, status = git.call("commit", "-m", "Upstream source")
      assert status.success?
      revision, = git.call("rev-parse", "HEAD")
      contract = {"upstream_files" => {"recipe.txt" => Digest::SHA256.hexdigest("new recipe\n")},
        "upstream_files_by_revision" => {revision.strip => {"recipe.txt" => Digest::SHA256.hexdigest("parent recipe\n")}}, "commands" => {}}
      File.write(File.join(directory, "recipe-contract.json"), JSON.generate(contract))
      git.call("add", ".")
      git.call("commit", "-m", "Prepare workload")
      context = File.join(directory, "benchmark-context.json")
      File.write(context, JSON.generate({"source" => {"revision" => revision.strip}}))
      _, error, status = run_script(directory, "verify-upstream-recipe", directory)
      assert status.success?, error
      git.call("commit", "--allow-empty", "-m", "Unexpected wrapper")
      _, error, status = run_script(directory, "verify-upstream-recipe", directory)
      refute status.success?
      assert_includes error, "does not have the declared upstream parent"
    end
  end

  def test_deno_profile_selects_exactly_one_declared_profile
    with_case("deno") do |directory|
      path = File.join(directory, ".boringcache.toml")
      _, error, status = run_script(directory, "select-deno-cargo-profile", "compiler-only")
      assert status.success?, error
      plan = TomlRB.load_file(path)
      assert_equal ["compiler-only"], plan.dig("adapters", "cargo", "profiles")
      before = File.read(path)
      _, _, status = run_script(directory, "select-deno-cargo-profile", "unknown")
      refute status.success?
      assert_equal before, File.read(path)
    end
  end

  def test_zed_layer_cohort_is_shared_within_a_run_and_fresh_for_a_new_attempt
    with_case("zed") do |directory|
      source = File.join(directory, "upstream")
      FileUtils.mkdir_p(source)
      _, error, status = Open3.capture3("git", "init", source)
      assert status.success?, error
      run = lambda do |lane, attempt|
        _, error, status = Open3.capture3({"GITHUB_RUN_ID" => "123", "GITHUB_RUN_ATTEMPT" => attempt, "BENCHMARK_SERIES_ID" => "screening", "BENCHMARK_SAMPLE" => "1"},
          RbConfig.ruby, File.join(directory, "scripts", "activate-cargo-plan.rb"), lane, "primary", chdir: directory)
        assert status.success?, error
        TomlRB.load_file(File.join(source, ".boringcache.toml"))
      end
      cold = run.call("cold", "1")
      target = run.call("target-only", "1")
      assert_equal cold.dig("entries", "zed-target", "tag"), target.dig("entries", "zed-target", "tag")
      assert_equal "none", target.dig("adapters", "cargo", "compiler-cache")
      retry_plan = run.call("cold", "2")
      refute_equal cold.dig("entries", "zed-target", "tag"), retry_plan.dig("entries", "zed-target", "tag")
      assert_equal "boringcache/benchmarks", retry_plan["workspace"]
    end
  end
end
