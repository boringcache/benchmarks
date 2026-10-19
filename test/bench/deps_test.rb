require "minitest/autorun"
require "tmpdir"
require_relative "../../scripts/deps"

class DepsTest < Minitest::Test
  def setup
    @plan = Deps.plan
    @deps = Deps.new(@plan, run_id: "123")
  end

  def test_every_case_lane_and_runner_seeds_updates_and_verifies
    Deps::KINDS.each do |kind|
      jobs = @deps.jobs(kind)
      own = jobs.select { it["producer"] == it["runner"] }
      assert_equal @plan["cases"].size * @plan["lanes"].size * @plan["runners"].size, own.size
      assert_equal jobs.size, jobs.map { it["name"] }.uniq.size
    end
    assert_equal @plan["cases"].size * @plan["lanes"].size, Deps.new(@plan, run_id: "1", preflight: true).jobs("seed").size
    assert_equal [@plan["lanes"].size, ["discourse-bundler"]], Deps.new(@plan, run_id: "1", preflight: true, only: "discourse-bundler").jobs("seed").then { [it.size, it.map { it["case"] }.uniq] }
    assert_raises(ArgumentError) { Deps.new(@plan, run_id: "1", only: "nope") }
  end

  def test_seed_installs_the_earlier_lockfile_and_later_jobs_the_update
    before, after = @plan.dig("cases", "discourse-bundler", "steps", 0)
    seed, update, verify = Deps::KINDS.map { |kind| @deps.jobs(kind).find { it["case"] == "discourse-bundler" && it["runner"] == "github" && it["lane"] == "boringcache" } }
    assert_equal [before, after, after], [seed, update, verify].map { it["sha"] }
    assert_equal ["deps-123-discourse-bundler-github"], [seed, update, verify].map { it["key"] }.uniq
  end

  def test_keys_follow_the_lockfile_and_share_a_restore_prefix
    with_job("update", "posthog-uv") do |job, _dir|
      File.write(File.join(job.upstream, "uv.lock"), "version = 1\n")
      digest = Digest::SHA256.hexdigest("version = 1\n")[0, 16]
      assert_equal "key=deps-123-posthog-uv-github-#{digest}\nrestore_key=deps-123-posthog-uv-github-\n", job.keys
    end
  end

  def test_case_environment_points_at_the_run_directory
    with_job("seed", "posthog-pnpm") do |job, _dir|
      assert_match %r{\Anpm_config_store_dir=/.+/bench-deps/posthog-pnpm/\.pnpm-store\n}, job.env_lines
    end
  end

  def test_update_records_restore_install_and_save_and_the_cache_size
    with_job("update", "posthog-pnpm") do |job, dir|
      FileUtils.mkdir_p(File.join("bench-deps", "posthog-pnpm", ".pnpm-store", "v10"))
      File.write(File.join("bench-deps", "posthog-pnpm", ".pnpm-store", "v10", "a"), "x" * 10)
      File.write(File.join("bench-deps", "posthog-pnpm", ".pnpm-store", "v10", "b"), "y" * 5)
      job.measure
      File.write(File.join(dir, "marks"), %w[restore_start\ 1.0\ eth0=0,0 restore_end\ 3.0\ eth0=100,0 install_start\ 3.5\ eth0=100,0
                                              install_end\ 10.0\ eth0=300,0 save_start\ 10.5\ eth0=300,0 save_end\ 12.5\ eth0=300,40].join("\n"))
      record = job.record("restore" => "success", "restore_check" => "", "install" => "success", "save" => "success", "lookup" => "success")
      assert_equal [2.0, 6.5, 2.0], %w[restore install save].map { record.dig(it, "seconds") }
      assert_equal [100, 40], [record.dig("restore", "network_bytes"), record.dig("save", "network_bytes")]
      assert_equal({ "bytes" => 15, "files" => 2 }, record["cache"])
      assert_equal [0, true], record.values_at("exit_status", "output_ok")
    end
  end

  def test_a_failed_install_fails_the_record
    with_job("seed", "posthog-pnpm") do |job, _dir|
      record = job.record("install" => "failure", "save" => "success", "lookup" => "success")
      assert_equal [1, false], record.values_at("exit_status", "output_ok")
    end
  end

  def test_report_pairs_update_and_verify_records
    Dir.mktmpdir("deps-report") do |dir|
      base = { "case" => "posthog-pnpm", "lane" => "boringcache", "machine" => "github 4c", "versions" => { "boringcache" => "1.42.0" }, "exit_status" => 0, "output_ok" => true }
      File.write(File.join(dir, "update.json"), JSON.generate(base.merge("kind" => "update", "restore" => { "seconds" => 20.0, "ok" => true },
        "install" => { "seconds" => 30.0, "ok" => true }, "save" => { "seconds" => 5.0, "network_bytes" => 50_000_000, "ok" => true })))
      File.write(File.join(dir, "verify.json"), JSON.generate(base.merge("kind" => "verify", "restore" => { "seconds" => 21.0, "network_bytes" => 900_000_000, "ok" => true },
        "cache" => { "bytes" => 2_000_000_000, "files" => 250_000 })))
      File.write(File.join(dir, "seed.json"), JSON.generate(base.merge("kind" => "seed", "save" => { "seconds" => 99.0, "ok" => true })))
      markdown = DepsReport.new(dir).markdown
      assert_includes markdown, "## posthog-pnpm"
      assert_includes markdown, "| boringcache | boringcache | github 4c | - | - | - | - | - | 1.42.0 | 1 | 0 | 20.0 | 30.0 | 5.0 | 50 | 21.0 | 900 | 2000 | 250000 |"
      refute_includes markdown, "99.0"
    end
  end

  def test_cross_runner_verification_uses_the_github_cache_only_where_the_backend_is_shared
    jobs = @deps.jobs("verify").select { it["producer"] != it["runner"] }
    assert_equal %w[blacksmith-4 depot-4 namespace-4], jobs.select { it["lane"] == "boringcache" }.map { it["runner"] }.uniq.sort
    assert_equal ["namespace-4"], jobs.select { it["lane"] == "actions-cache" }.map { it["runner"] }.uniq
    assert jobs.all? { it["key"].end_with?("-github") }
    assert_equal ["blacksmith"], @deps.jobs("seed").select { it["runner"] == "blacksmith-4" && it["lane"] == "actions-cache" }.map { it["cache_backend"] }.uniq
  end

  def test_failed_or_missing_stages_do_not_contribute_timings
    Dir.mktmpdir("deps-report") do |dir|
      base = { "run_id" => "1", "case" => "app", "lane" => "boringcache", "runner" => "github", "machine" => "github 4c", "exit_status" => 0, "output_ok" => true }
      %w[seed update verify].each do |kind|
        File.write(File.join(dir, "#{kind}.json"), JSON.generate(base.merge("kind" => kind, "exit_status" => kind == "seed" ? 1 : 0,
          "restore" => { "seconds" => 2, "ok" => true }, "save" => { "seconds" => 3, "ok" => true })))
      end
      row = DepsReport.new(dir).rows.fetch(0)
      assert_equal [1, 1, nil, nil], row.values_at("samples", "failed", "restore_after", "save")
      File.delete(File.join(dir, "verify.json"))
      assert_equal [1, 1], DepsReport.new(dir).rows.fetch(0).values_at("samples", "failed")
    end
  end

  def test_install_command_does_not_override_autoconf_install
    require "yaml"
    action = YAML.load_file(File.join(Throughput::ROOT, ".github/actions/deps/action.yml"))
    step = action.fetch("runs").fetch("steps").find { it["id"] == "install" }
    env = step.fetch("env").transform_values { 'test -z "${INSTALL+x}"' }
    env["INSTALL"] = nil unless env.key?("INSTALL")
    assert system(env, "bash", "-ec", step.fetch("run"))
  end

  private
    def with_job(kind, name)
      job = @deps.jobs(kind).find { it["case"] == name && it["runner"] == "github" && it["lane"] == "boringcache" }
      Dir.mktmpdir("deps") do |dir|
        Dir.chdir(dir) do
          runner = DepsJob.new(job, dir:, env: {})
          FileUtils.mkdir_p(runner.upstream)
          yield runner, dir
        end
      end
    end
end
