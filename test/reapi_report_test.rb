# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "json"
require "open3"
require "rbconfig"

class ReapiReportTest < Minitest::Test
  def test_phase_name_does_not_establish_a_cache_hit_or_miss
    assert_nil reported_cache_hit("cold", "0 remote cache hits")
    assert_nil reported_cache_hit("warm", "0 remote cache hits")
    assert_equal true, reported_cache_hit("cold", "2 remote cache hits")
    assert_equal true, reported_cache_hit("warm", "81 remote cache hits")
    assert_nil reported_cache_hit("commit", "0 remote cache hits")
    assert_equal true, reported_cache_hit("commit", "2 remote cache hits")
  end

  private

  def reported_cache_hit(phase, log)
    previous = ENV.to_h
    ENV.update("PHASE" => phase, "PROVIDER" => "bazel-remote", "BENCHMARK_ID" => "msgpack-sbt",
      "CACHE_LANE" => phase == "commit" ? "rolling" : "fresh", "BENCHMARK_SAMPLE" => "1",
      "GITHUB_RUN_ID" => "1", "GITHUB_RUN_ATTEMPT" => "1", "GITHUB_REF_NAME" => "main")
    ENV.delete("BENCHMARK_SERIES_ID")
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        FileUtils.mkdir_p("reapi-evidence")
        File.write("benchmark-context.json", JSON.generate("source" => {"repository" => "msgpack/msgpack-java", "revision" => "a" * 40}))
        File.write("reapi-recipe.json", JSON.generate("warm_hit_pattern" => "\\b[1-9][0-9]* remote cache hits\\b"))
        File.write("reapi-evidence/build.log", log)
        File.write("reapi-evidence/timing.json", JSON.generate("build_seconds" => 2, "restore_or_setup_seconds" => 1, "save_seconds" => 1))
        source = File.expand_path("../scripts", __dir__)
        %w[reapi-setup reapi-client reapi-registry benchmark-phase benchmark-plan].each do |name|
          FileUtils.cp(File.join(source, "#{name}.rb"), "#{name}.rb")
        end
        FileUtils.cp(File.join(source, "canonical/benchmark-report.rb"), "benchmark-report.rb")
        output, status = Open3.capture2e(RbConfig.ruby, "reapi-setup.rb", "report")
        assert status.success?, output
        record = JSON.parse(File.read(Dir["benchmark-results/*.json"].fetch(0)))
        record.dig("cache", "hit")
      end
    end
  ensure
    ENV.replace(previous)
  end
end
