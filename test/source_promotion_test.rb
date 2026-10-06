# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/source-promotion"
require_relative "../scripts/rolling-monitor"
require "minitest/mock"

class SourcePromotionTest < Minitest::Test
  VERSION = "vcli-canary-0123456789ab"

  def proposal(item)
    prefix = item.dig("execution", "source_prefix")
    base = if prefix
      BenchmarkPlan.settings(File.join(BenchmarkCases::ROOT, "cases", item.fetch("id"), "payload/benchmark-source.env")).fetch("#{prefix}_HEAD_SHA")
    else
      item.dig("source", "revision") || item.dig("source", "pins").find { |pin| pin["kind"] == "gitlink" }.fetch("revision")
    end
    record = {"case_id" => item.fetch("id"), "state" => "proposal", "base_sha" => base, "head_sha" => "a" * 40,
      "source_distance" => "1", "requires_verified_build" => item.dig("execution", "sync") == "verified-pair"}
    if prefix
      text = File.read(File.join(BenchmarkCases::ROOT, "cases", item.fetch("id"), "payload/benchmark-source.env"))
      record["candidate_source_env"] = text.sub(/^#{prefix}_BASE_SHA=.*$/, "#{prefix}_BASE_SHA=#{base}").sub(/^#{prefix}_HEAD_SHA=.*$/, "#{prefix}_HEAD_SHA=#{'a' * 40}")
    end
    record
  end

  class Publisher < SourcePromotion::Publisher
    attr_reader :saved, :requests
    attr_accessor :fail_request, :outcome

    def initialize
      super
      @saved, @requests, @files = [], [], {}
      @outcome = "in_progress"
    end

    def optional_file(path, ref: "main")
      @files[path]
    end

    def save(record, expected:, changes: {})
      path = state_path(record.fetch("case_id"))
      raise "State was overwritten" unless expected.fetch(path) == @files[path]
      @saved << {"record" => Marshal.load(Marshal.dump(record)), "changes" => changes}
      @files[path] = JSON.pretty_generate(record) + "\n"
    end

    def api(path, body: nil)
      if body
        raise "Dispatch happened before a durable intent" unless @saved.last.dig("record", "state") == "dispatching"
        @requests << body
        return {} if @fail_request == @requests.length
        {"workflow_run_id" => @requests.length}
      else
        {"status" => @outcome == "in_progress" ? "in_progress" : "completed", "conclusion" => @outcome}
      end
    end
  end

  def test_snapshot_promotion_changes_only_source_pins_and_matching_nix_uri
    item = BenchmarkCases.load_case("helix-nix")
    candidate, changes = SourcePromotion.changes(item, proposal(item))
    assert_equal "a" * 40, candidate.dig("source", "revision")
    assert_equal item.except("source"), candidate.except("source")
    assert_equal %w[cases/helix-nix/case.json cases/helix-nix/payload/.boringcache.toml cases/helix-nix/payload/recipe-contract.json], changes.keys.sort
    old = JSON.parse(File.read(File.join(BenchmarkCases::ROOT, "cases/helix-nix/payload/recipe-contract.json")))
    actual = JSON.parse(changes.fetch("cases/helix-nix/payload/recipe-contract.json"))
    assert_equal old.fetch("upstream_files"), actual.fetch("upstream_files")
  end

  def test_source_environment_cannot_change_toolchain_repository_or_commands
    item = BenchmarkCases.load_case("deno")
    proposed = proposal(item)
    SourcePromotion.changes(item, proposed)
    %w[DENO_RUST_VERSION DENO_SOURCE_REPOSITORY].each do |key|
      changed = proposed.merge("candidate_source_env" => proposed.fetch("candidate_source_env").sub(/^#{key}=.*$/, "#{key}=changed"))
      assert_raises(SourcePromotion::Error) { SourcePromotion.changes(item, changed) }
    end
    assert_raises(SourcePromotion::Error) { SourcePromotion.changes(item, proposed.merge("base_sha" => "b" * 40)) }
  end

  def test_native_variants_and_zed_auto_are_the_only_selected_rolling_targets
    item = BenchmarkCases.load_case("n8n")
    targets = SourcePromotion.targets(item, proposal(item), version: VERSION)
    assert_equal %w[distroless docker runners turbo], targets.map { |target| target.dig("inputs", "variant") }.sort
    assert targets.all? { |target| target.dig("inputs", "cli_version") == VERSION }
    zed = BenchmarkCases.load_case("zed")
    targets = SourcePromotion.targets(zed, proposal(zed), version: VERSION)
    assert_equal ["zed-zed-cargo-rolling-auto.yml"], targets.map { |target| target.fetch("workflow") }
  end

  def test_every_scheduled_case_can_plan_a_changed_source_run
    BenchmarkCadence.source_cases.each do |item|
      targets = SourcePromotion.targets(item, proposal(item), version: VERSION)
      refute_empty targets, item.fetch("id")
      assert targets.all? { |target| target.fetch("lane") == "rolling" }, item.fetch("id")
    end
  end

  def test_proposal_cannot_disable_zed_build_verification
    item = BenchmarkCases.load_case("zed")
    assert_raises(SourcePromotion::Error) { SourcePromotion.changes(item, proposal(item).merge("requires_verified_build" => false)) }
  end

  def test_grouped_request_failure_retains_all_variants_and_blocks_blind_retry
    item = BenchmarkCases.load_case("n8n")
    publisher = Publisher.new
    publisher.fail_request = 1
    Dir.mktmpdir do |directory|
      path = File.join(directory, "receipt.json")
      assert_raises(SourcePromotion::Error) { publisher.publish(item, proposal(item), version: VERSION, output: path) }
      assert_equal 1, publisher.requests.length
      record = JSON.parse(File.read(path))
      assert_equal "dispatch-failed", record.fetch("state")
      assert_equal ["request-unknown"], record.fetch("runs").map { |run| run.fetch("state") }
      assert_equal 4, record.fetch("runs").first.fetch("selections").length
      assert publisher.saved.first.fetch("changes").key?("cases/n8n/case.json")
      assert_raises(SourcePromotion::Error) { publisher.publish(item, proposal(item), version: VERSION, output: path) }
      assert_equal 1, publisher.requests.length
    end
  end

  def test_zed_promotes_only_after_all_requested_builds_succeed
    item = BenchmarkCases.load_case("zed")
    publisher = Publisher.new
    Dir.mktmpdir do |directory|
      path = File.join(directory, "receipt.json")
      publisher.publish(item, proposal(item), version: VERSION, output: path)
      assert_empty publisher.saved.first.fetch("changes")
      assert_equal "requested", publisher.reconcile(item, output: path).fetch("state")
      assert_equal 2, publisher.saved.length
      publisher.outcome = "success"
      check = ->(_item, run, **_options) { run.merge("state" => "success") }
      RollingMonitor.stub(:check_run, check) do
        assert_equal "promoted", publisher.reconcile(item, output: path).fetch("state")
      end
      assert publisher.saved.last.fetch("changes").key?("cases/zed/case.json")
      assert publisher.saved.last.fetch("changes").key?("cases/zed/payload/benchmark-source.env")
    end
  end

  def test_failed_zed_build_preserves_the_declared_source
    item = BenchmarkCases.load_case("zed")
    publisher = Publisher.new
    Dir.mktmpdir do |directory|
      path = File.join(directory, "receipt.json")
      publisher.publish(item, proposal(item), version: VERSION, output: path)
      publisher.outcome = "failure"
      check = ->(_item, run, **_options) { run.merge("state" => "failure") }
      RollingMonitor.stub(:check_run, check) do
        assert_equal "failed", publisher.reconcile(item, output: path).fetch("state")
      end
      assert publisher.saved.all? { |entry| entry.fetch("changes").empty? }
      assert_raises(SourcePromotion::Error) { publisher.publish(item, proposal(item), version: VERSION, output: path) }
    end
  end

  def test_publication_rejects_a_concurrent_edit_instead_of_overwriting_it
    publisher = SourcePromotion::Publisher.new
    requests = []
    api = lambda do |path, body: nil|
      requests << path
      path.include?("git/ref") ? {"object" => {"sha" => "b" * 40}} : {"type" => "file", "content" => Base64.strict_encode64("edited")}
    end
    publisher.stub(:api, api) do
      assert_raises(SourcePromotion::Error) { publisher.commit({"cases/example/case.json" => "new"}, expected: {"cases/example/case.json" => "original"}, message: "Advance source") }
    end
    refute_includes requests, "graphql"
  end

  def test_unrelated_branch_advancement_retries_with_a_new_expected_head
    [
      {"type" => "STALE_DATA", "message" => "Branch advanced"},
      {"type" => "FORBIDDEN", "path" => ["createCommitOnBranch"], "message" => "is at #{'c' * 40} but expected #{'b' * 40}"}
    ].each { |conflict| assert_concurrent_commit_retries(conflict) }
  end

  def test_permission_failures_and_unrelated_ref_errors_are_not_retried
    ["Resource not accessible by integration", "is at #{'c' * 40} but expected #{'a' * 40}"].each do |message|
      publisher = SourcePromotion::Publisher.new
      requests = 0
      api = lambda do |path, body: nil|
        if path == "graphql"
          requests += 1
          {"errors" => [{"type" => "FORBIDDEN", "path" => ["createCommitOnBranch"], "message" => message}]}
        else
          {"object" => {"sha" => "b" * 40}}
        end
      end
      publisher.stub(:api, api) do
        error = assert_raises(SourcePromotion::Error) { publisher.commit({"receipt.json" => "{}"}, expected: {}, message: "Record receipt") }
        assert_includes error.message, message
      end
      assert_equal 1, requests
    end
  end

  private

  def assert_concurrent_commit_retries(conflict)
    publisher = SourcePromotion::Publisher.new
    heads = ["b" * 40, "c" * 40]
    commits = []
    api = lambda do |path, body: nil|
      if path == "graphql"
        commits << body.fetch("variables").fetch("input")
        commits.length == 1 ? {"errors" => [conflict]} : {"data" => {"createCommitOnBranch" => {"commit" => {"oid" => "d" * 40}}}}
      elsif path.include?("git/ref")
        {"object" => {"sha" => heads.shift}}
      else
        {"type" => "file", "content" => Base64.strict_encode64("original")}
      end
    end
    publisher.stub(:api, api) do
      assert_equal "d" * 40, publisher.commit({"cases/example/case.json" => "new"}, expected: {"cases/example/case.json" => "original"}, message: "Advance source")
    end
    assert_equal ["b" * 40, "c" * 40], commits.map { |input| input.fetch("expectedHeadOid") }
    assert_equal "new", Base64.decode64(commits.last.dig("fileChanges", "additions", 0, "contents"))
  end
end
