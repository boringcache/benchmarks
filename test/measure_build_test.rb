# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "json"
require "open3"
require "rbconfig"

class MeasureBuildTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/measure-build.rb", __dir__)

  def measure(source)
    Dir.mktmpdir("build-timing-") do |directory|
      path = File.join(directory, "timing.json")
      output, error, status = Open3.capture3(RbConfig.ruby, SCRIPT, "--output", path, "--", RbConfig.ruby, "-e", source)
      yield JSON.parse(File.read(path)), output, error, status
    end
  end

  def test_measures_the_upstream_group_and_keeps_setup_outside_it
    measure(<<~RUBY) do |record, output, _, status|
      $stdout.sync = true
      puts "dependency install"
      sleep 0.12
      puts "::group::Building obs-studio..."
      sleep 0.03
      puts "::group::nested output"
      puts "::endgroup::"
      puts "::endgroup::"
      puts "packaging"
      sleep 0.12
    RUBY
      assert status.success?
      assert record["verified_boundary"]
      assert_operator record["before_build_seconds"], :>=, 0.1
      assert_operator record["build_seconds"], :>=, 0.02
      assert_operator record["entrypoint_seconds"] - record["build_seconds"], :>=, 0.2
      assert_includes output, "dependency install"
      assert_includes output, "packaging"
    end
  end

  def test_missing_or_repeated_groups_cannot_produce_a_valid_measurement
    ["puts 'build succeeded'", "2.times { puts '::group::Building obs-studio...'; puts '::endgroup::' }"].each do |source|
      measure(source) do |record, _, error, status|
        refute status.success?
        refute record["verified_boundary"]
        assert_nil record["build_seconds"]
        assert_includes error, "exactly one complete"
      end
    end
  end

  def test_preserves_the_build_failure_and_marks_an_incomplete_group
    measure("puts '::group::Building obs-studio...'; exit 7") do |record, _, _, status|
      assert_equal 7, status.exitstatus
      assert_equal 7, record["exit_code"]
      refute record["verified_boundary"]
      assert_nil record["build_seconds"]
    end
  end
end
