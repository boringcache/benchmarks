require_relative "test_helper"

class CLITest < Minitest::Test
  include BenchFixture

  def test_case_setup_applies_to_every_lane_without_duplicates
    path = "tools/demo/app/case.toml"
    write path, "setup = [\"ghcr\"]\n" + File.read(File.join(@root, path))
    path = "tools/demo/lanes/remote.toml"
    write path, "setup = [\"buildx\", \"ghcr\"]\n" + File.read(File.join(@root, path))
    setups = matrix("app").to_h { [it.fetch("lane"), it.fetch("setup")] }
    assert_equal "ghcr", setups.fetch("boringcache-demo")
    assert_equal "ghcr", setups.fetch("gha")
    assert_equal "ghcr buildx", setups.fetch("remote")
  end

  def test_matrix_lists_every_lane_and_runner_of_a_project_without_local
    assert_equal [
      { "case" => "demo/app", "lane" => "boringcache-demo", "runner" => "github", "runs_on" => "ubuntu-24.04", "secrets" => [], "setup" => "", "label" => "github 4c · boringcache", "step" => "", "sha" => "", "cache_scope" => "", "continues" => "", "cadence" => "", "cli" => "" },
      { "case" => "demo/app", "lane" => "remote", "runner" => "github", "runs_on" => "ubuntu-24.04", "secrets" => ["REMOTE_TOKEN"], "setup" => "", "label" => "github 4c · remote", "step" => "", "sha" => "", "cache_scope" => "", "continues" => "", "cadence" => "", "cli" => "" },
      { "case" => "demo/app", "lane" => "gha", "runner" => "github", "runs_on" => "ubuntu-24.04", "secrets" => [], "setup" => "", "label" => "github 4c · gha", "step" => "", "sha" => "", "cache_scope" => "", "continues" => "", "cadence" => "", "cli" => "" }
    ], matrix("app")
  end

  def test_report_excludes_experimental_lanes_even_before_the_record_flag_was_added
    path = "tools/demo/lanes/boringcache-demo.toml"
    write path, File.read(File.join(@root, path)) + "experimental = true\n"
    %w[boringcache-demo remote].each do |lane|
      write "tmp/results/demo/app/#{lane}.json", JSON.generate("adapter_command" => "demo", "case" => "app", "lane" => lane, "runner" => "github", "phase" => "cold", "seconds" => 1, "exit_status" => 0, "output_ok" => true)
    end

    assert_equal 0, Bench::CLI.new(%W[report --results #{@root}/tmp/results --out #{@root}/report], catalog:, out: StringIO.new).call
    rows = JSON.parse(File.read(File.join(@root, "report/results.json"))).fetch("rows")
    assert_equal ["remote"], rows.map { it["lane"] }
  end

  def test_report_keeps_samples_without_requiring_their_retired_rolling_lanes
    path = "tools/demo/app/case.toml"
    write path, File.read(File.join(@root, path)) + %([samples]\nremote = ["github"]\n)
    %w[boringcache-demo gha remote].each do |lane|
      2.times do |step|
        record = { "adapter_command" => "demo", "case" => "app", "lane" => lane, "runner" => "github", "phase" => "rolling",
          "step" => step, "sha" => "commit-#{step}", "cache_scope" => "#{lane}-github-rolling", "scope" => "#{lane}-github-rolling", "seconds" => 10,
          "exit_status" => 0, "output_ok" => true, "versions" => { "boringcache" => "1.40.0" } }
        write "tmp/results/demo/app/#{lane}-#{step}.json", JSON.generate(record)
        write "tmp/results/demo/app/sample.json", JSON.generate(record.merge("phase" => "sample")) if lane == "remote" && step == 1
      end
    end

    assert_equal 0, Bench::CLI.new(%W[report --results #{@root}/tmp/results --out #{@root}/report], catalog:, out: StringIO.new).call
    report = JSON.parse(File.read(File.join(@root, "report/results.json")))
    assert_equal %w[boringcache-demo gha], report.fetch("matched").map { it["lane"] }.sort
    assert_equal ["remote"], report.fetch("samples").map { it["lane"] }
    refute report.fetch("latest").any? { it["lane"] == "remote" }
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

  def test_rolling_requires_the_canonical_tool_title_used_by_the_workflow_concurrency_group
    write "tools/demo/tool.toml", %(name = "Demo/Build"\n[levels]\nbase = ["remote-cache"]\n)
    out = StringIO.new

    _, err = capture_io { assert_equal 1, Bench::CLI.new(%w[matrix app --tool demo --rolling], catalog:, out:).call }
    assert_empty out.string
    assert_includes err, 'rolling requires the tool title "Demo/Build"'
    assert_equal 3, matrix("app", "--tool", "demo/build", "--rolling").size
    assert_equal 3, matrix("app", "--tool", "demo").size
  end

  def test_rolling_matrix_keeps_one_fixed_cache_scope_per_lane_apart_from_fresh_runs
    write "tmp/results/demo/app/remote-github-r1/remote-github-cold.json", JSON.generate("scope" => "remote-github-r1", "sha" => @upstream_sha, "exit_status" => 0, "output_ok" => true)

    scopes = matrix("app", "--rolling").to_h { [it["lane"], it["cache_scope"]] }
    assert_equal({ "boringcache-demo" => "boringcache-demo-github-rolling", "remote" => "remote-github-rolling", "gha" => "gha-github-rolling" }, scopes)
  end

  def test_a_reader_rolls_on_the_cache_of_the_lane_it_reads_and_stays_out_of_fresh_runs_and_reruns
    write "tools/demo/lanes/boringcache-reader.toml", %(provider = "boringcache"\nlevel = "base"\nlabel = "boringcache read-only"\nreads = { lane = "boringcache-demo", runner = "github" }\n)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]\n", "[runs]\nboringcache-reader = [\"github\"]\n")

    assert_equal %w[boringcache-demo remote gha], matrix("app").map { it["lane"] }
    reader = matrix("app", "--rolling").find { it["lane"] == "boringcache-reader" }
    assert_equal ["github 4c · boringcache read-only", "boringcache-demo-github-rolling"], reader.values_at("label", "cache_scope")

    rolling_record("boringcache-demo", 0, @upstream_sha)
    assert_equal %w[boringcache-demo remote gha], matrix("app", "--rolling", "--step", "0").map { it["lane"] }
  end

  def test_a_nightly_reader_rolls_once_a_day_on_the_cache_of_the_lane_it_reads
    write "tools/demo/lanes/boringcache-reader.toml", %(provider = "boringcache"\nlevel = "base"\nreads = { lane = "boringcache-demo", runner = "github" }\n)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]\n", "[runs]\nboringcache-reader = [\"github\"]\n") + %([nightly]\nboringcache-reader = ["github"]\n)
    commit_upstream("two")
    reader = -> { matrix("app", "--rolling").select { it["lane"] == "boringcache-reader" }.map { it.values_at("cadence", "cache_scope") } }

    assert_equal [["nightly", "boringcache-demo-github-rolling"]], reader.call
    write "tmp/results/demo/app/boringcache-reader-github-rolling/boringcache-reader-github-rolling-0.json", JSON.generate("step" => 0, "sha" => @upstream_sha, "started_at" => Time.now.utc.iso8601)
    assert_empty reader.call
  end

  def test_samples_use_the_latest_completed_seed_without_new_upstream_commits
    write "tools/demo/lanes/boringcache-reader.toml", %(provider = "boringcache"\nlevel = "base"\nrunners = ["github", "other"]\nreads = { lane = "boringcache-demo", runner = "github" }\n)
    write "runners.toml", File.read(File.join(@root, "runners.toml")) + %([other]\nlabel = "other-8"\nmachine = "other 8c"\n)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]\n", "[runs]\nboringcache-reader = [\"github\"]\n") + %([samples]\nboringcache-reader = ["github"]\nremote = ["github"]\n)
    write "tmp/results/demo/app/boringcache-demo-github-rolling/seed.json", JSON.generate("step" => 0, "sha" => @upstream_sha,
      "exit_status" => 0, "output_ok" => true, "cache_scope" => "boringcache-demo-github-rolling", "run_url" => "https://example.test/runs/1")

    jobs = matrix("app", "--tool", "demo", "--sample")
    assert_equal %w[boringcache-reader remote], jobs.map { it["lane"] }
    assert_equal [@upstream_sha], jobs.map { it["sha"] }.uniq
    assert_equal %w[boringcache-demo-github-rolling remote-github-sample], jobs.map { it["cache_scope"] }
    assert_equal ["boringcache-demo", "gha"], matrix("app").map { it["lane"] }
    assert_equal ["other"], matrix("app", "--tool", "demo", "--sample", "--lane", "boringcache-reader", "--runner", "other").map { it["runner"] }
    assert_equal "https://example.test/runs/1", JSON.parse(jobs.first["source"])["run_url"]

    newer = commit_upstream("two")
    changed = matrix("app", "--tool", "demo", "--sample", "--sha", newer)
    assert_equal [newer], changed.map { it["sha"] }.uniq
    assert_equal [@upstream_sha], changed.map { JSON.parse(it["source"]).fetch("sha") }.uniq
    assert_equal jobs.map { it["cache_scope"] }, changed.map { it["cache_scope"] }

    [@upstream_sha, "b" * 40, "main"].each do |sha|
      _, error = capture_io do
        assert_equal 1, Bench::CLI.new(%W[matrix app --tool demo --sample --sha #{sha} --results #{@root}/tmp/results], catalog:, out: StringIO.new).call
      end
      assert_includes error, "sample --sha must be a newer first-parent commit"
    end

    _, error = capture_io do
      assert_equal 1, Bench::CLI.new(%W[matrix app --rolling --sha #{newer}], catalog:, out: StringIO.new).call
    end
    assert_includes error, "matrix --sha requires --sample"

    write "tmp/results/demo/app/boringcache-demo-github-rolling/failed.json", JSON.generate("step" => 1, "sha" => "b" * 40, "exit_status" => 1, "output_ok" => false)
    _, error = capture_io do
      assert_equal 1, Bench::CLI.new(%W[matrix app --tool demo --sample --results #{@root}/tmp/results], catalog:, out: StringIO.new).call
    end
    assert_includes error, "latest boringcache-demo build has no successful cache seed"
  end

  def test_rolling_matrix_marks_lanes_that_continue_their_own_rolling_cache
    commit_upstream("two")
    rolling_record("remote", 0, @upstream_sha)
    write "tmp/results/demo/app/gha-github-rolling/gha-github-rolling-0.json", JSON.generate("step" => 0, "sha" => @upstream_sha, "cache_scope" => "gha-github-r1")

    continues = matrix("app", "--rolling").to_h { [it["lane"], it["continues"]] }
    assert_equal({ "boringcache-demo" => "", "remote" => "true", "gha" => "" }, continues)
  end

  def test_a_rolling_series_restarts_at_the_start_commit_on_its_own_scope
    commit_upstream("two")
    %w[boringcache-demo remote gha].each { rolling_record(it, 0, @upstream_sha) }
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]", "rolling_series = 2\n\n[runs]")

    entries = matrix("app", "--rolling").map { it.values_at("lane", "step", "sha", "cache_scope", "continues") }
    assert_equal [["boringcache-demo", "0", @upstream_sha, "boringcache-demo-github-rolling-2", ""], ["remote", "0", @upstream_sha, "remote-github-rolling-2", ""],
                  ["gha", "0", @upstream_sha, "gha-github-rolling-2", ""]], entries
  end

  def test_a_rolling_stride_moves_every_lane_that_many_commits_per_step
    commit_upstream("two")
    %w[boringcache-demo remote gha].each { rolling_record(it, 0, @upstream_sha) }
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]", "rolling_stride = 2\n\n[runs]")
    assert_empty matrix("app", "--rolling")

    third = commit_upstream("three")
    assert_equal [["1", third]], matrix("app", "--rolling").map { it.values_at("step", "sha") }.uniq
  end

  def test_rolling_matrix_reruns_a_recorded_step_only_for_lanes_without_a_passing_record
    second = commit_upstream("two")
    commit_upstream("three")
    %w[boringcache-demo remote gha].each { rolling_record(it, 0, @upstream_sha) }
    write "tmp/results/demo/app/boringcache-demo-github-rolling/boringcache-demo-github-rolling-1.json", JSON.generate("step" => 1, "sha" => second, "exit_status" => 0, "output_ok" => true)
    write "tmp/results/demo/app/remote-github-rolling/remote-github-rolling-1.json", JSON.generate("step" => 1, "sha" => second, "exit_status" => 1, "output_ok" => false)

    assert_equal [["remote", "1", second], ["gha", "1", second]], matrix("app", "--rolling", "--step", "1").map { it.values_at("lane", "step", "sha") }
    write "tmp/results/demo/app/gha-github-rolling/gha-github-rolling-1.json", JSON.generate("step" => 1, "sha" => second, "exit_status" => 0, "output_ok" => true, "job_conclusion" => "failure")
    assert_equal %w[remote gha], matrix("app", "--rolling", "--step", "1").map { it["lane"] }
    rolling_record("remote", 2, "b" * 40)
    assert_equal ["gha"], matrix("app", "--rolling", "--step", "1").map { it["lane"] }
    [%w[app --step 1], %w[app --rolling --step 5]].each do |argv|
      _, err = capture_io { assert_equal 1, Bench::CLI.new(["matrix", *argv], catalog:, out: StringIO.new).call }
      assert_match(/step/, err)
    end
  end

  def test_nightly_lanes_join_the_first_rolling_step_of_each_utc_day
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")) + %([nightly]\nremote = ["github"]\n)
    commit_upstream("two")
    %w[boringcache-demo gha].each { rolling_record(it, 0, @upstream_sha) }
    write "tmp/results/demo/app/remote-github-rolling/remote-github-rolling-0.json", JSON.generate("step" => 0, "sha" => @upstream_sha, "cache_scope" => "remote-github-rolling", "started_at" => "2026-10-14T00:05:00Z")

    assert_equal [["boringcache-demo", ""], ["gha", ""]], matrix("app", "--rolling", now: Time.utc(2026, 10, 14, 23)).map { it.values_at("lane", "cadence") }
    assert_equal [["boringcache-demo", ""], ["remote", "nightly"], ["gha", ""]], matrix("app", "--rolling", now: Time.utc(2026, 10, 15, 0, 10)).map { it.values_at("lane", "cadence") }
    assert_equal %w[boringcache-demo remote gha], matrix("app", now: Time.utc(2026, 10, 14, 23)).map { it["lane"] }
  end

  def test_a_versions_case_pin_applies_to_rolling_and_fresh_runs_unless_a_fresh_run_names_another
    write "versions.toml", %(boringcache = "1.40.0"\n[cases]\n"demo/app" = "vcli-canary-abc123def"\n)

    assert_equal ["vcli-canary-abc123def"], matrix("app", "--rolling").map { it["cli"] }.uniq
    assert_equal ["vcli-canary-abc123def"], matrix("app").map { it["cli"] }.uniq
    assert_equal ["v1.41.0"], matrix("app", "--cli", "v1.41.0").map { it["cli"] }.uniq
  end

  def test_a_rerun_includes_a_nightly_lane_only_at_steps_it_ran
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")) + %([nightly]\nremote = ["github"]\n)
    second = commit_upstream("two")
    commit_upstream("three")
    %w[boringcache-demo remote gha].each { rolling_record(it, 0, @upstream_sha) }
    %w[boringcache-demo gha].each do |lane|
      write "tmp/results/demo/app/#{lane}-github-rolling/#{lane}-github-rolling-1.json", JSON.generate("step" => 1, "sha" => second, "exit_status" => 1, "output_ok" => false)
    end

    assert_equal %w[boringcache-demo gha], matrix("app", "--rolling", "--step", "1").map { it["lane"] }
    write "tmp/results/demo/app/remote-github-rolling/remote-github-rolling-1.json", JSON.generate("step" => 1, "sha" => second, "exit_status" => 1, "output_ok" => false)
    assert_equal [["boringcache-demo", ""], ["remote", "nightly"], ["gha", ""]], matrix("app", "--rolling", "--step", "1").map { it.values_at("lane", "cadence") }
  end

  def test_post_job_saves_adds_only_the_lanes_post_job_cache_saves
    write "tools/demo/lanes/gha.toml", %(provider = "github-actions-cache"\nlevel = "base"\nactions_only = true\nrunners = ["github"]\npost_job_save = ["acme/save-action", "dance-cache"]\n)
    write "job.log", <<~LOG
      2026-10-09T10:00:00Z ##[end-action id=__self.__acme_save-action;outcome=success;conclusion=success;duration_ms=9000]
      2026-10-09T10:10:00Z Post job cleanup.
      2026-10-09T10:10:12Z ##[end-action id=__1a2b.__acme_save-action;outcome=success;conclusion=success;duration_ms=12500]
      2026-10-09T10:10:13Z ##[end-action id=__1a2b.dance-cache;outcome=success;conclusion=success;duration_ms=500]
      2026-10-09T10:11:21Z ##[end-action id=__1a2b.__docker_setup-buildx-action;outcome=success;conclusion=success;duration_ms=68000]
    LOG
    write "bin/gh", <<~BASH
      #!/usr/bin/env bash
      echo "gh $*" >> "$STUB_LOG"
      case "$*" in
        *runs/42/jobs*)
          echo '{"id":7,"name":"rolling: github 4c · gha","run_attempt":1,"conclusion":"failure"}'
          echo '{"id":8,"name":"rolling: github 4c · gha","run_attempt":2,"conclusion":"success"}' ;;
        *jobs/7/logs*) cat "#{File.join(@root, "job.log")}" ;;
      esac
    BASH
    File.chmod(0o755, File.join(@root, "bin/gh"))
    %w[gha remote].each do |lane|
      write "tmp/results/demo/app/#{lane}-github-rolling/#{lane}-github-rolling-3.json", JSON.generate("adapter_command" => "demo", "case" => "app", "lane" => lane, "runner" => "github", "phase" => "rolling",
                                                                                                   "run_url" => "https://github.com/boringcache/benchmarks/actions/runs/42")
    end

    with_fixture_env do
      ENV["GITHUB_REPOSITORY"] = "boringcache/benchmarks"
      Bench::CLI.new(%W[post-job-saves --run-id 42 --results #{@root}/tmp/results], catalog:, out: StringIO.new).call
    ensure
      ENV.delete("GITHUB_REPOSITORY")
    end

    saved = %w[gha remote].to_h { [it, JSON.parse(File.read(File.join(@root, "tmp/results/demo/app/#{it}-github-rolling/#{it}-github-rolling-3.json")))["post_job_save_seconds"]] }
    assert_equal({ "gha" => 13.0, "remote" => nil }, saved)
    assert_equal 2, File.readlines(File.join(@root, "stub.log")).size
    path = File.join(@root, "tmp/results/demo/app/gha-github-rolling/gha-github-rolling-3.json")
    record = JSON.parse(File.read(path))
    assert_equal "failure", record.delete("job_conclusion")
    File.write(path, JSON.generate(record))

    with_fixture_env do
      ENV["GITHUB_REPOSITORY"] = "boringcache/benchmarks"
      Bench::CLI.new(%W[post-job-saves --run-id 42 --results #{@root}/tmp/results], catalog:, out: StringIO.new).call
    ensure
      ENV.delete("GITHUB_REPOSITORY")
    end

    assert_equal "failure", JSON.parse(File.read(path))["job_conclusion"]
    assert_equal 3, File.readlines(File.join(@root, "stub.log")).size

    record.delete("post_job_save_seconds")
    File.write(path, JSON.generate(record))
    write "job.log", "Post job cleanup.\n"
    with_fixture_env do
      ENV["GITHUB_REPOSITORY"] = "boringcache/benchmarks"
      Bench::CLI.new(%W[post-job-saves --run-id 42 --results #{@root}/tmp/results], catalog:, out: StringIO.new).call
    ensure
      ENV.delete("GITHUB_REPOSITORY")
    end
    refute JSON.parse(File.read(path)).key?("post_job_save_seconds")
  end

  def test_restored_keys_recovers_only_cache_dance_restores_the_job_log_proves
    write "tools/demo/lanes/gha.toml", %(provider = "github-actions-cache"\nlevel = "base"\nactions_only = true\nrunners = ["github"]\nsetup = ["cache-dance"]\npost_job_save = ["dance-cache"]\n)
    write "restored.log", <<~LOG
      2026-10-09T10:00:00Z Cache restored from key: demo-app-gha-github-rolling-2
      2026-10-09T10:10:00Z Post job cleanup.
    LOG
    write "missed.log", <<~LOG
      2026-10-09T10:00:00Z Cache not found for input keys: demo-app-gha-github-rolling-4, demo-app-gha-github-rolling-
      2026-10-09T10:10:00Z Post job cleanup.
      2026-10-09T10:10:13Z Cache restored from key: demo-app-gha-github-rolling-3
    LOG
    write "bin/gh", <<~BASH
      #!/usr/bin/env bash
      echo "gh $*" >> "$STUB_LOG"
      case "$*" in
        *runs/42/jobs*) echo '{"id":7,"name":"rolling: github 4c · gha","run_attempt":1,"conclusion":"success"}' ;;
        *runs/43/jobs*) echo '{"id":8,"name":"rolling: github 4c · gha","run_attempt":1,"conclusion":"success"}' ;;
        *jobs/7/logs*) cat "#{File.join(@root, "restored.log")}" ;;
        *jobs/8/logs*) cat "#{File.join(@root, "missed.log")}" ;;
      esac
    BASH
    File.chmod(0o755, File.join(@root, "bin/gh"))
    paths = { 3 => 42, 4 => 43 }.to_h do |step, run|
      path = "tmp/results/demo/app/gha-github-rolling/gha-github-rolling-#{step}.json"
      write path, JSON.generate("adapter_command" => "demo", "case" => "app", "lane" => "gha", "runner" => "github", "phase" => "rolling", "step" => step, "cache_scope" => "gha-github-rolling",
                                "cache_restored_key" => nil, "cache_restore_tracked" => true, "run_url" => "https://github.com/boringcache/benchmarks/actions/runs/#{run}")
      [step, File.join(@root, path)]
    end

    with_fixture_env do
      ENV["GITHUB_REPOSITORY"] = "boringcache/benchmarks"
      assert_equal 0, Bench::CLI.new(%W[restored-keys --results #{@root}/tmp/results], catalog:, out: StringIO.new).call
    ensure
      ENV.delete("GITHUB_REPOSITORY")
    end

    assert_equal({ 3 => "demo-app-gha-github-rolling-2", 4 => nil }, paths.transform_values { JSON.parse(File.read(it))["cache_restored_key"] })
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
      write "tmp/results/demo/app/#{lane}-github-rolling/#{lane}-github-rolling-#{step}.json", JSON.generate("step" => step, "sha" => sha, "cache_scope" => "#{lane}-github-rolling")
    end

    def matrix(*argv, now: Time.now.utc)
      out = StringIO.new
      Bench::CLI.new(["matrix", *argv], catalog:, out:, now:).call
      JSON.parse(out.string)
    end

    def assert_matrix_refused(*argv)
      out = StringIO.new
      _, err = capture_io { assert_equal 1, Bench::CLI.new(["matrix", *argv], catalog:, out:).call }
      assert_empty out.string
      assert_match(/--cli/, err)
    end
end
