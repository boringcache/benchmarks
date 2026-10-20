require_relative "test_helper"

class BuildkitPruneTest < Minitest::Test
  NOW = Time.utc(2026, 10, 12, 12)
  OLD = "2026-10-11T12:00:00Z"
  RECENT = "2026-10-12T11:00:00Z"

  def entry(key, created_at = OLD, size = 100)
    { "id" => key.hash.abs, "key" => key, "version" => "v", "size_in_bytes" => size, "created_at" => created_at }
  end

  def index(scope, version, created_at = OLD)
    entry("index-#{scope}-1-0123abcd##{version}", created_at)
  end

  def blob(digest, created_at = OLD)
    entry("buildkit-blob-1-sha256:#{digest}", created_at)
  end

  def plan(layers:, blobs:, indexes:)
    Bench::BuildkitPrune.plan(indexes:, blobs:, layers:, active_scopes: ["docker-app-gha-github-rolling"], now: NOW)
  end

  def test_only_blobs_no_active_index_references_and_older_indexes_go
    indexes = [index("docker-app-gha-github-rolling", 3), index("docker-app-gha-github-rolling", 2), index("docker-app-gha-github-rolling", 1),
               index("docker-dropped-gha-github-rolling", 1)]
    blobs = [blob("aa"), blob("bb"), blob("cc"), blob("dd", RECENT), blob("ee")]
    layers = { indexes.first["key"] => %w[sha256:aa sha256:bb] }

    result = plan(layers:, blobs:, indexes:)

    assert_equal %w[sha256:cc sha256:ee], result.blobs.map { it["key"].delete_prefix("buildkit-blob-1-") }
    assert_equal [indexes[2]["key"], indexes[3]["key"]], result.indexes.map { it["key"] }
    assert_equal [2, 0, 1.0, true], [result.referenced, result.missing, result.coverage, result.deletable]
  end

  def test_nothing_is_deletable_when_the_index_does_not_match_the_listed_blobs
    indexes = [index("docker-app-gha-github-rolling", 1)]
    result = plan(layers: { indexes.first["key"] => %w[sha256:xx sha256:yy] }, blobs: [blob("aa")], indexes:)

    assert_equal [2, 0.0, false], [result.missing, result.coverage, result.deletable]
  end

  def test_the_newest_index_is_chosen_by_its_version_number
    indexes = [index("docker-app-gha-github-rolling", 9), index("docker-app-gha-github-rolling", 10)]

    assert_equal [indexes.last["key"]], Bench::BuildkitPrune.newest(indexes, ["docker-app-gha-github-rolling"]).map { it["key"] }
  end

  def test_delete_continues_when_a_listed_cache_is_already_gone
    calls = []
    gh = lambda do |*args|
      calls << args
      raise Bench::Error, "gh api -X failed: gh: Not Found (HTTP 404)"
    end

    Bench::BuildkitPrune.new("owner/repo", gh:).delete("id" => 123)

    assert_equal [["api", "-X", "DELETE", "repos/owner/repo/actions/caches/123"]], calls
  end

  def test_delete_preserves_other_api_errors
    [403, 429, 500].each do |status|
      gh = ->(*) { raise Bench::Error, "gh api -X failed: HTTP #{status}" }

      assert_raises(Bench::Error) { Bench::BuildkitPrune.new("owner/repo", gh:).delete("id" => 123) }
    end
  end
end
