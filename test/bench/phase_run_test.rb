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

  def test_cold_refuses_a_rerun_attempt_but_warm_runs
    with_fixture_env do
      ENV["GITHUB_RUN_ATTEMPT"] = "2"
      refute_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r9")
      assert_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "warm", "--run-id", "r9")
    ensure
      ENV.delete("GITHUB_RUN_ATTEMPT")
    end
  end

  def test_plans_get_run_scoped_tags
    with_fixture_env { cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "cold", "--run-id", "r2") }

    plan = TomlRB.load_file(File.join(@root, ".work/demo/app/.boringcache.toml"))
    assert_equal "demo-app-boringcache-demo-local-r2", plan.dig("adapters", "demo", "tag")
    assert_equal "demo-deps-boringcache-demo-local-r2", plan.dig("entries", "deps", "tag")
  end

  def test_other_lanes_run_the_product_command_with_their_env
    with_fixture_env { assert_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r3") }

    output = File.read(File.join(@root, ".work/demo/app/upstream/out.txt"))
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

    run_dir = File.join(@root, ".work/demo/app")
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

  def test_rolling_prepare_uses_the_step_and_commit_it_is_given
    second = commit_upstream("two")
    with_fixture_env do
      assert_equal 0, cli("prepare", "demo/app", "--lane", "remote", "--phase", "rolling", "--sha", second, "--step", "5")
      assert_equal 0, cli("start", "demo/app", "--lane", "remote")
      assert_equal 0, cli("build", "demo/app", "--lane", "remote")
      assert_equal 0, cli("record", "demo/app", "--lane", "remote", "--exit-status", "0")
    end

    assert_equal [5, second], record("remote-local-rolling", "remote-local-rolling-5").values_at("step", "sha")
  end

  def test_a_failed_build_is_recorded_then_fails_the_step_on_actions
    out = StringIO.new
    with_fixture_env do
      ENV["GITHUB_ACTIONS"] = "true"
      assert_equal 0, cli("prepare", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r12")
      assert_equal 0, cli("start", "demo/app", "--lane", "remote")
      assert_equal 1, cli("record", "demo/app", "--lane", "remote", "--exit-status", "1", out:)
    ensure
      ENV.delete("GITHUB_ACTIONS")
    end

    assert_includes out.string, "::error title=demo/app remote cold::exit_status=1 output_ok=false"
    assert_equal 1, record("remote-local-r12", "remote-local-cold")["exit_status"]
  end

  def test_a_retried_attempt_keeps_the_first_attempts_record
    with_fixture_env do
      assert_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "warm", "--run-id", "r14")
      ENV["GITHUB_RUN_ATTEMPT"] = "2"
      assert_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "warm", "--run-id", "r14")
    ensure
      ENV.delete("GITHUB_RUN_ATTEMPT")
    end

    assert_nil record("remote-local-r14", "remote-local-warm")["attempt"]
    assert_equal 2, record("remote-local-r14", "remote-local-warm-attempt-2")["attempt"]
  end

  def test_records_carry_when_the_lane_saves_its_cache
    lane = File.join(@root, "tools/demo/lanes/remote.toml")
    with_fixture_env { cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r15") }
    write "tools/demo/lanes/remote.toml", File.read(lane).sub(/^level = .*$/) { "#{it}\ncache_save_timing = \"post-job\"" }
    with_fixture_env { cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r16") }

    assert_equal ["in-phase", "post-job"], %w[r15 r16].map { record("remote-local-#{it}", "remote-local-cold")["cache_save_timing"] }
  end

  def test_a_failed_output_check_fails_the_run
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub(/^check = .*$/, %(check = "false"))

    with_fixture_env { assert_equal 1, cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r13") }

    assert_equal [0, false], record("remote-local-r13", "remote-local-cold").values_at("exit_status", "output_ok")
  end

  def test_actions_steps_prepare_start_build_and_record_across_processes
    outputs = File.join(@root, "github_output")
    exported = File.join(@root, "github_env")
    with_fixture_env do
      ENV.update("GITHUB_OUTPUT" => outputs, "GITHUB_ENV" => exported)
      assert_equal 0, cli("prepare", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r6", "--github")
      assert_equal 0, cli("start", "demo/app", "--lane", "remote")
      assert_equal 0, cli("build", "demo/app", "--lane", "remote")
      assert_equal 0, cli("record", "demo/app", "--lane", "remote", "--exit-status", "0")
    ensure
      ENV.delete("GITHUB_OUTPUT")
      ENV.delete("GITHUB_ENV")
    end

    assert_includes File.read(outputs), "provider<<BENCH_EOF\nremote\nBENCH_EOF"
    assert_includes File.read(outputs), "cache_key<<BENCH_EOF\ndemo-app-remote-local-r6\nBENCH_EOF"
    assert_includes File.read(exported), "DEMO_CACHE=remote-secret"
    assert_includes File.read(exported), "BENCH_SCOPE=demo-app-remote-local-r6"
    assert_equal [0, true, @upstream_sha], record("remote-local-r6", "remote-local-cold").values_at("exit_status", "output_ok", "sha")
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
