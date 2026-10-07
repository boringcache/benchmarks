require_relative "test_helper"

class ReportTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir("results")
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def test_groups_records_and_keeps_failures
    record "a.json", seconds: 10.0
    record "b.json", seconds: 30.0
    record "c.json", seconds: 20.0
    record "d.json", seconds: 99.0, exit_status: 1, output_ok: false

    rows = Bench::Report.new(@dir).rows
    assert_equal 1, rows.size
    assert_equal({ "samples" => 4, "failed" => 1, "output_ok" => 3, "median_seconds" => 20.0, "min_seconds" => 10.0, "max_seconds" => 30.0 },
                 rows.first.slice("samples", "failed", "output_ok", "median_seconds", "min_seconds", "max_seconds"))
  end

  def test_missing_values_are_unmeasured_in_markdown
    record "a.json", seconds: 5.0, exit_status: 2, output_ok: false

    assert_includes Bench::Report.new(@dir).markdown, "| docker | posthog | gha | base | github | warm | 1 | 1 | 0 | unmeasured | unmeasured | unmeasured |"
  end

  private
    def record(name, seconds:, exit_status: 0, output_ok: true)
      File.write(File.join(@dir, name), JSON.generate(
        "adapter_command" => "docker", "case" => "posthog", "lane" => "gha", "level" => "base", "runner" => "github",
        "phase" => "warm", "seconds" => seconds, "exit_status" => exit_status, "output_ok" => output_ok
      ))
    end
end
