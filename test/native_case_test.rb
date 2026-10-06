# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/benchmark-cases"

class NativeCaseTest < Minitest::Test
  def with_payload(id)
    item = BenchmarkCases.load_case(id)
    Dir.mktmpdir("native-case-") do |directory|
      FileUtils.cp_r(Dir[File.join(BenchmarkCases::ROOT, "cases", id, "payload", "{*,.[!.]*}")], directory)
      BenchmarkCases.copy_shared_actions(directory)
      yield item, directory
    end
  end

  def test_fresh_and_rolling_share_the_recipe_and_loaded_output
    with_payload("hugo") do |item, directory|
      fresh = NativeCase.write_action(item, directory: directory, lane: "fresh")
      rolling = NativeCase.write_action(item, directory: directory, lane: "rolling")
      assert_equal fresh.dig("runs", "steps", 0, "uses"), rolling.dig("runs", "steps", 0, "uses")
      assert_equal "true", fresh.dig("runs", "steps", 0, "with", "load_image")
      assert_equal "true", rolling.dig("runs", "steps", 0, "with", "load_image")
      refute rolling.dig("runs", "steps", 0, "with").key?("push_image")
      assert_equal "${{ inputs.cli_version }}", fresh.dig("runs", "steps", 0, "with", "cli_version")
    end
  end

  def test_shared_wrapper_keeps_the_reviewed_toolchain_and_environment
    with_payload("opentelemetry-java") do |item, directory|
      action = NativeCase.write_action(item, directory: directory, lane: "fresh")
      assert_equal "21", action.dig("runs", "steps", 0, "with", "java_version")
      assert_equal "${{ github.workspace }}/.gradle-user-home", action.dig("runs", "steps", 0, "env", "GRADLE_USER_HOME")
    end
  end

  def test_shared_workflow_cannot_dispatch_a_different_case
    item = BenchmarkCases.load_case("hugo-go")
    assert_equal "hugo-go", BenchmarkCases.plan(item).dig("inputs", "case_id")
    assert_raises(BenchmarkCases::Error) { BenchmarkCases.plan(item, inputs: {"case_id" => "storybook"}) }
  end

  def test_workload_variants_select_one_reviewed_recipe_and_report_identity
    with_payload("n8n") do |item, directory|
      %w[turbo docker runners distroless].each do |variant|
        plan = BenchmarkCases.plan(item, variant: variant)
        assert_equal variant, plan.dig("inputs", "variant")
        assert_equal "native-fresh-benchmark.yml", plan.fetch("workflow")
        action = NativeCase.write_action(item, directory: directory, lane: "fresh", variant: variant)
        step = action.dig("runs", "steps", 0)
        assert_equal variant, step.dig("with", "report_variant")
        assert_equal "26.7.0", step.dig("with", "node_version")
        if variant == "turbo"
          assert_equal "./.github/actions/n8n-turbo-benchmark", step.fetch("uses")
        else
          assert_equal "./.github/actions/n8n-docker-benchmark", step.fetch("uses")
          assert_match(/upstream\/docker\/images\//, step.dig("with", "dockerfile_path"))
        end
      end
      assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh") }
      assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh", variant: "unknown") }
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.plan(item, variant: "turbo", inputs: {"variant" => "docker"}) }
    end
  end

  def test_native_variant_recipes_are_validated_before_selection
    with_payload("mastodon") do |item, directory|
      action = NativeCase.write_action(item, directory: directory, lane: "fresh", variant: "server-sccache")
      assert_equal "server", action.dig("runs", "steps", 0, "with", "workload")
      assert_equal "${{ (inputs.strategy == 'actions-cache' || inputs.strategy == 'depot-actions-cache') && 'false' || 'true' }}", action.dig("runs", "steps", 0, "with", "docker_tool_cache")
      item["execution"]["native"]["variants"]["streaming"]["fresh_inputs"]["workload"] = "${{ inputs.workload }}"
      assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh", variant: "server") }
    end
  end

  def test_n8n_dependency_installation_does_not_increase_build_and_reuse_time
    assert_dependency_setup_excluded("n8n", "n8n-turbo-benchmark", ["pnpm", "--frozen-lockfile"])
  end

  def test_storybook_installation_and_sandbox_creation_do_not_increase_build_and_reuse_time
    assert_dependency_setup_excluded("storybook", "storybook-nx-benchmark", ["--immutable", "sandbox", "react-vite/default-ts"])
  end

  def assert_dependency_setup_excluded(case_id, action, commands)
    path = File.join(BenchmarkCases::ROOT, "cases", case_id, "payload/.github/actions", action, "action.yml")
    invocation = YAML.safe_load_file(path).dig("runs", "steps").find { |step| step["uses"] == "./.github/actions/native-cache-benchmark" }
    preparation = File.join(BenchmarkCases::ROOT, "cases", case_id, "payload", invocation.dig("with", "prepare_script"))
    commands.each { |command| assert_includes File.read(preparation), command }
    steps = YAML.safe_load_file(File.join(BenchmarkCases::ROOT, ".github/actions/native-cache-benchmark/action.yml")).dig("runs", "steps")
    timer = steps.index { |step| step["id"] == "build_timer" }
    setup = steps.index { |step| step["name"] == "Prepare workload dependencies outside measurement" }
    assert_operator steps.index { |step| step["id"] == "setup_timing" }, :<, setup
    assert_operator setup, :<, timer
    assert_operator timer, :<, steps.index { |step| step["id"] == "build" }
    reporter = steps.find { |step| step["name"] == "Write the benchmark phase evidence" }
    assert_equal "${{ steps.setup_timing.outputs.setup_seconds }}", reporter.dig("env", "SETUP_SECONDS")
    Dir.mktmpdir("benchmark-timing-") do |directory|
      clock = File.join(directory, "clock")
      output = File.join(directory, "output")
      date = File.join(directory, "date")
      File.write(date, "#!/bin/sh\ncat \"$CLOCK_FILE\"\n")
      File.chmod(0o755, date)
      environment = {"PATH" => "#{directory}:#{ENV.fetch('PATH')}", "CLOCK_FILE" => clock, "GITHUB_OUTPUT" => output}
      {"setup_timing" => [103, {"SETUP_STARTED_AT" => "100"}],
       "build_timer" => [113, {}], "build_timing" => [120, {"BUILD_STARTED_AT" => "113"}]}.each do |id, (time, inputs)|
        File.write(clock, time.to_s)
        step = steps.find { |entry| entry["id"] == id }
        _, errors, status = Open3.capture3(environment.merge(inputs), "bash", "-c", step.fetch("run"))
        assert status.success?, errors
      end
      values = File.readlines(output).to_h { |line| line.strip.split("=", 2) }
      assert_equal "3", values.fetch("setup_seconds")
      assert_equal "7", values.fetch("build_seconds")
    end
  end

  def test_provider_flags_preserve_the_comparator_and_cannot_change_phase_identity
    with_payload("posthog") do |item, directory|
      item["execution"]["native"]["provider_flags"] = {"actions-cache" => {"docker_tool_cache" => "false"}}
      item["execution"]["native"]["variants"]["combined"]["provider_flags"] = {"actions-cache" => {"docker_mount_cache" => "false"}}
      action = NativeCase.write_action(item, directory: directory, lane: "fresh", variant: "combined")
      %w[docker_tool_cache docker_mount_cache].each do |name|
        assert_equal "${{ (inputs.strategy == 'actions-cache' || inputs.strategy == 'depot-actions-cache') && 'false' || 'true' }}", action.dig("runs", "steps", 0, "with", name)
      end
      item["execution"]["native"]["provider_flags"]["actions-cache"]["phase"] = "true"
      error = assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh", variant: "combined") }
      assert_includes error.message, "cannot change shared runtime inputs"
    end
  end

  def test_native_planning_rejects_missing_output_verification_before_dispatch
    %w[chroma duckgres hugo linkerd2].each do |id|
      item = BenchmarkCases.load_case(id)
      assert_equal "native-fresh-benchmark.yml", BenchmarkCases.plan(item).fetch("workflow")
      assert_equal "native-rolling-benchmark.yml", BenchmarkCases.plan(item, lane: "rolling").fetch("workflow")
      item.fetch("execution").fetch("native").fetch("rolling_inputs").delete("load_image")
      error = assert_raises(NativeCase::Error) { BenchmarkCases.plan(item, lane: "rolling") }
      assert_includes error.message, "requires load_image=true"
    end
    with_payload("hugo-go") do |item, directory|
      path = File.join(directory, ".github/actions/native-cache-benchmark/action.yml")
      File.write(path, File.read(path).gsub("--verified-output", ""))
      error = assert_raises(NativeCase::Error) { NativeCase.verify_report(item.dig("execution", "native"), payload: directory, lane: "fresh") }
      assert_includes error.message, "does not report verified output"
    end
    %w[hugo-go qdrant spring-ai storybook opentelemetry-java].each do |id|
      assert_equal "native-fresh-benchmark.yml", BenchmarkCases.plan(BenchmarkCases.load_case(id), variant: id == "storybook" ? "archive-sandbox" : nil).fetch("workflow")
    end
  end

  def test_native_preparation_rejects_unverified_output_before_creating_a_checkout
    Dir.mktmpdir("native-preflight-") do |directory|
      target = File.join(directory, "workload")
      error = assert_raises(NativeCase::Error) do
        item = BenchmarkCases.load_case("n8n")
        item["execution"]["native"]["variants"]["docker"]["fresh_inputs"]["load_image"] = "false"
        BenchmarkCases.prepare(item, directory: target, native_lane: "fresh", variant: "docker")
      end
      assert_includes error.message, "requires load_image=true"
      refute Dir.exist?(target)
    end
  end

  def test_native_docker_variants_use_the_shared_loaded_image_check
    {"chroma" => [nil], "duckgres" => [nil], "hugo" => [nil], "linkerd2" => [nil], "n8n" => %w[docker runners distroless],
     "mastodon" => %w[server server-sccache streaming], "posthog" => %w[layers combined], "immich" => [nil]}.each do |id, variants|
      variants.each do |variant|
        item = BenchmarkCases.load_case(id)
        assert_equal "native-fresh-benchmark.yml", BenchmarkCases.plan(item, variant: variant).fetch("workflow")
        recipe = NativeCase.resolve(item.dig("execution", "native"), variant)
        assert_equal "true", recipe.dig("fresh_inputs", "load_image")
        action = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, "cases", id, "payload", recipe.fetch("action"), "action.yml")))
        steps = action.dig("runs", "steps")
        assert_operator steps.index { |step| step["id"] == "provider_build" }, :<, steps.index { |step| step["id"] == "output_verification" }
        steps.each_with_index do |step, index|
          next unless step["run"].to_s.match?(/\bdocker\s+(?:image|buildx\s+imagetools)\s+inspect\b|verify-docker-output\.rb/)
          assert_operator steps.index { |entry| entry["id"] == "provider_build" }, :<, index, "#{id}: #{step['name']} must run after build timing"
        end
        assert_operator steps.index { |step| step["id"] == "output_verification" }, :<, steps.index { |step| step["name"] == "Write the benchmark phase evidence" }
      end
    end
  end

  def test_posthog_wrapper_resolves_the_same_series_scope_for_cold_and_warm
    with_payload("posthog") do |item, directory|
      %w[layers combined].each do |variant|
        wrapper = NativeCase.write_action(item, directory: directory, lane: "fresh", variant: variant)
        recipe = NativeCase.resolve(item.dig("execution", "native"), variant)
        action = YAML.safe_load(File.read(File.join(directory, recipe.fetch("action"), "action.yml")))
        step = action.dig("runs", "steps").find { |entry| entry["id"] == "scope" }
        defaults = action.fetch("inputs").transform_values { |input| input.fetch("default", "") }
        %w[boringcache actions-cache].each do |provider|
          scopes = %w[publish warm].map do |phase|
            runtime = {"strategy" => provider, "phase" => phase, "benchmark_id" => recipe.fetch("benchmark_id")}
            inputs = defaults.merge(wrapper.dig("runs", "steps", 0, "with").transform_values do |value|
              value.gsub(/\$\{\{ inputs\.(\w+) \}\}/) { runtime.fetch(Regexp.last_match(1), "") }
            end)
            environment = step.fetch("env").transform_values do |value|
              value.gsub(/\$\{\{ inputs\.(\w+) \}\}/) { inputs.fetch(Regexp.last_match(1)) }
            end
            assert_equal "", environment.fetch("PUBLISHED_SCOPE")
            run_posthog_scope(item, directory, step, environment.merge("BENCHMARK_SERIES_ID" => "scope-screening-01", "BENCHMARK_SAMPLE" => "1"))
          end
          assert_equal scopes.first, scopes.last
          assert_equal "#{recipe.fetch('benchmark_id')}-series-scope-screening-01-s1-r123-a2", scopes.first
        end
      end
    end
  end

  def test_posthog_legacy_warm_requires_and_keeps_the_explicit_published_scope
    with_payload("posthog") do |item, directory|
      action = YAML.safe_load(File.read(File.join(directory, item.dig("execution", "native", "action"), "action.yml")))
      step = action.dig("runs", "steps").find { |entry| entry["id"] == "scope" }
      environment = {"BENCHMARK_ID" => "posthog", "CACHE_LANE" => "fresh", "PHASE" => "warm", "PLATFORM" => "linux/amd64", "PUBLISHED_SCOPE" => "seed-scope"}
      assert_equal "seed-scope", run_posthog_scope(item, directory, step, environment)
      assert_nil run_posthog_scope(item, directory, step, environment.merge("PUBLISHED_SCOPE" => ""), success: false)
    end
  end

  def test_shared_fresh_workflow_preserves_the_published_posthog_scope
    workflow = YAML.safe_load_file(File.join(BenchmarkCases::ROOT, ".github/workflows/native-fresh-benchmark.yml"))
    cold = workflow.fetch("jobs").fetch("cold")
    warm = workflow.fetch("jobs").fetch("warm")
    assert_equal "${{ steps.benchmark.outputs.cache_scope }}", cold.dig("outputs", "cache_scope")
    assert cold.fetch("steps").any? { |step| step["id"] == "benchmark" && step["uses"] == "./.github/actions/benchmark-phase" }
    assert_equal "${{ needs.cold.outputs.cache_scope }}", warm.fetch("steps").find { |step| step["uses"] == "./.github/actions/benchmark-phase" }.dig("with", "cache_scope")

    with_payload("posthog") do |item, directory|
      %w[layers combined].each do |variant|
        wrapper = NativeCase.write_action(item, directory: directory, lane: "fresh", variant: variant, suffix: "-canary")
        recipe = NativeCase.resolve(item.dig("execution", "native"), variant)
        assert_equal "${{ steps.phase.outputs.cache_scope }}", wrapper.dig("outputs", "cache_scope", "value")
        assert_equal "phase", wrapper.dig("runs", "steps", 0, "id")
        assert_equal "${{ inputs.cache_scope }}", wrapper.dig("runs", "steps", 0, "with", "cache_scope")
        action = YAML.safe_load_file(File.join(directory, recipe.fetch("action"), "action.yml"))
        assert_equal "${{ steps.scope.outputs.cache_scope }}", action.dig("outputs", "cache_scope", "value")
        step = action.dig("runs", "steps").find { |entry| entry["id"] == "scope" }
        defaults = action.fetch("inputs").transform_values { |input| input.fetch("default", "") }
        published_scopes = %w[boringcache actions-cache].map do |provider|
          published = ""
          %w[publish warm].each do |phase|
            runtime = {"strategy" => provider, "phase" => phase, "benchmark_id" => "#{recipe.fetch('benchmark_id')}-canary", "cache_scope" => published}
            inputs = defaults.merge(wrapper.dig("runs", "steps", 0, "with").transform_values do |value|
              value.gsub(/\$\{\{ inputs\.(\w+) \}\}/) { runtime.fetch(Regexp.last_match(1), "") }
            end)
            environment = step.fetch("env").transform_values do |value|
              value.gsub(/\$\{\{ inputs\.(\w+) \}\}/) { inputs.fetch(Regexp.last_match(1)) }
            end
            resolved = run_posthog_scope(item, directory, step, environment)
            assert_equal published, resolved if phase == "warm"
            published = resolved
          end
          assert_equal "#{recipe.fetch('benchmark_id')}-canary-run-r123-a2", published
          published
        end
        assert_equal 1, published_scopes.uniq.length, "The cold matrix output must be identical for both providers"
      end
    end
  end

  def run_posthog_scope(item, directory, step, environment, success: true)
    %w[benchmark-plan benchmark-phase scope-case-cache].each { |name| FileUtils.cp(File.join(BenchmarkCases::ROOT, "scripts", "#{name}.rb"), File.join(directory, "scripts")) }
    File.write(File.join(directory, "benchmark-context.json"), JSON.generate(item))
    FileUtils.cp(File.join(BenchmarkCases::ROOT, "cases/posthog/payload/.boringcache.toml"), directory)
    commands = File.join(directory, "commands")
    FileUtils.mkdir_p(commands)
    git = File.join(commands, "git")
    File.write(git, "#!/bin/sh\ncase \"$*\" in\n  'config -f .gitmodules submodule.upstream.url') echo 'https://github.com/PostHog/posthog.git' ;;\n  '-C upstream rev-parse HEAD') echo '#{item.dig('source', 'pins', 0, 'revision')}' ;;\n  *) exit 1 ;;\nesac\n")
    File.chmod(0o755, git)
    output = File.join(directory, "scope-output")
    File.write(output, "")
    env = {"PATH" => "#{commands}:#{ENV.fetch('PATH')}", "GITHUB_OUTPUT" => output,
      "GITHUB_RUN_ID" => "123", "GITHUB_RUN_ATTEMPT" => "2", "GITHUB_REF_NAME" => "main",
      "BENCHMARK_SERIES_ID" => nil, "BENCHMARK_SAMPLE" => nil}.merge(environment)
    _, errors, status = Open3.capture3(env, "bash", "-c", step.fetch("run"), chdir: directory)
    assert_equal success, status.success?, errors
    return unless status.success?
    File.readlines(output).to_h { |line| line.strip.split("=", 2) }.fetch("cache_scope")
  end

  def test_unreviewed_recipe_input_and_unsafe_suffix_are_rejected
    with_payload("hugo-go") do |item, directory|
      assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh", suffix: "\nOTHER=value") }
      item["execution"]["native"]["fresh_inputs"]["go_version"] = "${{ inputs.go_version }}"
      assert_raises(NativeCase::Error) { NativeCase.write_action(item, directory: directory, lane: "fresh") }
      refute File.exist?(File.join(directory, ".github", "actions", "benchmark-phase", "action.yml"))
    end
  end

  def test_case_actions_leave_product_evidence_uploads_to_the_shared_post_step
    Dir[File.join(BenchmarkCases::ROOT, "cases/*/payload/.github/actions/*/action.yml")].each do |path|
      steps = YAML.safe_load_file(path, aliases: true).dig("runs", "steps")
      steps.select { |step| step["uses"].to_s.start_with?("actions/upload-artifact@") }.each do |step|
        refute_match(/outputs\.evidence-path/, step.dig("with", "path").to_s, path)
      end
    end
  end

  def test_storybook_reports_the_selected_product_mode
    path = File.join(BenchmarkCases::ROOT, "cases/storybook/payload/.github/actions/storybook-nx-benchmark/action.yml")
    steps = YAML.safe_load_file(path).dig("runs", "steps")
    invocation = steps.find { |step| step["uses"] == "./.github/actions/native-cache-benchmark" }
    assert_equal "${{ inputs.workload == 'nx' && 'nx' || 'archive' }}", invocation.dig("with", "mode")
    assert_equal "nx", invocation.dig("with", "command_mode")
    shared = YAML.safe_load_file(File.join(BenchmarkCases::ROOT, ".github/actions/native-cache-benchmark/action.yml")).dig("runs", "steps")
    calls = shared.select { |step| step["uses"] == "./.github/actions/boringcache" }
    assert_equal ["${{ inputs.mode }}"], calls.map { |step| step.dig("with", "mode") }.uniq
    report = shared.find { |step| step["run"].to_s.include?("benchmark-report.rb phase") }
    assert_equal "${{ inputs.mode }}", report.dig("env", "BENCHMARK_MODE")
    assert_includes report.fetch("run"), '--mode "$BENCHMARK_MODE"'
  end

  def test_product_contract_view_resolves_the_wrapper_without_losing_adapter_or_failure_policy
    provider = YAML.safe_load(File.read(File.join(BenchmarkCases::ROOT, ".github/actions/boringcache/action.yml")))
    steps = provider.dig("runs", "steps")
    assert_equal "./.github/actions/retain-product-evidence", steps.find { |step| step["id"] == "retention" }.fetch("uses")
    assert_equal "provider", steps.find { |step| step["id"] == "provider" }.fetch("id")
    assert_equal "always()", steps.last.fetch("if")
    assert_equal "${{ steps.provider.outputs.evidence-path }}", steps.last.dig("env", "EVIDENCE_PATH")
    step = {"uses" => "./.github/actions/boringcache", "id" => "cache", "with" => {"mode" => "cargo", "trust-policy" => "restore", "fail-on-cache-miss" => "true"}}
    resolved = BenchmarkCases.resolve_provider_steps(step, provider)
    assert_equal steps.find { |step| step["id"] == "provider" }.fetch("uses"), resolved["uses"]
    assert_equal "cache", resolved["id"]
    assert_equal "cargo", resolved.dig("with", "mode")
    assert_equal "restore", resolved.dig("with", "trust-policy")
    assert_equal true, resolved.dig("with", "fail-on-cache-miss")
    assert_equal true, resolved.dig("with", "fail-on-cache-error")
    cold = BenchmarkCases.resolve_provider_steps({"uses" => "./.github/actions/boringcache", "with" => {"mode" => "go"}}, provider)
    assert_equal false, cold.dig("with", "fail-on-cache-miss")
    assert_equal true, cold.dig("with", "fail-on-cache-error")
    conditional = BenchmarkCases.resolve_provider_steps({"uses" => "./.github/actions/boringcache", "with" => {"mode" => "docker", "fail-on-cache-miss" => "${{ inputs.phase == 'warm' }}"}}, provider)
    assert_equal "${{ inputs.phase == 'warm' }}", conditional.dig("with", "fail-on-cache-miss")
    assert_equal true, steps.find { |step| step["id"] == "provider" }.dig("with", "fail-on-cache-error")
    assert_equal "${{ inputs.fail-on-cache-miss == 'true' }}", steps.find { |step| step["id"] == "provider" }.dig("with", "fail-on-cache-miss")
    assert_raises(BenchmarkCases::Error) { BenchmarkCases.resolve_provider_steps({"uses" => "./.github/actions/boringcache", "with" => {"obsolete" => "true"}}, provider) }
  end
end
