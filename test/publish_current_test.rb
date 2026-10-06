# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/publish-current"

class PublishCurrentTest < Minitest::Test
  def test_shared_project_run_retains_every_case_receipt
    Dir.mktmpdir do |directory|
      one = {"id" => 42, "workflow" => "project-rolling.yml", "canonical_records" => [{"case" => {"case_id" => "hugo"}}]}
      two = one.merge("canonical_records" => [{"case" => {"case_id" => "hugo-go"}}])
      current = {"outcomes" => {"rolling" => {"collected_at" => "2026-10-06T11:00:00Z", "cases" => [{"runs" => [one]}, {"runs" => [two]}]}}}
      PublishCurrent.retain(current, directory: directory)
      retained = JSON.parse(File.read(File.join(directory, "rolling/42.json")))
      assert_equal [one, two], retained.fetch("case_records")
    end
  end

  def test_publication_retries_unrelated_source_commits_but_rejects_changed_data
    publisher = PublishCurrent::Publisher.new
    original = "old data\n"
    heads, requests, blobs = ["a" * 40, "b" * 40, "b" * 40], [], []
    api = lambda do |path, body: nil|
      if path.include?("git/ref")
        {"object" => {"sha" => heads.shift}}
      elsif path.include?("git/trees") && !body
        {"tree" => [{"type" => "blob", "path" => "data/latest/current.json", "sha" => Digest::SHA1.hexdigest("blob #{original.bytesize}\0#{original}")}], "truncated" => false}
      elsif path.end_with?("git/blobs")
        blobs << body
        {"sha" => "d" * 40}
      elsif path.include?("git/commits/")
        {"tree" => {"sha" => path.split('/').last}}
      elsif path.end_with?("git/trees")
        {"sha" => "e" * 40}
      else
        requests << body
        {"sha" => "c" * 40}
      end
    end
    expected = {"data/latest/current.json" => original, "data/observations/daily/42.json" => nil}
    outcomes = [false, true]
    publisher.stub(:api, api) do
      publisher.stub(:advance_ref, ->(_sha) { outcomes.shift }) do
        assert_equal "c" * 40, publisher.commit({"data/latest/current.json" => "new"}, expected: expected, message: "Publish observations")
      end
      assert_raises(BenchmarkCases::Error) { publisher.verify_expected("c" * 40, expected.merge("data/latest/current.json" => "another value")) }
    end
    assert_equal [["a" * 40], ["b" * 40]], requests.map { |input| input.fetch("parents") }
    assert_equal 1, blobs.length
    assert_equal "new", Base64.decode64(blobs.first.fetch("content"))
  end

  def test_publication_checks_previous_contents_and_only_writes_changed_data
    Dir.mktmpdir do |root|
      BenchmarkCases.write_json(File.join(root, "data/latest/current.json"), {"new" => true})
      BenchmarkCases.write_json(File.join(root, "data/latest/unchanged.json"), {})
      BenchmarkCases.write_json(File.join(root, "data/observations/daily/42.json"), {"state" => "in_progress"})
      BenchmarkCases.write_json(File.join(root, "cases/example/case.json"), {"source" => "user work"})
      calls = []
      publisher = Object.new
      publisher.define_singleton_method(:commit) { |changes, **options| calls << [changes, options]; "a" * 40 }
      command = lambda do |*arguments, **|
        if arguments[1] == "ls-tree"
          "data/latest/current.json\ndata/latest/unchanged.json\n"
        else
          arguments.last == "HEAD:data/latest/unchanged.json" ? "{}\n" : "old data\n"
        end
      end
      BenchmarkCases.stub(:command, command) do
        assert_equal "a" * 40, PublishCurrent.commit(root: root, publisher: publisher)
      end
      changes, options = calls.fetch(0)
      assert_equal %w[data/latest/current.json data/observations/daily/42.json], changes.keys
      assert_equal "old data\n", options.fetch(:expected).fetch("data/latest/current.json")
      assert_nil options.fetch(:expected).fetch("data/observations/daily/42.json")
      assert_equal "in_progress", JSON.parse(changes.fetch("data/observations/daily/42.json")).fetch("state")
    end
  end

  def test_reference_update_never_forces_and_reconciles_uncertain_acceptance
    publisher = PublishCurrent::Publisher.new
    success, failure = Struct.new(:success?).new(true), Struct.new(:success?).new(false)
    sha = "a" * 40
    replies = [
      [JSON.generate({"object" => {"sha" => sha}}), "", success],
      [JSON.generate({"message" => "Update is not a fast forward"}), "gh: HTTP 422", failure],
      ["", "gh: HTTP 504", failure]
    ]
    capture = lambda do |*args, stdin_data:|
      assert_equal ["gh", "api", "repos/boringcache/benchmarks/git/refs/heads/main", "--method", "PATCH", "--input", "-"], args
      assert_equal({"sha" => sha, "force" => false}, JSON.parse(stdin_data))
      replies.shift
    end
    Open3.stub(:capture3, capture) do
      assert publisher.advance_ref(sha)
      refute publisher.advance_ref(sha)
      publisher.stub(:api, {"object" => {"sha" => sha}}) { assert publisher.advance_ref(sha) }
    end
    Open3.stub(:capture3, ["", "gh: HTTP 504", failure]) do
      publisher.stub(:api, {"object" => {"sha" => "b" * 40}}) do
        assert_raises(SourcePromotion::Error) { publisher.advance_ref(sha) }
      end
    end
  end

  def test_index_cannot_publish_unprotected_files_or_harness_changes
    publisher = PublishCurrent::Publisher.new
    %w[cases/example/case.json data/latest/../other.json data/latest/current.json].each do |path|
      assert_raises(SourcePromotion::Error) { publisher.commit({path => "{}"}, expected: {}, message: "Publish observations") }
    end
  end
end
