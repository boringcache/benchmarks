# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/publish-current"

class PublishCurrentTest < Minitest::Test
  def test_publication_retries_unrelated_source_commits_but_rejects_changed_data
    publisher = PublishCurrent::Publisher.new
    original = "old data\n"
    heads, requests = ["a" * 40, "b" * 40], []
    api = lambda do |path, body: nil|
      if path.include?("git/ref")
        {"object" => {"sha" => heads.shift}}
      elsif path.include?("git/trees")
        {"tree" => [{"type" => "blob", "path" => "data/latest/current.json", "sha" => Digest::SHA1.hexdigest("blob #{original.bytesize}\0#{original}")}], "truncated" => false}
      else
        requests << body.fetch("variables").fetch("input")
        requests.length == 1 ? {"errors" => [{"type" => "STALE_DATA", "message" => "Branch advanced"}]} :
          {"data" => {"createCommitOnBranch" => {"commit" => {"oid" => "c" * 40}}}}
      end
    end
    expected = {"data/latest/current.json" => original, "data/observations/daily/42.json" => nil}
    publisher.stub(:api, api) do
      assert_equal "c" * 40, publisher.commit({"data/latest/current.json" => "new"}, expected: expected, message: "Publish observations")
      assert_raises(BenchmarkCases::Error) { publisher.verify_expected("c" * 40, expected.merge("data/latest/current.json" => "another value")) }
    end
    assert_equal ["a" * 40, "b" * 40], requests.map { |input| input.fetch("expectedHeadOid") }
    assert_equal "new", Base64.decode64(requests.last.dig("fileChanges", "additions", 0, "contents"))
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
end
