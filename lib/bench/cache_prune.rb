module Bench
  class CachePrune
    def self.stale(caches, scope:, step:, prefixes: [])
      steps = caches.filter_map { |cache| [cache, Integer($1)] if cache["key"] =~ /\A#{Regexp.escape(scope)}-(\d+)\z/ }
      older = steps.any? { |_, saved| saved == step } ? steps.select { |_, saved| saved < step }.map(&:first) : []
      older + prefixes.flat_map { |prefix| caches.select { it["key"].start_with?(prefix) }.sort_by { it["created_at"] }[0...-1] }
    end

    def initialize(repo, gh: Bench.method(:gh))
      @repo = repo
      @gh = gh
    end

    def call(scope:, step:, prefixes: [])
      caches = [scope, *prefixes].flat_map { list(it) }.uniq { it["id"] }
      self.class.stale(caches, scope:, step:, prefixes:).each { @gh.call("api", "-X", "DELETE", "repos/#{@repo}/actions/caches/#{it["id"]}") }
    end

    private
      def list(prefix)
        @gh.call("api", "--paginate", "repos/#{@repo}/actions/caches?per_page=100&key=#{URI.encode_www_form_component(prefix)}", "--jq", ".actions_caches[] | {id, key, created_at}")
          .lines.map { JSON.parse(it) }
      end
  end
end
