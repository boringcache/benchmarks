module Bench
  class PhaseRun
    attr_reader :kase, :lane, :phase, :runner, :scope, :sha, :step

    def initialize(kase, lane, phase:, runner:, scope:, work_root:, results_dir:, sha: kase.start_sha, step: nil, env: ENV)
      @kase = kase
      @lane = lane
      @phase = phase
      @runner = runner
      @scope = scope
      @work_root = work_root
      @results_dir = results_dir
      @sha = sha
      @step = step
      @env = env
    end

    def call
      workspace.prepare(sha)
      FileUtils.mkdir_p(File.dirname(record_path))
      kase.prepare.each { shell(it) or raise Error, "#{kase.id}: prepare failed: #{it}" }

      started_at = Time.now.utc
      seconds, exit_status = measure { build }
      write_record(started_at:, seconds:, exit_status:)
    end

    def record_path
      File.join(@results_dir, kase.tool.name, kase.name, scope, "#{[lane.name, runner, phase, step].compact.join("-")}.json")
    end

    private
      def workspace
        @workspace ||= Workspace.new(kase, scope:, phase: [phase, step].compact.join("-"), root: @work_root)
      end

      def plan_dir
        workspace.plan_dir(lane)
      end

      def build
        system(environment, *command, chdir: File.join(plan_dir, kase.directory)) ? 0 : ($?&.exitstatus || 127)
      end

      def command
        lane.boringcache? ? boringcache_command : adapter.fetch("command")
      end

      def boringcache_command
        read_only = ("--read-only" if phase == "warm")
        return ["boringcache", kase.tool.name, *read_only] unless kase.tool.name == "run"

        ["boringcache", "run", *adapter.fetch("profiles", []).flat_map { ["--profile", it] },
         *("--no-platform" if adapter["no-platform"]), *("--no-git" if adapter["no-git"]), *read_only, "--", *adapter.fetch("command")]
      end

      def adapter
        @adapter ||= TomlRB.load_file(File.join(plan_dir, ".boringcache.toml")).dig("adapters", kase.tool.name) or
          raise Error, "#{kase.id}: #{lane.plan_dir}/.boringcache.toml has no [adapters.#{kase.tool.name}]"
      end

      def environment
        @environment ||= begin
          base = @env.to_h.merge("BENCH_DIR" => workspace.dir)
          shared = base.merge(kase.env(base))
          shared.merge(lane.boringcache? ? { "BORINGCACHE_OBSERVABILITY_JSONL_PATH" => evidence_path } : lane.env(phase, shared))
        end
      end

      def shell(command)
        system(environment, "bash", "-c", command, chdir: workspace.dir)
      end

      def measure
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = yield
        [(Process.clock_gettime(Process::CLOCK_MONOTONIC) - start).round(3), result]
      end

      def output_ok(exit_status)
        return false unless exit_status.zero?

        kase.check.empty? ? nil : shell(kase.check)
      end

      def evidence_path
        record_path.sub(/\.json\z/, ".boringcache.jsonl")
      end

      def write_record(started_at:, seconds:, exit_status:)
        record = {
          "adapter_command" => kase.tool.name,
          "case" => kase.name,
          "lane" => lane.name,
          "provider" => lane.provider,
          "level" => lane.level,
          "capabilities" => lane.capabilities,
          "runner" => runner,
          "runner_label" => kase.tool.catalog.runners[runner],
          "phase" => phase,
          "step" => step,
          "scope" => scope,
          "repo" => kase.repo,
          "sha" => sha,
          "seconds" => seconds,
          "exit_status" => exit_status,
          "output_ok" => output_ok(exit_status),
          "provider_reported" => provider_reported,
          "evidence" => File.exist?(evidence_path) ? [File.basename(evidence_path)] : [],
          "versions" => { "boringcache" => boringcache_version },
          "run_url" => run_url,
          "attempt" => @env["GITHUB_RUN_ATTEMPT"]&.to_i,
          "started_at" => started_at.iso8601
        }
        File.write(record_path, JSON.pretty_generate(record) + "\n")
        record
      end

      def provider_reported
        return {} unless File.exist?(evidence_path)

        summary = File.foreach(evidence_path).filter_map { JSON.parse(it) rescue nil }.reverse.find { it["operation"] == "cache_session_summary" }
        summary ? { "cache_session_summary" => summary } : {}
      end

      def boringcache_version
        output, status = Open3.capture2("boringcache", "--version")
        output.split.last if status.success?
      rescue Errno::ENOENT
        nil
      end

      def run_url
        "#{@env.fetch("GITHUB_SERVER_URL", "https://github.com")}/#{@env["GITHUB_REPOSITORY"]}/actions/runs/#{@env["GITHUB_RUN_ID"]}" if @env["GITHUB_RUN_ID"]
      end
  end
end
