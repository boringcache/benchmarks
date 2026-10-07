require_relative "test_helper"

class PhaseRunTest < Minitest::Test
  include BenchFixture

  def test_boringcache_lane_runs_cold_then_warm_read_only
    with_fixture_env do
      assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-demo", "--run-id", "r1")
    end

    assert_equal ["demo ", "demo --read-only"], File.readlines(File.join(@root, "stub.log"), chomp: true)
    cold = record("boringcache-demo-local-r1", "boringcache-demo-local-cold")
    assert_equal({ "exit_status" => 0, "output_ok" => true, "sha" => @upstream_sha, "provider" => "boringcache" },
                 cold.slice("exit_status", "output_ok", "sha", "provider"))
    assert_equal ["boringcache-demo-local-cold.boringcache.jsonl"], cold["evidence"]
    assert_equal({ "operation" => "cache_session_summary", "duration_ms" => 7 }, cold.dig("provider_reported", "cache_session_summary"))
    assert_equal({ "boringcache" => "9.9.9" }, cold["versions"])
  end

  def test_plans_get_run_scoped_tags
    with_fixture_env { cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "cold", "--run-id", "r2") }

    plan = TomlRB.load_file(File.join(@root, ".work/demo/app/boringcache-demo/.boringcache.toml"))
    assert_equal "demo-app-boringcache-demo-local-r2", plan.dig("adapters", "demo", "tag")
    assert_equal "demo-deps-boringcache-demo-local-r2", plan.dig("entries", "deps", "tag")
  end

  def test_other_lanes_run_the_product_command_with_their_env
    with_fixture_env { assert_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r3") }

    output = File.read(File.join(@root, ".work/demo/app/remote/upstream/out.txt"))
    assert_equal "remote-secret\n", output
    assert_equal true, record("remote-local-r3", "remote-local-cold")["output_ok"]
  end

  def test_case_env_and_directory_apply_to_every_lane
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml"))
      .sub("check = ", %(directory = "upstream"\ncheck = )).concat(%([env]\nDEMO_STORE = "${BENCH_DIR}/store"\n))
    write "tools/demo/app/.boringcache.toml", <<~TOML
      [adapters.demo]
      tag = "demo-app"
      command = ["bash", "-c", "echo \\"$DEMO_CACHE $DEMO_STORE\\" > out.txt"]
    TOML

    with_fixture_env { assert_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r4") }

    run_dir = File.join(@root, ".work/demo/app/remote")
    assert_equal "remote-secret #{run_dir}/store\n", File.read(File.join(run_dir, "upstream/out.txt"))
  end

  def test_rolling_seeds_at_start_sha_then_follows_first_parent_commits
    second = commit_upstream("two")
    third = commit_upstream("three")
    out = StringIO.new

    with_fixture_env do
      3.times { assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "rolling") }
      assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "rolling", out:)
    end

    steps = Dir[File.join(@root, "tmp/results/demo/app/boringcache-demo-local-rolling/*.json")].map { JSON.parse(File.read(it)) }
    assert_equal [[0, @upstream_sha], [1, second], [2, third]], steps.sort_by { it["step"] }.map { it.values_at("step", "sha") }
    assert_equal ["demo "] * 3, File.readlines(File.join(@root, "stub.log"), chomp: true)
    assert_equal "demo/app boringcache-demo rolling: no upstream commit after the last step\n", out.string
  end

  def test_run_tool_passes_profiles_flags_and_command_after_double_dash
    write "tools/run/tool.toml", %([levels]\nbase = ["archive"]\n)
    write "tools/run/lanes/boringcache-run.toml", %(provider = "boringcache"\nlevel = "base"\n)
    write "tools/run/app/case.toml", %(repo = "#{File.join(@root, "upstream")}"\nbranch = "main"\nstart_sha = "#{@upstream_sha}"\ncheck = "test -s upstream/out.txt"\n[runs]\nboringcache-run = ["local"]\n)
    write "tools/run/app/.boringcache.toml", <<~TOML
      [entries.deps]
      tag = "deps"
      path = "upstream/deps"
      [profiles.build]
      entries = ["deps"]
      [adapters.run]
      profiles = ["build"]
      no-git = true
      command = ["make", "all"]
    TOML

    with_fixture_env { cli("run", "run/app", "--lane", "boringcache-run", "--run-id", "r5") }

    assert_equal ["run --profile build --no-git -- make all", "run --profile build --no-git --read-only -- make all"],
                 File.readlines(File.join(@root, "stub.log"), chomp: true)
  end

  def test_actions_only_lane_is_skipped_locally
    out = StringIO.new
    assert_equal 0, Bench::CLI.new(%w[run demo/app --lane gha], catalog:, out:).call
    assert_equal "skip demo/app gha on local: needs GitHub Actions\n", out.string
  end

  private
    def cli(*argv, out: StringIO.new)
      Bench::CLI.new([*argv, "--results", File.join(@root, "tmp/results"), "--work", File.join(@root, ".work")], catalog:, out:).call
    end

    def record(scope, name)
      JSON.parse(File.read(File.join(@root, "tmp/results/demo/app", scope, "#{name}.json")))
    end
end
