module Bench
  class PhaseRun
    PLAN_CAPABILITIES = %w[tool-cache mount-cache].freeze

    STATE = ".bench-state.json"

    attr_reader :kase, :lane, :phase, :runner, :scope, :cache_scope, :sha, :step

    def self.resume(kase, lane, work_root:, results_dir:, env: ENV)
      state = JSON.parse(File.read(File.join(work_root, kase.tool.name, kase.name, STATE)))
      new(kase, lane, phase: state["phase"], runner: state["runner"], scope: state["scope"], cache_scope: state["cache_scope"],
                      sha: state["sha"], step: state["step"], work_root:, results_dir:, env:)
    end

    def initialize(kase, lane, phase:, runner:, scope:, work_root:, results_dir:, cache_scope: nil, sha: kase.start_sha, step: nil, env: ENV)
      @kase = kase
      @lane = lane
      @phase = phase
      @runner = runner
      @scope = scope
      @cache_scope = cache_scope || scope
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
      raise Error, "#{kase.id}: cold cannot be retried within a run because its cache scope may already hold data; dispatch a fresh run" if phase == "cold" && @env["GITHUB_RUN_ATTEMPT"].to_i > 1

      workspace.prepare(sha)
      FileUtils.mkdir_p(File.dirname(record_path))
      [*kase.prepare, *lane.prepare(phase)].each { shell(it) or raise Error, "#{kase.id}: prepare failed: #{it}" }
      save_state
    end

    def probe
      FileUtils.mkdir_p(workspace.dir)
      lane.probe.each { shell(it) or raise Error, "#{kase.id} #{lane.name}: probe failed: #{it}" }
    end

    def start
      save_state("monotonic" => Process.clock_gettime(Process::CLOCK_MONOTONIC), "started_at" => Time.now.utc.iso8601)
    end

    def build
      return $?&.exitstatus || 127 unless system(environment, *command, chdir: build_dir)

      lane.finish(phase).all? { shell(it, chdir: build_dir) } ? 0 : 1
    end

    def record(exit_status)
      seconds = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - state.fetch("monotonic")).round(3)
      write_record(started_at: state.fetch("started_at"), seconds:, exit_status:)
    end

    def record_path
      File.join(@results_dir, kase.tool.name, kase.name, scope, "#{[lane.name, runner, phase, step, rolling_run, retry_suffix].compact.join("-")}.json")
    end

    def build_dir
      File.join(workspace.dir, kase.directory)
    end

    def exported_env
      environment.reject { |key, value| @env[key] == value }
    end

    def cache_paths
      [*lane.paths, *kase.shared].map { File.expand_path(it, workspace.dir) }
    end

    private
      def retry_suffix
        "attempt-#{attempt}" if attempt.to_i > 1
      end

      def rolling_run
        @env["GITHUB_RUN_ID"] if phase == "rolling"
      end

      def attempt
        @env["GITHUB_RUN_ATTEMPT"]&.to_i
      end

      def workspace
        @workspace ||= Workspace.new(kase, lane:, scope: cache_scope, root: @work_root)
      end

      def state
        @state ||= JSON.parse(File.read(state_path))
      end

      def save_state(extra = {})
        @state = { "phase" => phase, "runner" => runner, "scope" => scope, "cache_scope" => cache_scope, "sha" => sha, "step" => step, **extra }
        File.write(state_path, JSON.generate(@state))
      end

      def state_path
        File.join(workspace.dir, STATE)
      end

      def command
        lane.boringcache? ? ["boringcache", kase.tool.name, *("--read-only" if phase == "warm")] : [*lane.wrap(phase, environment), *lane_program, *lane.args(phase, environment)]
      end

      def lane_program
        plan_command = adapter.fetch("command")
        return plan_command unless lane.program
        prefix = plan_command.first(lane.replaces.size)
        raise Error, "#{lane.name} replaces #{lane.replaces.join(" ")} but the plan runs #{prefix.join(" ")}" unless lane.replaces.any? && prefix == lane.replaces

        [*lane.program, *plan_command.drop(lane.replaces.size)]
      end

      def adapter
        @adapter ||= TomlRB.load_file(workspace.plan_path).dig("adapters", kase.tool.name) or
          raise Error, "#{kase.id}: #{kase.plan_path(lane)} has no [adapters.#{kase.tool.name}]"
      end

      def environment
        @environment ||= begin
          base = @env.to_h.merge(kase.tool.catalog.runner_env(runner), "BENCH_ROOT" => kase.tool.catalog.root, "BENCH_CASE" => kase.id, "BENCH_DIR" => workspace.dir, "BENCH_SCOPE" => "#{kase.tool.name}-#{kase.name}-#{cache_scope}")
          shared = base.merge(kase.env(base))
          shared.merge(lane.boringcache? ? { "BORINGCACHE_OBSERVABILITY_JSONL_PATH" => evidence_path } : lane.env(phase, shared))
        end
      end

      def shell(command, chdir: workspace.dir)
        system(environment, "bash", "-c", command, chdir:)
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
          "machine" => lane.machine || kase.tool.catalog.runner_machine(runner),
          "phase" => phase,
          "step" => step,
          "scope" => scope,
          "cache_scope" => cache_scope,
          "repo" => kase.repo,
          "sha" => sha,
          "seconds" => seconds,
          "cache_save_timing" => lane.cache_save_timing,
          "exit_status" => exit_status,
          "output_ok" => output_ok(exit_status),
          "provider_reported" => provider_reported,
          "observed" => observed,
          "evidence" => File.exist?(evidence_path) ? [File.basename(evidence_path)] : [],
          "versions" => { "boringcache" => boringcache_version },
          "run_url" => run_url,
          "attempt" => attempt,
          "started_at" => started_at
        }
        File.write(record_path, JSON.pretty_generate(record) + "\n")
        record
      end

      def provider_reported
        { "cache_session_summary" => session_summary }.compact
      end

      def observed
        machine = { "cpu" => cpu_model, "cores" => Etc.nprocessors }.compact
        return { "machine" => machine } unless kase.tool.name == "docker"

        { "machine" => machine, "image_platform" => image_platform, "buildx_builder" => buildx_builder }.compact
      end

      def cpu_model
        lscpu = (Open3.capture2("lscpu").first rescue "")[/^Model name:\s*(.+)$/, 1]
        cpuinfo = File.exist?("/proc/cpuinfo") ? File.read("/proc/cpuinfo")[/^model name\s*:\s*(.+)$/, 1] : nil
        sysctl = (Open3.capture2("sysctl", "-n", "machdep.cpu.brand_string").first rescue "") unless lscpu || cpuinfo
        [lscpu, cpuinfo, sysctl].map { it.to_s.strip }.find { !it.empty? && it != "-" }
      end

      def image_platform
        tag = adapter.fetch("command").each_cons(2).find { |flag, _| %w[--tag -t].include?(flag) }&.last
        return unless tag

        output, status = Open3.capture2(environment, "docker", "image", "inspect", "--format", "{{.Os}}/{{.Architecture}}", tag)
        output.strip if status.success?
      rescue Errno::ENOENT
        nil
      end

      def session_summary
        return unless File.exist?(evidence_path)

        File.foreach(evidence_path).filter_map { JSON.parse(it) rescue nil }.reverse.find { it["operation"] == "cache_session_summary" }
      end

      def buildx_builder
        return if lane.boringcache? || lane.program

        output, status = Open3.capture2e(environment, "docker", "buildx", "inspect")
        return unless status.success?

        header, nodes = output.split(/^Nodes:\n/, 2)
        { "name" => header[/^Name:\s*(.+)$/, 1], "driver" => header[/^Driver:\s*(.+)$/, 1],
          "nodes" => nodes.to_s.scan(/^Name:\s*(.+)\nEndpoint:\s*(.+)$/).map { |name, endpoint| { "name" => name.strip, "endpoint" => endpoint.strip } } }
      rescue Errno::ENOENT
        nil
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
