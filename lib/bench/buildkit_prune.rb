require "net/http"

module Bench
  class BuildkitPrune
    BLOB_PREFIX = "buildkit-blob-1-"
    INDEX = /\Aindex-(?<scope>.+)-1-[0-9a-f]{8}(?:-sig)?#(?<version>\d+)\z/
    MIN_AGE = 6 * 3600
    KEEP_INDEXES = 2
    MIN_COVERAGE = 0.95

    Plan = Struct.new(:blobs, :indexes, :referenced, :missing, :coverage, :deletable, keyword_init: true) do
      def bytes
        [*blobs, *indexes].sum { it["size_in_bytes"].to_i }
      end
    end

    def self.by_base(indexes)
      indexes.filter_map { |entry| (match = INDEX.match(entry["key"])) && [entry, match] }
        .group_by { |entry, _| entry["key"].sub(/#\d+\z/, "") }.values
    end

    def self.newest(indexes, active_scopes)
      by_base(indexes).filter_map do |group|
        entry, match = group.max_by { |_, m| m[:version].to_i }
        entry if active_scopes.include?(match[:scope])
      end
    end

    def self.plan(indexes:, blobs:, layers:, active_scopes:, now:)
      old = ->(entry) { now - Time.parse(entry["created_at"]) > MIN_AGE }
      newest = newest(indexes, active_scopes)
      stale_indexes = by_base(indexes).flat_map do |group|
        sorted = group.sort_by { |_, m| -m[:version].to_i }
        keep = active_scopes.include?(sorted.first[1][:scope]) ? KEEP_INDEXES : 0
        sorted.drop(keep).map(&:first)
      end.select(&old)

      referenced = newest.flat_map { layers.fetch(it["key"]) }.to_set
      present = blobs.to_set { it["key"].delete_prefix(BLOB_PREFIX).delete_suffix("-sig") }
      missing = referenced.reject { present.include?(it) }
      coverage = referenced.empty? ? 0.0 : 1 - missing.size.fdiv(referenced.size)
      stale_blobs = blobs.reject { referenced.include?(it["key"].delete_prefix(BLOB_PREFIX).delete_suffix("-sig")) }.select(&old)
      Plan.new(blobs: stale_blobs, indexes: stale_indexes, referenced: referenced.size, missing: missing.size, coverage:,
               deletable: newest.any? && coverage >= MIN_COVERAGE)
    end

    def initialize(repo, gh: Bench.method(:gh), env: ENV)
      @repo = repo
      @gh = gh
      @env = env
    end

    def list(prefix)
      @gh.call("api", "--paginate", "repos/#{@repo}/actions/caches?per_page=100&key=#{URI.encode_www_form_component(prefix)}",
               "--jq", ".actions_caches[] | {id, key, version, size_in_bytes, created_at}").lines.map { JSON.parse(it) }
    end

    def layers(entry)
      response = twirp("GetCacheEntryDownloadURL", "key" => entry["key"], "restore_keys" => [], "version" => entry["version"])
      url = response["signed_download_url"] || response["signedDownloadUrl"]
      raise Error, "#{entry["key"]}: no download URL" if url.to_s.empty?

      JSON.parse(get(url)).fetch("layers", []).map { it.fetch("blob") }
    end

    def delete(entry)
      @gh.call("api", "-X", "DELETE", "repos/#{@repo}/actions/caches/#{entry["id"]}")
    rescue Error => error
      raise unless error.message.end_with?("(HTTP 404)")
    end

    private
      def twirp(method, body)
        base = @env.fetch("ACTIONS_RESULTS_URL") { raise Error, "prune-buildkit needs the Actions runtime (ACTIONS_RESULTS_URL)" }
        uri = URI.join(base, "twirp/github.actions.results.api.v1.CacheService/#{method}")
        request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json", "Authorization" => "Bearer #{@env.fetch("ACTIONS_RUNTIME_TOKEN")}")
        request.body = JSON.generate(body)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { it.request(request) }
        raise Error, "#{method} #{body["key"]}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      end

      def get(url)
        uri = URI(url)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { it.request(Net::HTTP::Get.new(uri)) }
        raise Error, "download #{uri.host}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        response.body
      end
  end
end
