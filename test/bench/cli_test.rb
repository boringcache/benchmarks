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

  private
    def matrix(*argv)
      out = StringIO.new
      Bench::CLI.new(["matrix", *argv], catalog:, out:).call
      JSON.parse(out.string)
    end
end
