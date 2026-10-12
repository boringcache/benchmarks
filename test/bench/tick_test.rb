require_relative "test_helper"
require "stringio"

class TickTest < Minitest::Test
  NOW = Time.utc(2026, 10, 12, 16)

  def run_of(id, tool, project, status: "completed", conclusion: "success", created: NOW - 3600)
    { "databaseId" => id, "displayTitle" => Bench::Tick.title(tool, project), "status" => status, "conclusion" => conclusion, "createdAt" => created.iso8601 }
  end

  def test_only_projects_with_new_upstream_commits_are_dispatched
    behind = ->(_, project) { project != "hugo" }

    chosen, notes = Bench::Tick.plan([%w[Go hugo], %w[Bazel grpc]], [], behind:)

    assert_equal [%w[Bazel grpc]], chosen
    assert_equal [["current", "Go - hugo (rolling)", "no new upstream commit"]], notes
  end

  def test_a_running_project_behind_upstream_queues_its_next_step_once
    runs = [run_of(1, "Rust/Cargo", "zed", status: "in_progress"), run_of(2, "Nix", "zed", status: "in_progress"), run_of(3, "Nix", "zed", status: "queued")]

    chosen, notes = Bench::Tick.plan([%w[Rust/Cargo zed], %w[Nix zed]], runs, behind: ->(*) { true })

    assert_equal [%w[Rust/Cargo zed]], chosen
    assert_equal [["busy", "Rust/Cargo - zed (rolling)", "next step queues behind run 1"], ["queued", "Nix - zed (rolling)", "next step already waiting"]], notes.sort
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

    Bench::Tick.new("acme/bench", gh: ->(*args) { calls << args; "[]" }, out: StringIO.new, now: NOW).call([%w[Go hugo]], behind: ->(*) { true }, dry_run: true)

    assert_equal [%w[run list]], calls.map { it.first(2) }
  end
end
