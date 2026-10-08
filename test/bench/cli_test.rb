require_relative "test_helper"

class CLITest < Minitest::Test
  include BenchFixture

  def test_matrix_lists_every_lane_and_runner_of_a_project_without_local
    assert_equal [
      { "case" => "demo/app", "lane" => "boringcache-demo", "runner" => "github", "runs_on" => "ubuntu-24.04", "secrets" => [], "setup" => "", "label" => "github 4c · boringcache", "step" => "", "sha" => "", "cache_scope" => "", "continues" => "" },
      { "case" => "demo/app", "lane" => "remote", "runner" => "github", "runs_on" => "ubuntu-24.04", "secrets" => ["REMOTE_TOKEN"], "setup" => "", "label" => "github 4c · remote", "step" => "", "sha" => "", "cache_scope" => "", "continues" => "" },
      { "case" => "demo/app", "lane" => "gha", "runner" => "github", "runs_on" => "ubuntu-24.04", "secrets" => [], "setup" => "", "label" => "github 4c · gha", "step" => "", "sha" => "", "cache_scope" => "", "continues" => "" }
    ], matrix("app")
  end

  def test_rolling_matrix_gives_every_lane_of_a_case_one_step_and_commit
    assert_equal [["0", @upstream_sha]], matrix("app", "--rolling").map { it.values_at("step", "sha") }.uniq

    second = commit_upstream("two")
    third = commit_upstream("three")
    rolling_record("boringcache-demo", 0, @upstream_sha)
    rolling_record("remote", 0, @upstream_sha)
    rolling_record("remote", 1, second)
    assert_equal [["2", third]], matrix("app", "--rolling").map { it.values_at("step", "sha") }.uniq

    rolling_record("gha", 2, third)
    assert_empty matrix("app", "--rolling")
  end

  def test_rolling_matrix_continues_each_lanes_latest_passing_fresh_cache
    write "tmp/results/demo/app/remote-github-r1/remote-github-cold.json", JSON.generate("scope" => "remote-github-r1", "sha" => @upstream_sha, "exit_status" => 0, "output_ok" => true)
    write "tmp/results/demo/app/remote-github-r2/remote-github-cold.json", JSON.generate("scope" => "remote-github-r2", "sha" => @upstream_sha, "exit_status" => 1, "output_ok" => false)
    write "tmp/results/demo/app/remote-github-r3/remote-github-cold.json", JSON.generate("scope" => "remote-github-r3", "sha" => "f" * 40, "exit_status" => 0, "output_ok" => true)

    scopes = matrix("app", "--rolling").to_h { [it["lane"], it["cache_scope"]] }
    assert_equal({ "boringcache-demo" => "boringcache-demo-github-rolling", "remote" => "remote-github-r1", "gha" => "gha-github-rolling" }, scopes)
  end

  def test_rolling_matrix_marks_lanes_that_continue_their_own_rolling_cache
    commit_upstream("two")
    rolling_record("remote", 0, @upstream_sha)

    continues = matrix("app", "--rolling").to_h { [it["lane"], it["continues"]] }
    assert_equal({ "boringcache-demo" => "", "remote" => "true", "gha" => "" }, continues)
  end

  def test_rolling_matrix_never_seeds_from_a_canary_fresh_run
    write "tmp/results/demo/app/remote-github-r1/remote-github-cold.json", JSON.generate("scope" => "remote-github-r1", "sha" => @upstream_sha, "exit_status" => 0, "output_ok" => true)
    write "tmp/results/demo/app/remote-github-r2/remote-github-cold.json", JSON.generate("scope" => "remote-github-r2", "sha" => @upstream_sha, "exit_status" => 0, "output_ok" => true,
                                                                                       "versions" => { "boringcache" => "1.40.1", "boringcache_release" => "vcli-canary-0123456789ab" })

    assert_equal "remote-github-r1", matrix("app", "--rolling", "--lane", "remote").first["cache_scope"]
  end

  def test_matrix_takes_a_cli_release_for_fresh_runs_only
    assert_equal 3, matrix("app", "--cli", "vcli-canary-0123456789ab").size
    assert_equal 3, matrix("app", "--cli", "v1.41.0").size
    assert_matrix_refused "app", "--cli", "latest"
    assert_matrix_refused "app", "--cli", "vcli-canary-0123456789ab", "--rolling"
  end

  def test_matrix_filters_by_tool_case_insensitively
    write "tools/demo/tool.toml", %(name = "Demo Tool"\n[levels]\nbase = ["remote-cache"]\n)

    assert_equal 3, matrix("APP", "--tool", "demo tool").size
    assert_equal 3, matrix("app", "--tool", "demo").size
  end

  def test_a_remote_builder_lane_is_labelled_with_its_builder_not_the_runner
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\nmachine = "remote builder"\n)

    assert_equal "remote builder", matrix("app", "--lane", "remote").first["label"]
  end

  def test_matrix_filters_by_lane
    assert_equal ["remote"], matrix("app", "--lane", "remote").map { it["lane"] }
    assert_equal ["boringcache-demo", "gha"], matrix("app", "--lane", "boringcache-demo gha").map { it["lane"] }
  end

  def test_runner_env_reaches_the_build
    write "runners.toml", %([github]\nlabel = "ubuntu-24.04"\nmachine = "github 4c"\n[local]\nlabel = "local"\nmachine = "local"\nenv = { DEMO_CACHE = "from-runner" }\n)
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\n)

    with_fixture_env do
      Bench::CLI.new(%W[run demo/app --lane remote --phase cold --run-id r1 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call
    end

    assert_equal "from-runner\n", File.read(File.join(@root, ".work/demo/app/upstream/out.txt"))
  end

  def test_lane_args_follow_the_plan_command_and_warm_overrides_them
    write "tools/demo/app/.boringcache.toml", %([adapters.demo]\ntag = "demo-app"\ncommand = ["bash", "-c", "echo \\"$0 $1\\" > upstream/out.txt"]\n)
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\nargs = ["cold-args", "${BENCH_SCOPE}"]\n[warm]\nargs = ["warm-args", "${BENCH_SCOPE}"]\n)
    outputs = %w[cold warm].map do |phase|
      with_fixture_env do
        Bench::CLI.new(%W[run demo/app --lane remote --phase #{phase} --run-id r7 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call
      end
      File.read(File.join(@root, ".work/demo/app/upstream/out.txt"))
    end

    assert_equal ["cold-args demo-app-remote-local-r7\n", "warm-args demo-app-remote-local-r7\n"], outputs
  end

  def test_lane_program_replaces_docker_buildx_and_lane_prepare_runs_on_its_phase
    write "tools/demo/app/.boringcache.toml", %([adapters.demo]\ntag = "demo-app"\ncommand = ["docker", "buildx", "build", "upstream"]\n)
    write "bin/depot", "#!/usr/bin/env bash\necho \"depot $*\" > upstream/out.txt\n"
    File.chmod(0o755, File.join(@root, "bin/depot"))
    write "tools/demo/lanes/remote.toml", %(provider = "depot"\nlevel = "base"\nprogram = ["depot"]\nreplaces = ["docker", "buildx"]\nargs = ["--project", "p1"]\n[cold]\nprepare = ["touch cold-prepared"]\n)
    with_fixture_env do
      Bench::CLI.new(%W[run demo/app --lane remote --phase cold --run-id r8 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call
    end

    run_dir = File.join(@root, ".work/demo/app")
    assert_equal "depot build upstream --project p1\n", File.read(File.join(run_dir, "upstream/out.txt"))
    assert File.exist?(File.join(run_dir, "cold-prepared"))
  end

  def test_phase_wrap_and_finish_run_inside_the_build
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("check = ", %(directory = "upstream"\ncheck = ))
    write "tools/demo/app/.boringcache.toml", %([adapters.demo]\ntag = "demo-app"\ncommand = ["bash", "-c", "echo \\"wrapped=$WRAPPED\\" > out.txt"]\n)
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\n[cold]\nwrap = ["env", "WRAPPED=yes"]\nfinish = ["echo pushed > finished.txt"]\n)
    %w[cold warm].each do |phase|
      with_fixture_env do
        Bench::CLI.new(%W[run demo/app --lane remote --phase #{phase} --run-id r10 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call
      end
      run_dir = File.join(@root, ".work/demo/app")
      assert_equal "wrapped=#{"yes" if phase == "cold"}\n", File.read(File.join(run_dir, "upstream/out.txt"))
      assert_equal phase == "cold", File.exist?(File.join(run_dir, "upstream/finished.txt"))
    end
  end

  def test_probe_runs_lane_checks_without_a_checkout
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\nprobe = ["test \\"$BENCH_CASE\\" = demo/app && echo \\"$BENCH_SCOPE\\" > probed"]\n)
    probe = -> { with_fixture_env { Bench::CLI.new(%W[probe demo/app --lane remote --run-id r11 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call } }

    assert_equal 0, probe.call
    assert_equal "demo-app-remote-local-r11\n", File.read(File.join(@root, ".work/demo/app/probed"))
    refute File.exist?(File.join(@root, ".work/demo/app/upstream"))

    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\nprobe = ["false"]\n)
    assert_equal 1, probe.call
  end

  private
    def rolling_record(lane, step, sha)
      write "tmp/results/demo/app/#{lane}-github-rolling/#{lane}-github-rolling-#{step}.json", JSON.generate("step" => step, "sha" => sha)
    end

    def matrix(*argv)
      out = StringIO.new
      Bench::CLI.new(["matrix", *argv], catalog:, out:).call
      JSON.parse(out.string)
    end

    def assert_matrix_refused(*argv)
      out = StringIO.new
      _, err = capture_io { assert_equal 1, Bench::CLI.new(["matrix", *argv], catalog:, out:).call }
      assert_empty out.string
      assert_match(/--cli/, err)
    end
end
