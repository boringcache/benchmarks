require_relative "test_helper"
require "stringio"

class TickTest < Minitest::Test
  def test_active_sample_run_holds_the_regular_build
    runs = [{ "displayTitle" => "Docker - posthog (sample)", "status" => "in_progress", "databaseId" => 123 }]
    chosen, notes = Bench::Tick.plan([["Docker", "posthog"]], runs, behind: ->(*) { raise "must not advance while sampling" })
    assert_empty chosen
    assert_equal "busy", notes.first.first
  end
  NOW = Time.utc(2026, 10, 12, 16)

  def run_of(id, tool, project, status: "completed", conclusion: "success", created: NOW - 3600)
    { "databaseId" => id, "displayTitle" => Bench::Tick.title(tool, project), "status" => status, "conclusion" => conclusion, "createdAt" => created.iso8601 }
  end

  def test_only_projects_with_new_upstream_commits_are_dispatched
    behind = ->(_, project) { project != "hugo" }

    chosen, notes = Bench::Tick.plan([%w[Go hugo], %w[Bazel grpc]], [], behind:)

    assert_equal [%w[Bazel grpc]], chosen
    assert_equal [["current", "Go - hugo (rolling)", "no upstream commit due"]], notes
  end

  def test_active_projects_wait_until_their_current_run_has_published
    Bench::Tick::ACTIVE.each do |status|
      runs = [run_of(1, "Bazel", "grpc", status:)]
      chosen, notes = Bench::Tick.plan([%w[Bazel grpc]], runs, behind: ->(*) { flunk "must not check an unfinished run's recorded position" })

      assert_empty chosen
      assert_equal [["busy", "Bazel - grpc (rolling)", "run 1 is #{status}"]], notes
    end
  end

  def test_manual_case_variants_and_step_reruns_count_as_active
    run = run_of(1, "bazel", "gRPC", status: "in_progress")
    run["displayTitle"] += " step 4"

    chosen, = Bench::Tick.plan([%w[Bazel grpc]], [run], behind: ->(*) { flunk "must not dispatch beside a rerun" })

    assert_empty chosen
  end

  def test_a_failed_last_run_is_flagged_and_the_project_keeps_rolling
    runs = [run_of(5, "Nx", "storybook", conclusion: "failure", created: NOW - 600), run_of(4, "Nx", "storybook", created: NOW - 7200)]

    chosen, notes = Bench::Tick.plan([%w[Nx storybook]], runs, behind: ->(*) { true })

    assert_equal [%w[Nx storybook]], chosen
    assert_equal [["REVIEW", "Nx - storybook (rolling)", "last run 5 concluded failure"]], notes
  end

  def test_call_dispatches_the_plan_and_counts_failed_dispatches
    calls = []
    gh = lambda do |*args|
      calls << args
      raise Bench::Error, "dispatch failed" if args.include?("project=n8n")

      args.first == "run" ? "[]" : ""
    end
    out = StringIO.new

    failed = Bench::Tick.new("acme/bench", gh:, out:, now: NOW).call([%w[Go hugo], %w[Turbo n8n]], behind: ->(*) { true })

    assert_equal 1, failed
    assert_equal 2, calls.count { it.first(2) == %w[workflow run] }
    assert_match "dispatch Go - hugo (rolling)", out.string
    assert_match "FAILED   Turbo - n8n (rolling)", out.string
  end

  def test_a_dry_run_dispatches_nothing
    calls = []

    Bench::Tick.new("acme/bench", gh: ->(*args) { calls << args; args.first == "run" ? "[]" : "" }, out: StringIO.new, now: NOW).call([%w[Go hugo]], behind: ->(*) { true }, dry_run: true)

    refute calls.any? { it.first(2) == %w[workflow run] }
  end

  def test_active_runs_are_checked_even_when_older_than_the_recent_run_window
    gh = lambda do |*args|
      if args.first == "run"
        "[]"
      elsif args.any? { it.include?("status=in_progress") }
        JSON.generate(run_of(1, "Bazel", "grpc", status: "in_progress")) + "\n"
      elsif args.first == "api"
        ""
      else
        flunk "must not dispatch an active project"
      end
    end

    assert_equal 0, Bench::Tick.new("acme/bench", gh:, out: StringIO.new, now: NOW).call([%w[Bazel grpc]], behind: ->(*) { true })
  end

  def test_upstream_errors_fail_the_tick_without_dispatching_the_affected_project
    calls = []
    gh = ->(*args) { calls << args; args.first == "run" ? "[]" : "" }
    behind = ->(_, project) { raise Bench::Error, "fetch failed" if project == "grpc"; true }
    out = StringIO.new

    assert_equal 1, Bench::Tick.new("acme/bench", gh:, out:, now: NOW).call([%w[Bazel grpc], %w[Go hugo]], behind:)
    assert_equal ["project=hugo"], calls.select { it.first == "workflow" }.flat_map { it.grep(/\Aproject=/) }
    assert_includes out.string, "upstream check failed: fetch failed"
  end

  def test_a_failed_run_remains_visible_when_no_new_commit_is_due
    runs = [run_of(5, "Nx", "storybook", conclusion: "failure")]

    chosen, notes = Bench::Tick.plan([%w[Nx storybook]], runs, behind: ->(*) { false })

    assert_empty chosen
    assert_includes notes, ["REVIEW", "Nx - storybook (rolling)", "last run 5 concluded failure"]
  end
end
