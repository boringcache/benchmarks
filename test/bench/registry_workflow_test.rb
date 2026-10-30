require_relative "test_helper"
require "yaml"

class RegistryWorkflowTest < Minitest::Test
  def test_both_registry_jobs_allow_oidc_without_static_boringcache_credentials
    workflow = YAML.load_file(File.join(Bench::ROOT, ".github/workflows/registry.yml"), aliases: true)
    %w[push pull].each do |operation|
      job = workflow.fetch("jobs").fetch(operation)
      assert_equal "write", job.dig("permissions", "id-token")
      refute job.fetch("env").keys.any? { it.start_with?("BORINGCACHE_") }
    end

    steps = action_steps
    install = steps.index { it.fetch("run", "").include?("registry-cli") }
    login = steps.index { it.fetch("run", "").include?('case "$PROVIDER"') }
    assert_equal "inputs.provider == 'boringcache'", steps.fetch(install).fetch("if")
    assert_operator install, :<, login
  end

  def test_push_and_pull_run_with_oidc_and_the_docker_credential_helper
    %w[push pull].each do |operation|
      output, status, calls = transfer(operation)

      assert status.success?, output
      assert_equal [
        "docker login",
        "ci run --oidc-provider github-actions -- ruby scripts/registry-benchmark.rb boringcache #{operation}",
        "transfer scripts/registry-benchmark.rb boringcache #{operation}"
      ], calls.lines.map(&:chomp)
    end
  end

  def test_a_failed_oidc_transfer_fails_the_step
    _, status, = transfer("pull", exit_status: "7")
    assert_equal 7, status.exitstatus
  end

  private
    def action_steps
      YAML.load_file(File.join(Bench::ROOT, ".github/actions/registry-transfer/action.yml")).fetch("runs").fetch("steps")
    end

    def transfer(operation, exit_status: "0")
      Dir.mktmpdir("registry-oidc") do |dir|
        calls = File.join(dir, "calls")
        {
          "boringcache" => <<~SH,
            #!/usr/bin/env bash
            set -eu
            echo "$*" >> "$CALLS"
            if [ "$*" = "docker login" ]; then exit 0; fi
            test "$1 $2 $3 $4 $5" = "ci run --oidc-provider github-actions --"
            shift 5
            export REGISTRY_TEST_SESSION=active
            exec "$@"
          SH
          "ruby" => <<~SH,
            #!/usr/bin/env bash
            set -eu
            test "$REGISTRY_TEST_SESSION" = active
            echo "transfer $*" >> "$CALLS"
            exit "$TRANSFER_STATUS"
          SH
          "docker" => "#!/usr/bin/env bash\nexit 99\n"
        }.each do |name, script|
          path = File.join(dir, name)
          File.write(path, script)
          File.chmod(0o755, path)
        end
        steps = action_steps
        login = steps.find { it.fetch("run", "").include?('case "$PROVIDER"') }.fetch("run")
        command = steps.find { it.fetch("env", {}).key?("OPERATION") }.fetch("run")
        output, status = Open3.capture2e(
          { "PATH" => "#{dir}:#{ENV.fetch("PATH")}", "CALLS" => calls,
            "PROVIDER" => "boringcache", "OPERATION" => operation, "TRANSFER_STATUS" => exit_status,
            "REGISTRY_TEST_SESSION" => nil, "BORINGCACHE_REGISTRY_TOKEN" => nil,
            "BORINGCACHE_RESTORE_TOKEN" => nil, "BORINGCACHE_SAVE_TOKEN" => nil },
          "bash", "-e", "-o", "pipefail", "-c", "#{login}\n#{command}"
        )
        [output, status, File.exist?(calls) ? File.read(calls) : ""]
      end
    end
end
