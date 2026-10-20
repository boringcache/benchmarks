require_relative "test_helper"

class RegistryDispatchTest < Minitest::Test
  def test_dispatches_an_active_workflow_with_source_artifacts
    output, status, calls = dispatch(source: "true", state: "active")

    assert status.success?, output
    assert_includes calls, "workflow run registry.yml --ref main -f provider=all -f source_run=123"
  end

  def test_skips_a_disabled_workflow
    output, status, calls = dispatch(source: "true", state: "disabled_manually")

    assert status.success?, output
    assert_includes output, "Registry transfers skipped: registry.yml is disabled_manually."
    refute_includes calls, "workflow run"
  end

  def test_does_not_query_the_workflow_without_source_artifacts
    output, status, calls = dispatch(source: "false", state: "active")

    assert status.success?, output
    refute_includes calls, "actions/workflows"
    refute_includes calls, "workflow run"
  end

  def test_keeps_api_failures_fatal
    output, status, calls = dispatch(source: "true", state: "active", api_status: "1")

    refute status.success?, output
    refute_includes calls, "workflow run"
  end

  private
    def dispatch(source:, state:, api_status: "0")
      Dir.mktmpdir do |dir|
        gh = File.join(dir, "gh")
        calls = File.join(dir, "calls")
        File.write(gh, <<~SH)
          #!/usr/bin/env bash
          echo "$*" >> "$CALLS"
          case "$2" in
            */artifacts) echo "$SOURCE" ;;
            */registry.yml) echo "$STATE"; exit "$API_STATUS" ;;
          esac
        SH
        File.chmod(0o755, gh)
        output, status = Open3.capture2e(
          { "PATH" => "#{dir}:#{ENV.fetch("PATH")}", "CALLS" => calls,
            "SOURCE" => source, "STATE" => state, "API_STATUS" => api_status,
            "GITHUB_REPOSITORY" => "boringcache/benchmarks", "RUN_ID" => "123" },
          "bash", File.join(Bench::ROOT, "scripts/dispatch-registry.sh")
        )
        [output, status, File.read(calls)]
      end
    end
end
