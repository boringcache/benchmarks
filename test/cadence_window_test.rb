# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "open3"
require_relative "../scripts/cadence-window"
require_relative "../scripts/cadence-dispatch"

class CadenceWindowTest < Minitest::Test
  def test_deadline_excludes_the_boundary_and_accepts_explicit_timezones
    deadline = "2026-10-07T20:00:00Z"
    assert CadenceWindow.open?(deadline, now: Time.iso8601("2026-10-07T19:59:59Z"))
    refute CadenceWindow.open?(deadline, now: Time.iso8601(deadline))
    refute CadenceWindow.open?(deadline, now: Time.iso8601("2026-10-07T20:00:01Z"))
    refute CadenceWindow.open?("2026-10-07T21:00:00+01:00", now: Time.iso8601(deadline))
    assert CadenceWindow.open?("", now: Time.iso8601(deadline))
  end

  def test_invalid_deadlines_fail_closed
    ["tomorrow", "2026-10-07", "2026-10-07T20:00:00", "2026-02-30T20:00:00Z"].each do |deadline|
      assert_raises(CadenceWindow::Error) { CadenceWindow.open?(deadline) }
    end
  end

  def test_a_queued_fresh_request_cannot_dispatch_after_the_deadline
    plan = {"state" => "planned", "cli_version" => "v1.40.0", "channel" => "stable", "ref" => "main",
      "runs" => [{"repository" => "boringcache/benchmarks", "workflow" => "native-fresh-benchmark.yml", "inputs" => {"case_id" => "posthog"}, "state" => "planned"}]}
    Dir.mktmpdir do |directory|
      runner = NightlyCanaries::Runner.new
      runner.stub(:api, ->(*) { flunk "The expired window must not call GitHub" }) do
        CadenceWindow.stub(:open?, false) do
          receipt = CadenceDispatch.dispatch(plan, index: 0, output: File.join(directory, "receipt.json"), runner: runner)
          assert_equal "window-closed", receipt.fetch("state")
          assert_equal "window-closed", CadenceDispatch.combine(plan, [receipt]).fetch("state")
          refute receipt.fetch("runs").first.key?("id")
        end
      end
    end
  end

  def test_expired_source_publication_returns_a_receipt_without_requiring_a_proposal_or_credentials
    Dir.mktmpdir do |directory|
      output = File.join(directory, "receipt.json")
      text, status = Open3.capture2e({"BENCHMARK_CADENCE_UNTIL" => "2020-01-01T00:00:00Z", "GH_TOKEN" => nil},
        RbConfig.ruby, File.expand_path("../scripts/source-promotion.rb", __dir__), "--case", "posthog", "--publish", "--output", output)
      assert status.success?, text
      assert_equal "window-closed", JSON.parse(File.read(output)).fetch("state")
    end
  end
end
