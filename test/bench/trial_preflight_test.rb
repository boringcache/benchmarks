require_relative "test_helper"
require "yaml"

class TrialPreflightTest < Minitest::Test
  def test_bazel_checks_available_space_and_preserves_the_build_reserve
    Dir.mktmpdir do |dir|
      df = File.join(dir, "df")
      File.write(df, <<~SH)
        #!/bin/bash
        printf 'Available\n %s\n' "$FREE_BYTES"
      SH
      File.chmod(0o755, df)
      github_env = File.join(dir, "github.env")
      env = { "BENCH_DIR" => dir, "GITHUB_ENV" => github_env, "PATH" => "#{dir}:#{ENV.fetch("PATH")}" }

      [[140, 8], [124, 4], [120, nil]].each do |free_gib, budget_gib|
        env["FREE_BYTES"] = (free_gib * 1024**3).to_s
        _, status = Open3.capture2e(env, "bash", File.join(Bench::ROOT, "tools/bazel/codex/storage.sh"), "read-cache")
        assert_equal !budget_gib.nil?, status.success?
        if budget_gib
          assert_includes File.read(github_env), "BORINGCACHE_BLOB_READ_CACHE_MAX_BYTES=#{budget_gib * 1024**3}"
          File.delete(github_env)
        else
          refute File.exist?(github_env)
        end
      end
    end
  end

  def test_availability_records_an_unassigned_runner_at_the_queue_deadline
    workflow = YAML.load_file(File.join(Bench::ROOT, ".github/workflows/incredibuild-availability.yml"))
    steps = workflow.dig("jobs", "deadline", "steps")
    watch = steps.first.fetch("run")
    stubs = <<~'BASH'
      timeout() { shift 2; "$@"; }
      gh() { printf '%s\n' "$JOB"; }
      date() {
        if [[ "$1" == '+%s' ]]; then echo 1000; else echo 100; fi
      }
    BASH
    Dir.mktmpdir do |dir|
      output = File.join(dir, "output")
      env = { "PLATFORM" => "macos", "GITHUB_OUTPUT" => output, "GITHUB_STEP_SUMMARY" => File.join(dir, "summary"),
              "RUNNER_TEMP" => dir, "JOB" => JSON.generate("status" => "queued", "runner_id" => 0, "created_at" => "2026-11-25T00:00:00Z") }
      _, status = Open3.capture2e(env, "bash", "-e", "-o", "pipefail", "-c", stubs + watch)
      assert status.success?
      assert_equal ["cancel=true", "outcome=queue_timeout"], File.readlines(output, chomp: true)
      record = JSON.parse(File.read(File.join(dir, "availability.json")))
      assert_equal ["macos", "queue_timeout", 900], record.values_at("platform", "outcome", "queue_deadline_seconds")
      assert_includes steps[1]["uses"], "actions/upload-artifact@"
      assert_includes steps[2]["run"], "/cancel"
    end
  end

  def test_swap_preflight_cleans_up_after_a_runner_refuses_activation
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "sudo"), <<~'SH')
        #!/bin/bash
        if [[ "$1" == swapon ]]; then exit 1; fi
        if [[ "$1" == rm ]]; then exec "$@"; fi
      SH
      File.write(File.join(dir, "swapon"), "#!/bin/bash\nexit 0\n")
      %w[sudo swapon].each { File.chmod(0o755, File.join(dir, it)) }
      env = { "RUNNER_TEMP" => dir, "PATH" => "#{dir}:#{ENV.fetch("PATH")}" }
      output, status = Open3.capture2e(env, "bash", File.join(Bench::ROOT, "tools/docker/posthog/overlay/swap.sh"), "preflight")

      refute status.success?
      assert_includes output, "could not activate a swap file"
      assert_empty Dir.glob(File.join(dir, "posthog-swap-check.*"))
    end
  end
end
