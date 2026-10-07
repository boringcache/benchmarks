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
    assert_equal({ "boringcache" => "9.9.9" }, cold["versions"])
  end

  def test_plans_get_run_scoped_tags
    with_fixture_env { cli("run", "demo/app", "--lane", "boringcache-demo", "--phase", "cold", "--run-id", "r2") }

    plan = TomlRB.load_file(File.join(@root, ".work/demo/app/boringcache-demo-local-r2/cold/.boringcache.toml"))
    assert_equal "demo-app-boringcache-demo-local-r2", plan.dig("adapters", "demo", "tag")
    assert_equal "demo-deps-boringcache-demo-local-r2", plan.dig("entries", "deps", "tag")
  end

  def test_other_lanes_run_the_product_command_with_their_env
    with_fixture_env { assert_equal 0, cli("run", "demo/app", "--lane", "remote", "--phase", "cold", "--run-id", "r3") }

    output = File.read(File.join(@root, ".work/demo/app/remote-local-r3/cold/upstream/out.txt"))
    assert_equal "remote-secret\n", output
    assert_equal true, record("remote-local-r3", "remote-local-cold")["output_ok"]
  end

  def test_actions_only_lane_is_skipped_locally
    out = StringIO.new
    assert_equal 0, Bench::CLI.new(%w[run demo/app --lane gha], catalog:, out:).call
    assert_equal "skip demo/app gha on local: needs GitHub Actions\n", out.string
  end

  private
    def cli(*argv)
      Bench::CLI.new([*argv, "--results", File.join(@root, "tmp/results"), "--work", File.join(@root, ".work")], catalog:, out: StringIO.new).call
    end

    def record(scope, name)
      JSON.parse(File.read(File.join(@root, "tmp/results/demo/app", scope, "#{name}.json")))
    end
end
