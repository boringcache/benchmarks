module Bench
  class Rolling
    def self.scope(lane, runner)
      "#{lane.name}-#{runner}-#{suffix}"
    end

    def self.suffix
      series = ENV.fetch("BENCH_ROLLING_SERIES", "")
      return "rolling" if series.empty?

      raise Error, "rolling series must use 1–64 lowercase letters, digits or hyphens, starting with a letter or digit" unless series.match?(/\A[a-z0-9][a-z0-9-]{0,63}\z/)

      "rolling-#{series}"
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

    private
      def last
        scopes = @kase.runs.flat_map { |lane, runners| Array(runners).map { self.class.scope(@kase.tool.lane(lane), it) } }
        @last ||= scopes.flat_map { Dir.glob(File.join(@results_dir, @kase.tool.name, @kase.name, it, "*.json")) }
          .map { JSON.parse(File.read(it)) }.max_by { it["step"] }
      end
  end
end
