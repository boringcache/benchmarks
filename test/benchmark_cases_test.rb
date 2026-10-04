# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "tmpdir"
require_relative "../scripts/benchmark-cases"

class BenchmarkCasesTest < Minitest::Test
  def with_root
    Dir.mktmpdir("benchmark-cases-") do |root|
      FileUtils.cp_r(File.join(BenchmarkCases::ROOT, "schemas"), root)
      yield root
    end
  end

  def test_new_evaluation_uses_the_common_contract_and_cannot_execute_until_reviewed
    with_root do |root|
      item = BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Can task outputs be reused?", root: root)
      assert_equal "boringcache/benchmarks", item["workspace"]
      assert_equal "evaluation-only", item.dig("reporting", "publication")
      BenchmarkCases.validate([item], root: root)
      error = assert_raises(BenchmarkCases::Error) { BenchmarkCases.plan(item, root: root) }
      assert_includes error.message, "Review the recipe"
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.prepare(item, directory: File.join(root, "workload"), root: root) }
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Can task outputs be reused?", root: root) }
    end
  end

  def test_variant_selects_the_workflow_input_and_rejects_conflicting_inputs
    deno = BenchmarkCases.load_case("deno")
    plan = BenchmarkCases.plan(deno, variant: "compiler-only")
    assert_equal "compiler-only", plan.dig("inputs", "cache_profile")
    error = assert_raises(BenchmarkCases::Error) do
      BenchmarkCases.plan(deno, variant: "compiler-only", inputs: {"cache_profile" => "cargo-product"})
    end
    assert_includes error.message, "differs from the declared variant"
    obs = BenchmarkCases.load_case("obs-studio")
    %w[obs-studio-obs-actions-cache.yml obs-studio-obs-boringcache.yml].each do |workflow|
      assert_equal "ccache", BenchmarkCases.plan(obs, workflow: workflow, variant: "ccache").dig("inputs", "cache_tool")
    end
    zed = BenchmarkCases.load_case("zed")
    %w[target-only sccache-only combined].each do |variant|
      assert_equal variant, BenchmarkCases.plan(zed, variant: variant).dig("inputs", "cache_layer")
    end
  end

  def test_installed_action_dependencies_do_not_change_definitions_or_prepared_source
    with_root do |root|
      action = File.join(root, ".github/actions/retain-product-evidence")
      FileUtils.mkdir_p(File.join(action, "node_modules/client"))
      File.write(File.join(action, "package-lock.json"), "locked dependencies")
      File.write(File.join(action, "node_modules/client/index.js"), "installed code")
      assert_equal [File.join(action, "package-lock.json")], BenchmarkCases.shared_action_files(root: root)
      target = File.join(root, "prepared")
      BenchmarkCases.copy_shared_actions(target, root: root)
      assert_equal "locked dependencies", File.read(File.join(target, ".github/actions/retain-product-evidence/package-lock.json"))
      refute Dir.exist?(File.join(target, ".github/actions/retain-product-evidence/node_modules"))
    end
  end

  def test_contract_views_check_only_the_docker_adapter_used_by_the_case
    Dir.mktmpdir("benchmark-contract-view-") do |directory|
      items = %w[hugo-go hugo].map { |id| BenchmarkCases.load_case(id) }
      BenchmarkCases.stub(:documents, items) { BenchmarkCases.write_contract_views(directory) }
      refute File.exist?(File.join(directory, "benchmark-hugo-go/.github/actions/docker-benchmark/action.yml"))
      path = File.join(directory, "benchmark-hugo/.github/actions/docker-benchmark/action.yml")
      steps = YAML.safe_load_file(path).dig("runs", "steps")
      calls = steps.select { |step| step["uses"].to_s.start_with?("boringcache/one@") }
      assert_equal %w[publish restore], calls.map { |step| step.dig("with", "trust-policy") }
      assert calls.all? { |step| step.dig("with", "mode") == "docker" && step.dig("with", "fail-on-cache-error") == true }
    end
  end

  def test_zed_workflow_selects_only_the_requested_restore_variants
    workflow = YAML.safe_load_file(File.join(BenchmarkCases::ROOT, ".github/workflows/zed-zed-cargo-product.yml"))
    script = workflow.fetch("jobs").fetch("source").fetch("steps").find { |step| step["id"] == "source" }.fetch("run")
    Dir.mktmpdir("zed-variants-") do |directory|
      FileUtils.cp(File.join(BenchmarkCases::ROOT, "cases/zed/payload/cargo-layer-source.env"), directory)
      output_path = File.join(directory, "outputs")
      variants = %w[target-only sccache-only combined]
      [*variants, "all"].each do |selected|
        File.write(output_path, "")
        _output, errors, status = Open3.capture3({"GITHUB_OUTPUT" => output_path, "INPUT_CACHE_LAYER" => selected}, "bash", "-c", script, chdir: directory)
        assert status.success?, errors
        outputs = File.readlines(output_path).to_h { |line| line.strip.split("=", 2) }
        assert_match(/\A[0-9a-f]{40}\z/, outputs.fetch("base_sha"))
        assert_match(/\A[0-9a-f]{40}\z/, outputs.fetch("head_sha"))
        assert_equal selected == "all" ? variants : [selected], JSON.parse(outputs.fetch("cache_layers"))
      end
      _output, errors, status = Open3.capture3({"GITHUB_OUTPUT" => output_path, "INPUT_CACHE_LAYER" => "unsupported"}, "bash", "-c", script, chdir: directory)
      refute status.success?
      assert_includes errors, "Unsupported Zed cache layer"
    end
  end

  def test_obs_actions_storage_token_is_available_only_to_the_reporter
    workflow = YAML.safe_load_file(File.join(BenchmarkCases::ROOT, ".github/workflows/obs-studio-obs-actions-cache.yml"))
    assert_equal "read", workflow.dig("permissions", "actions")
    refute workflow.fetch("env").key?("GITHUB_TOKEN")
    writers = []
    workflow.fetch("jobs").each_value do |job|
      refute job.fetch("env").key?("GITHUB_TOKEN")
      job.fetch("steps").each do |step|
        if step.fetch("run", "").include?("./scripts/write_phase_result.rb")
          writers << step
          assert_equal "${{ github.token }}", step.dig("env", "GITHUB_TOKEN")
        else
          refute step.fetch("env", {}).key?("GITHUB_TOKEN")
        end
      end
    end
    assert_equal 4, writers.length
  end

  def test_draft_cannot_remove_its_blocker_without_an_execution_path
    with_root do |root|
      item = BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Can task outputs be reused?", root: root)
      item.fetch("execution")["blockers"] = []
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.validate([item], root: root) }
    end
  end

  def test_rejects_unpinned_sources_and_path_traversal_before_writing
    with_root do |root|
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.create("../outside", repository: "example/upstream", revision: "a" * 40, question: "Reuse?", root: root) }
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.create("example", repository: "example/upstream", revision: "main", question: "Reuse?", root: root) }
      refute Dir.exist?(File.join(root, "cases"))
    end
  end

  def test_source_advancement_preserves_other_reviewed_source_pairs
    with_root do |root|
      item = BenchmarkCases.create("example", repository: "example/upstream", revision: "a" * 40, question: "Reuse?", root: root)
      item["execution"]["source_prefix"] = "EXAMPLE"
      item["source"]["pins"] = [{"path" => "payload/benchmark-source.env", "kind" => "env", "revision" => "a" * 40},
        {"path" => "payload/layer-source.env", "kind" => "env", "revision" => "b" * 40}]
      FileUtils.mkdir_p(File.join(root, "cases/example/payload"))
      workload = File.join(root, "workload")
      FileUtils.mkdir_p(workload)
      File.write(File.join(workload, "benchmark-source.env"), "EXAMPLE_SOURCE_REPOSITORY=example/upstream\nEXAMPLE_BASE_SHA=#{'c' * 40}\nEXAMPLE_HEAD_SHA=#{'d' * 40}\n")
      BenchmarkCases.update_source(item, workload, root: root)
      assert_includes item.dig("source", "pins"), {"path" => "payload/layer-source.env", "kind" => "env", "revision" => "b" * 40}
      assert_equal ["b" * 40, "c" * 40, "d" * 40], item.dig("source", "pins").map { |pin| pin["revision"] }
      original = File.read(File.join(root, "cases/example/payload/benchmark-source.env"))
      File.write(File.join(workload, "benchmark-source.env"), original.sub("example/upstream", "other/upstream"))
      assert_raises(BenchmarkCases::Error) { BenchmarkCases.update_source(item, workload, root: root) }
      assert_equal original, File.read(File.join(root, "cases/example/payload/benchmark-source.env"))
    end
  end

  def test_source_sync_fetches_the_declared_branch_from_a_single_branch_shallow_checkout
    with_root do |root|
      git = ->(*args, directory:) { BenchmarkCases.command("git", "-c", "user.name=Benchmark test", "-c", "user.email=benchmark@localhost", "-c", "commit.gpgsign=false", *args, chdir: directory) }
      origin = File.join(root, "origin")
      FileUtils.mkdir_p(origin)
      git.call("init", "-b", "main", directory: origin)
      File.write(File.join(origin, "source.txt"), "base\n")
      git.call("add", ".", directory: origin)
      git.call("commit", "-m", "Base source", directory: origin)
      base = git.call("rev-parse", "HEAD", directory: origin).strip
      git.call("checkout", "-b", "dev", directory: origin)
      File.write(File.join(origin, "source.txt"), "changed\n")
      git.call("commit", "-am", "Changed source", directory: origin)
      head = git.call("rev-parse", "HEAD", directory: origin).strip
      git.call("checkout", "main", directory: origin)

      workload = File.join(root, "workload")
      FileUtils.mkdir_p(workload)
      git.call("init", directory: workload)
      git.call("-c", "protocol.file.allow=always", "submodule", "add", "--depth", "1", "--branch", "main", "file://#{origin}", "upstream", directory: workload)
      git.call("config", "-f", ".gitmodules", "submodule.upstream.branch", "dev", directory: workload)
      git.call("add", ".", directory: workload)
      git.call("commit", "-m", "Pinned workload", directory: workload)
      refute_includes git.call("branch", "-r", directory: File.join(workload, "upstream")), "origin/dev"

      item = BenchmarkCases.create("example", repository: "example/upstream", revision: base, question: "Reuse?", root: root)
      item.fetch("source").delete("revision")
      item["source"]["pins"] = [{"path" => "upstream", "kind" => "gitlink", "revision" => base}]
      item["execution"]["sync"] = "upstream-head"
      FileUtils.mkdir_p(File.join(root, "cases/example/payload"))
      FileUtils.cp(File.join(workload, ".gitmodules"), File.join(root, "cases/example/payload/.gitmodules"))
      original_command = BenchmarkCases.method(:command)
      command = lambda do |*args, **options|
        next original_command.call(*args, **options) unless args.first == "gh"
        case args.last
        when "repos/example/upstream/commits/dev" then JSON.generate({"sha" => head})
        when "repos/example/upstream/compare/#{base}...#{head}" then JSON.generate({"status" => "ahead", "merge_base_commit" => {"sha" => base}})
        else raise "Unexpected GitHub lookup: #{args.last}"
        end
      end
      verified_sha = nil
      BenchmarkCases.stub(:command, command) do
        BenchmarkCases.stub(:prepare, ->(*, **) { workload }) do
          BenchmarkCases.stub(:verify_recipe, ->(directory) { verified_sha = original_command.call("git", "rev-parse", "HEAD", chdir: File.join(directory, "upstream")).strip }) do
            result = BenchmarkCases.sync_source(item, root: root)
            assert_equal true, result["updated"]
            assert_equal head, result["head_sha"]
          end
        end
      end
      assert_equal head, verified_sha
      assert_equal head, JSON.parse(File.read(File.join(root, "cases/example/case.json"))).dig("source", "pins", 0, "revision")
    end
  end
end
