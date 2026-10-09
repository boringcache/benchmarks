module Bench
  class Rolling
    def self.scope(lane, runner, series = nil)
      ["#{lane.name}-#{runner}-rolling", series].compact.join("-")
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

    def recorded_step(step)
      sha = rolling_records.find { it["step"] == step }&.dig("sha")
      [step, sha] if sha
    end

    def passed?(lane, runner, step)
      records(File.join(cache_scope(lane, runner), "*.json")).any? { it["step"] == step && it["exit_status"] == 0 && it["output_ok"] == true }
    end

    def cache_scope(lane, runner)
      self.class.scope(lane, runner, @kase.rolling_series)
    end

    def last_step(lane, runner)
      records(File.join(cache_scope(lane, runner), "*.json")).filter_map { it["step"] }.max
    end

    def continues?(lane, runner)
      records(File.join(cache_scope(lane, runner), "*.json")).any? { it["cache_scope"] == cache_scope(lane, runner) }
    end

    private
      def records(pattern)
        Dir.glob(File.join(@results_dir, @kase.tool.name, @kase.name, pattern)).sort.map { JSON.parse(File.read(it)) }
      end

      def last
        @last ||= rolling_records.max_by { it["step"] }
      end

      def rolling_records
        series_dirs = ["*-rolling", @kase.rolling_series].compact.join("-")
        @rolling_records ||= Dir.glob(File.join(@results_dir, @kase.tool.name, @kase.name, series_dirs, "*-rolling-*.json")).map { JSON.parse(File.read(it)) }
      end
  end
end
