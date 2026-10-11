require_relative "test_helper"

class CachePruneTest < Minitest::Test
  SCOPE = "turbo-n8n-gha-github-rolling"

  def cache(id, key, created_at = "2026-10-11T0#{id}:00:00Z")
    { "id" => id, "key" => key, "created_at" => created_at }
  end

  def test_older_steps_of_the_lane_go_once_this_step_has_saved
    caches = [cache(1, "#{SCOPE}-40"), cache(2, "#{SCOPE}-41"), cache(3, "#{SCOPE}-42"), cache(4, "#{SCOPE}-2-41"), cache(5, "turbo-n8n-gha-github-arm-rolling-40")]

    assert_equal [1, 2], Bench::CachePrune.stale(caches, scope: SCOPE, step: 42).map { it["id"] }
  end

  def test_nothing_goes_when_this_step_did_not_save
    caches = [cache(1, "#{SCOPE}-40"), cache(2, "#{SCOPE}-41")]

    assert_empty Bench::CachePrune.stale(caches, scope: SCOPE, step: 42)
  end

  def test_tool_keyed_caches_keep_only_their_newest_entry
    scope = "cargo-zed-kache-github-rolling"
    caches = [cache(1, "kache-#{scope}-v1.0.0-linux-x64-aaaa"), cache(3, "kache-#{scope}-v1.0.0-linux-x64-cccc"), cache(2, "kache-#{scope}-v1.0.0-linux-x64-bbbb"),
              cache(4, "kache-#{scope}-2-v1.0.0-linux-x64-dddd")]

    assert_equal [1, 2], Bench::CachePrune.stale(caches, scope:, step: 9, prefixes: ["kache-#{scope}-v"]).map { it["id"] }
  end

  def test_call_lists_each_prefix_and_deletes_the_stale_entries
    calls = []
    listed = { SCOPE => [cache(1, "#{SCOPE}-40"), cache(2, "#{SCOPE}-41")], "tool-#{SCOPE}-x" => [cache(3, "tool-#{SCOPE}-x1"), cache(4, "tool-#{SCOPE}-x2")] }
    gh = lambda do |*args|
      calls << args
      key = args.join(" ")[/key=([^&\s]+)/, 1]
      key ? listed.fetch(URI.decode_www_form_component(key)).map { JSON.generate(it) }.join("\n") : ""
    end

    deleted = Bench::CachePrune.new("acme/bench", gh:).call(scope: SCOPE, step: 41, prefixes: ["tool-#{SCOPE}-x"])

    assert_equal [1, 3], deleted.map { it["id"] }
    assert_equal [%w[api -X DELETE repos/acme/bench/actions/caches/1], %w[api -X DELETE repos/acme/bench/actions/caches/3]], calls.select { it.include?("DELETE") }
  end
end
