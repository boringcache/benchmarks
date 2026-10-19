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

    def sample_source
      sources = @kase.samples.keys.filter_map { @kase.tool.lane(it).reads }.uniq
      raise Error, "#{@kase.id}: samples need one shared GitHub cache source" unless sources.size == 1

      source = sources.first
      lane = @kase.tool.lane(source.fetch("lane"))
      latest = records(File.join(cache_scope(lane, source.fetch("runner")), "*.json")).max_by { [it["step"].to_i, it["started_at"].to_s, it["attempt"].to_i] }
      newest_step = rolling_records.filter_map { it["step"] }.max
      unless latest && (!newest_step || latest["step"] == newest_step) && !latest["excluded"] && latest["exit_status"] == 0 && latest["output_ok"] == true && latest.fetch("job_conclusion", "success") == "success"
        raise Error, "#{@kase.id}: latest #{lane.name} build has no successful cache seed"
      end

      latest.slice("step", "sha", "run_url", "lane", "runner", "cache_scope", "versions")
    end

    def passed?(lane, runner, step = nil)
      records(File.join(cache_scope(lane, runner), "*.json")).any? { (step.nil? || it["step"] == step) && it["exit_status"] == 0 && it["output_ok"] == true && it.fetch("job_conclusion", "success") == "success" }
    end

    def cache_scope(lane, runner)
      self.class.scope(lane, runner, @kase.rolling_series)
    end

    def read_scope(lane, runner)
      return cache_scope(lane, runner) unless lane.reads

      self.class.scope(@kase.tool.lane(lane.reads.fetch("lane")), lane.reads.fetch("runner"), @kase.rolling_series)
    end

    def recorded?(lane, runner, step)
      records(File.join(cache_scope(lane, runner), "*.json")).any? { it["step"] == step }
    end

    def ran_on?(lane, runner, date)
      records(File.join(cache_scope(lane, runner), "*.json")).any? { it["started_at"].to_s.start_with?(date) }
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
