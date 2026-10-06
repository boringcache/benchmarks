# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/reapi-client"
require_relative "../scripts/benchmark-candidate"
require_relative "../scripts/compiler-cache-setup"

class NativeAdapterCandidateTest < Minitest::Test
  def test_managed_warm_preserves_command_and_requires_read_only
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        command = ["moon", "run", "web:build"]
        File.write("reapi-recipe.json", JSON.generate({"tool" => "moon", "command" => command}))
        args = ReapiClient.managed_command("warm", "isolated-cohort")
        assert_equal ["boringcache", "moon", "--fail-on-cache-error", "--read-only"], args
        plan = TomlRB.load_file(".boringcache.toml")
        assert_equal command, plan.dig("adapters", "moon", "command")
        assert_equal "isolated-cohort", plan.dig("adapters", "moon", "tag")
        refute_includes ReapiClient.managed_command("cold", "isolated-cohort"), "--read-only"
      end
    end
  end

  def test_candidate_and_compiler_selection_fail_closed
    assert_raises(RuntimeError) { BenchmarkCandidate.install("latest") }
    assert_raises(KeyError) { CompilerCacheSetup.install("unknown") }
  end
end
