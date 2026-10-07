module Bench
  class Rolling
    def initialize(kase, lane, runner:, results_dir:, work_root:)
      @kase = kase
      @lane = lane
      @runner = runner
      @results_dir = results_dir
      @work_root = work_root
    end

    def scope
      "#{@lane.name}-#{@runner}-rolling"
    end

    def next_step
      return [0, @kase.start_sha] unless last

      sha = Upstream.new(@kase, root: @work_root).next_commit(last["sha"])
      [last["step"] + 1, sha] if sha
    end

    private
      def last
        @last ||= Dir.glob(File.join(@results_dir, @kase.tool.name, @kase.name, scope, "*-rolling-*.json"))
          .map { JSON.parse(File.read(it)) }.max_by { it["step"] }
      end
  end
end
