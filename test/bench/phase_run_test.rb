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

  def test_an_archive_lane_wraps_the_plan_command_in_boringcache_run
    write "tools/demo/lanes/boringcache-archive.toml", %(provider = "boringcache"\nlevel = "base"\nprofile = "deps"\n)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]\n", "[runs]\nboringcache-archive = [\"local\"]\n")
    with_fixture_env do
      assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-archive", "--run-id", "r40")
    end

    command = %(bash -c echo "$DEMO_CACHE" > upstream/out.txt)
    assert_equal ["run --profile deps --no-git --fail-on-cache-error -- #{command}", "run --profile deps --no-git --fail-on-cache-error --read-only -- #{command}"],
                 File.readlines(File.join(@root, "stub.log"), chomp: true)
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
    assert_equal [false], steps.map { it["cache_seeded"] }.uniq
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

  def test_rolling_keeps_one_fixed_tag_that_fresh_runs_never_touch
    commit_upstream("two")
    plan_tag = -> { TomlRB.load_file(File.join(@root, ".work/demo/app/.boringcache.toml")).dig("adapters", "demo", "tag") }
    with_fixture_env do
      assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "cold", "--run-id", "r20")
      assert_equal "demo-app-boringcache-demo-local-r20", plan_tag.call
      assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "rolling")
      assert_equal "demo-app-boringcache-demo-local-rolling", plan_tag.call
      assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "cold", "--run-id", "r21")
      assert_equal 0, cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "rolling")
      assert_equal "demo-app-boringcache-demo-local-rolling", plan_tag.call
    end

    rolling = Dir[File.join(@root, "tmp/results/demo/app/boringcache-demo-local-rolling/*.json")].map { JSON.parse(File.read(it)) }
    assert_equal [[0, "boringcache-demo-local-rolling", false], [1, "boringcache-demo-local-rolling", false]],
                 rolling.map { it.values_at("step", "cache_scope", "cache_seeded") }.sort
  end

  def test_rolling_restores_the_fresh_seed_first_then_only_the_newest_rolling_cache
    seed = rolling_restore_key
    assert_includes seed, "restore_key<<BENCH_EOF\ndemo-app-remote-local-r30\nBENCH_EOF"
    assert_includes seed, "cache_key<<BENCH_EOF\ndemo-app-remote-local-r30-3\nBENCH_EOF"

    assert_includes rolling_restore_key("--continues"), "restore_key<<BENCH_EOF\ndemo-app-remote-local-r30-\nBENCH_EOF"
  end

  def test_a_rerun_of_an_older_rolling_step_never_overwrites_a_newer_one
    recorded = File.join(@root, "recorded")
    write "recorded/demo/app/remote-local-rolling/remote-local-rolling-4-901.json", JSON.generate("step" => 4, "sha" => @upstream_sha)

    assert_includes rolling_restore_key("--recorded", recorded), "ready<<BENCH_EOF\nfalse\nBENCH_EOF"

    write "recorded/demo/app/remote-local-rolling/remote-local-rolling-4-901.json", JSON.generate("step" => 3, "sha" => @upstream_sha)
    assert_includes rolling_restore_key("--recorded", recorded), "ready<<BENCH_EOF\ntrue\nBENCH_EOF"
  end

  def test_a_record_keeps_the_cache_key_the_lane_restored
    with_fixture_env do
      assert_equal 0, cli("prepare", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r31")
      assert_equal 0, cli("start", "demo/app", "--lane", "remote")
      assert_equal 0, cli("build", "demo/app", "--lane", "remote")
      ENV["BENCH_CACHE_RESTORED_KEY"] = "demo-app-remote-local-r30-2"
      assert_equal 0, cli("record", "demo/app", "--lane", "remote", "--exit-status", "0")
    ensure
      ENV.delete("BENCH_CACHE_RESTORED_KEY")
    end

    assert_equal "demo-app-remote-local-r30-2", record("remote-local-r31", "remote-local-cold")["cache_restored_key"]
  end

  def test_rolling_records_from_separate_dispatches_of_one_step_do_not_collide
    second = commit_upstream("two")
    with_fixture_env do
      %w[777 778].each do |run_id|
        ENV["GITHUB_RUN_ID"] = run_id
        assert_equal 0, cli("prepare", "demo/app", "--lane", "remote", "--phase", "rolling", "--sha", second, "--step", "5")
        assert_equal 0, cli("start", "demo/app", "--lane", "remote")
        assert_equal 0, cli("build", "demo/app", "--lane", "remote")
        assert_equal 0, cli("record", "demo/app", "--lane", "remote", "--exit-status", "0")
      end
    end

    assert_equal [5, 5], %w[777 778].map { record("remote-local-rolling", "remote-local-rolling-5-#{it}")["step"] }
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

  def test_prepare_exports_the_dockerfile_cache_mounts_for_cache_dance_with_platform_ids
    write "tools/demo/app/.boringcache.toml", <<~TOML
      workspace = "boringcache/benchmarks"
      [adapters.demo]
      tag = "demo-app"
      command = ["docker", "buildx", "build", "--file", "overlay/app.Dockerfile", "upstream"]
    TOML
    write "tools/demo/app/overlay/app.Dockerfile", <<~'DOCKERFILE'
      FROM scratch
      # For --mount=type=cache the value of target is the default cache id
      RUN --mount=type=cache,id=apt-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
          --mount=type=cache,target=/go/pkg/mod \
          --mount=type=cache,id=go-build-$TARGETARCH,target=/root/.cache/go-build true
      RUN --mount=type=cache,id=apt-${TARGETPLATFORM},target=/var/cache/apt --mount=type=bind,source=.,target=/src,readonly true
      RUN --mount=type=cache,dst=/root/.npm true
    DOCKERFILE
    map = lambda do |setup|
      write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\nsecrets = ["REMOTE_TOKEN"]\nsetup = #{setup}\n[env]\nDEMO_CACHE = "${REMOTE_TOKEN}"\n)
      outputs = File.join(@root, "github_output")
      FileUtils.rm_f(outputs)
      with_fixture_env do
        ENV.update("GITHUB_OUTPUT" => outputs, "GITHUB_ENV" => File.join(@root, "github_env"), "RUNNER_TEMP" => "/runner")
        assert_equal 0, cli("prepare", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r7", "--github")
      ensure
        %w[GITHUB_OUTPUT GITHUB_ENV RUNNER_TEMP].each { ENV.delete(it) }
      end
      JSON.parse(File.read(outputs)[/cache_dance_map<<BENCH_EOF\n(.*)\nBENCH_EOF/, 1]).transform_values { it.fetch("id") }
    end

    arch = { "x86_64" => "amd64", "aarch64" => "arm64", "arm64" => "arm64" }.fetch(Etc.uname[:machine])
    assert_equal({}, map.(%([])))
    assert_equal({ "/runner/cache-dance/apt-linux/#{arch}" => "apt-linux/#{arch}", "/runner/cache-dance/go/pkg/mod" => "/go/pkg/mod",
                   "/runner/cache-dance/go-build-#{arch}" => "go-build-#{arch}", "/runner/cache-dance/root/.npm" => "/root/.npm" }, map.(%(["cache-dance"])))
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

    def rolling_restore_key(*flags)
      outputs = File.join(@root, "github_output-#{flags.size}")
      with_fixture_env do
        ENV.update("GITHUB_OUTPUT" => outputs, "GITHUB_ENV" => File.join(@root, "github_env"))
        assert_equal 0, cli("prepare", "demo/app", "--lane", "remote", "--phase", "rolling", "--sha", @upstream_sha, "--step", "3",
                            "--cache-scope", "remote-local-r30", *flags, "--github")
      end
      File.read(outputs)
    end

    def record(scope, name)
      JSON.parse(File.read(File.join(@root, "tmp/results/demo/app", scope, "#{name}.json")))
    end
end
