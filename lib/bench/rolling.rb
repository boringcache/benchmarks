module Bench
  class Rolling
    def self.scope(lane, runner)
      "#{lane.name}-#{runner}-rolling"
    end

    def initialize(kase, results_dir:, work_root:)
      @kase = kase
      @results_dir = results_dir
      @work_root = work_root
    end

    def next_step
      return [0, @kase.start_sha] unless last

      sha = Upstream.new(@kase, root: @work_root).next_commit(last["sha"])
      [last["step"] + 1, sha] if sha
    end

    def cache_scope(lane, runner)
      pinned(lane, runner) || fresh_scope(lane, runner) || self.class.scope(lane, runner)
    end

    def continues?(lane, runner)
      records(File.join(self.class.scope(lane, runner), "*.json")).any?
    end

    private
      def pinned(lane, runner)
        records(File.join(self.class.scope(lane, runner), "*.json")).filter_map { it["cache_scope"] }.first
      end

      def fresh_scope(lane, runner)
        records(File.join("#{lane.name}-#{runner}-*", "#{lane.name}-#{runner}-cold*.json"))
          .select { it["exit_status"] == 0 && it["output_ok"] == true && it["sha"] == @kase.start_sha && it.dig("versions", "boringcache_release").nil? }
          .max_by { it["scope"].to_s[/\d+\z/].to_i }&.fetch("scope")
      end

      def records(pattern)
        Dir.glob(File.join(@results_dir, @kase.tool.name, @kase.name, pattern)).sort.map { JSON.parse(File.read(it)) }
      end

      def last
        @last ||= Dir.glob(File.join(@results_dir, @kase.tool.name, @kase.name, "*-rolling", "*-rolling-*.json"))
          .map { JSON.parse(File.read(it)) }.max_by { it["step"] }
      end
  end
end
