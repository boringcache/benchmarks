require_relative "test_helper"

class CLITest < Minitest::Test
  include BenchFixture

  def test_matrix_lists_every_lane_and_runner_of_a_project_without_local
    assert_equal [
      { "case" => "demo/app", "lane" => "boringcache-demo", "runner" => "github", "runs_on" => "ubuntu-latest", "secrets" => [], "label" => "demo boringcache" },
      { "case" => "demo/app", "lane" => "remote", "runner" => "github", "runs_on" => "ubuntu-latest", "secrets" => ["REMOTE_TOKEN"], "label" => "demo remote" },
      { "case" => "demo/app", "lane" => "gha", "runner" => "github", "runs_on" => "ubuntu-latest", "secrets" => [], "label" => "demo gha" }
    ], matrix("app")
  end

  def test_matrix_filters_by_lane
    assert_equal ["remote"], matrix("app", "--lane", "remote").map { it["lane"] }
    assert_equal ["boringcache-demo", "gha"], matrix("app", "--lane", "boringcache-demo gha").map { it["lane"] }
  end

  def test_runner_env_reaches_the_build
    write "runners.toml", %([github]\nlabel = "ubuntu-latest"\n[local]\nlabel = "local"\nenv = { DEMO_CACHE = "from-runner" }\n)
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\n)

    with_fixture_env do
      Bench::CLI.new(%W[run demo/app --lane remote --phase cold --run-id r1 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call
    end

    assert_equal "from-runner\n", File.read(File.join(@root, ".work/demo/app/remote/upstream/out.txt"))
  end

  def test_lane_args_follow_the_plan_command_and_warm_overrides_them
    write "tools/demo/app/.boringcache.toml", %([adapters.demo]\ntag = "demo-app"\ncommand = ["bash", "-c", "echo \\"$0 $1\\" > upstream/out.txt"]\n)
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\nargs = ["cold-args", "${BENCH_SCOPE}"]\n[warm]\nargs = ["warm-args", "${BENCH_SCOPE}"]\n)
    outputs = %w[cold warm].map do |phase|
      with_fixture_env do
        Bench::CLI.new(%W[run demo/app --lane remote --phase #{phase} --run-id r7 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call
      end
      File.read(File.join(@root, ".work/demo/app/remote/upstream/out.txt"))
    end

    assert_equal ["cold-args demo-app-remote-local-r7\n", "warm-args demo-app-remote-local-r7\n"], outputs
  end

  def test_lane_program_replaces_docker_buildx_and_lane_prepare_runs_on_its_phase
    write "tools/demo/app/.boringcache.toml", %([adapters.demo]\ntag = "demo-app"\ncommand = ["docker", "buildx", "build", "upstream"]\n)
    write "bin/depot", "#!/usr/bin/env bash\necho \"depot $*\" > upstream/out.txt\n"
    File.chmod(0o755, File.join(@root, "bin/depot"))
    write "tools/demo/lanes/remote.toml", %(provider = "depot"\nlevel = "base"\nprogram = ["depot"]\nargs = ["--project", "p1"]\n[cold]\nprepare = ["touch cold-prepared"]\n)
    with_fixture_env do
      Bench::CLI.new(%W[run demo/app --lane remote --phase cold --run-id r8 --results #{@root}/tmp/results --work #{@root}/.work], catalog:, out: StringIO.new).call
    end

    run_dir = File.join(@root, ".work/demo/app/remote")
    assert_equal "depot build upstream --project p1\n", File.read(File.join(run_dir, "upstream/out.txt"))
    assert File.exist?(File.join(run_dir, "cold-prepared"))
  end

  private
    def matrix(*argv)
      out = StringIO.new
      Bench::CLI.new(["matrix", *argv], catalog:, out:).call
      JSON.parse(out.string)
    end
end
