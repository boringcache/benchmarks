module Bench
  class PhaseRun
    PLAN_CAPABILITIES = %w[tool-cache mount-cache].freeze

    STATE = ".bench-state.json"

    attr_reader :kase, :lane, :phase, :runner, :scope, :sha, :step

    def self.resume(kase, lane, work_root:, results_dir:, env: ENV)
      state = JSON.parse(File.read(File.join(work_root, kase.tool.name, kase.name, lane.name, STATE)))
      new(kase, lane, phase: state["phase"], runner: state["runner"], scope: state["scope"], sha: state["sha"], step: state["step"],
                      work_root:, results_dir:, env:)
    end

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
      prepare
      start
      record(build)
    end

    def prepare
      workspace.prepare(sha)
      FileUtils.mkdir_p(File.dirname(record_path))
      [*kase.prepare, *lane.prepare(phase)].each { shell(it) or raise Error, "#{kase.id}: prepare failed: #{it}" }
      save_state
    end

    def start
      save_state("monotonic" => Process.clock_gettime(Process::CLOCK_MONOTONIC), "started_at" => Time.now.utc.iso8601)
    end

    def build
      system(environment, *command, chdir: build_dir) ? 0 : ($?&.exitstatus || 127)
    end

    def record(exit_status)
      seconds = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - state.fetch("monotonic")).round(3)
      write_record(started_at: state.fetch("started_at"), seconds:, exit_status:)
    end

    def record_path
      File.join(@results_dir, kase.tool.name, kase.name, scope, "#{[lane.name, runner, phase, step].compact.join("-")}.json")
    end

    def build_dir
      File.join(workspace.dir, kase.directory)
    end

    def exported_env
      environment.reject { |key, value| @env[key] == value }
    end

    def cache_paths
      [*lane.paths, *kase.shared].map { File.join(workspace.dir, it) }
    end

    private
      def workspace
        @workspace ||= Workspace.new(kase, lane:, scope:, root: @work_root)
      end

      def state
        @state ||= JSON.parse(File.read(state_path))
      end

      def save_state(extra = {})
        @state = { "phase" => phase, "runner" => runner, "scope" => scope, "sha" => sha, "step" => step, **extra }
        File.write(state_path, JSON.generate(@state))
      end

      def state_path
        File.join(workspace.dir, STATE)
      end

      def command
        lane.boringcache? ? ["boringcache", kase.tool.name, *("--read-only" if phase == "warm")] : [*lane_program, *lane.args(phase, environment)]
      end

      def lane_program
        plan_command = adapter.fetch("command")
        return plan_command unless lane.program
        raise Error, "#{lane.name} replaces docker buildx but the plan runs #{plan_command.first(2).join(" ")}" unless plan_command.first(2) == %w[docker buildx]

        [*lane.program, *plan_command.drop(2)]
      end

      def adapter
        @adapter ||= TomlRB.load_file(workspace.plan_path).dig("adapters", kase.tool.name) or
          raise Error, "#{kase.id}: #{kase.plan_path(lane)} has no [adapters.#{kase.tool.name}]"
      end

      def environment
        @environment ||= begin
          base = @env.to_h.merge(kase.tool.catalog.runner_env(runner), "BENCH_DIR" => workspace.dir, "BENCH_SCOPE" => "#{kase.tool.name}-#{kase.name}-#{scope}")
          shared = base.merge(kase.env(base))
          shared.merge(lane.boringcache? ? { "BORINGCACHE_OBSERVABILITY_JSONL_PATH" => evidence_path } : lane.env(phase, shared))
        end
      end

      def shell(command)
        system(environment, "bash", "-c", command, chdir: workspace.dir)
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
          "capabilities" => lane.capabilities.reject { PLAN_CAPABILITIES.include?(it) && !adapter[it] },
          "runner" => runner,
          "runner_label" => kase.tool.catalog.runner_label(runner),
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
          "started_at" => started_at
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
