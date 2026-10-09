module Bench
  class CLI
    USAGE = <<~TEXT
      Usage:
        bin/bench check
        bin/bench list
        bin/bench run <tool>/<case> --lane LANE [--phase cold|warm|rolling] [--runner KEY] [--run-id ID] [--results DIR] [--work DIR]
                      [--container [--env-file PATH]]
        bin/bench prepare <tool>/<case> --lane LANE --phase PHASE [--runner KEY] [--run-id ID] [--sha SHA --step N] [--github]
        bin/bench start <tool>/<case> --lane LANE
        bin/bench build <tool>/<case> --lane LANE
        bin/bench record <tool>/<case> --lane LANE --exit-status N
        bin/bench probe <tool>/<case> --lane LANE [--runner KEY] [--run-id ID]
        bin/bench label <runner>
        bin/bench matrix <project|tool/case> [--tool TOOL] [--lane LANES] [--runner KEYS] [--rolling | --cli TAG]
        bin/bench rolling-projects
        bin/bench image
        bin/bench report [--results DIR] [--out DIR]
    TEXT
    CLI_RELEASE = /\A(v\d+\.\d+\.\d+|vcli-canary-[0-9a-f]{9,40})\z/

    def initialize(argv, catalog: Catalog.new, out: $stdout)
      @argv = argv.dup
      @catalog = catalog
      @out = out
    end

    def call
      case @argv.shift
      when "check" then check
      when "list" then list
      when "run" then run
      when "prepare" then prepare
      when "start" then resumed { it.start; 0 }
      when "build" then resumed(&:build)
      when "record" then record
      when "probe" then probe
      when "label" then label
      when "matrix" then matrix
      when "report" then report
      when "rolling-projects" then rolling_projects
      when "image" then image
      else usage
      end
    rescue Error, OptionParser::ParseError => error
      warn "bench: #{error.message}"
      1
    end

    private
      def check
        problems = Check.new(@catalog).problems
        problems.each { @out.puts it }
        @out.puts "#{@catalog.tools.size} tools, #{@catalog.cases.size} cases: #{problems.empty? ? "ok" : "#{problems.size} problems"}"
        problems.empty? ? 0 : 1
      end

      def list
        @catalog.tools.each do |tool|
          @out.puts "#{tool.name}  levels: #{tool.levels.keys.join(", ")}  lanes: #{tool.lanes.map(&:name).join(", ")}"
          tool.cases.each do |kase|
            kase.runs.each { |lane, runners| @out.puts "  #{kase.id}  #{lane}  #{Array(runners).join(", ")}" }
          end
        end
        0
      end

      def run
        options = parse(defaults)
        kase, lane = case_and_lane(options)
        return skip(kase, lane, options[:runner]) unless lane.allows?(options[:runner])

        phases = options[:phase] ? [options[:phase]] : PHASES
        return in_containers(kase, lane, phases, options) if options[:container]

        records = phases.filter_map { phase_run(kase, lane, it, options)&.call }
        records.each { summarize(kase, lane, it) }
        records.any? { failed?(it) } ? 1 : 0
      end

      def prepare
        options = parse(defaults)
        kase, lane = case_and_lane(options)
        phase_run = phase_run(kase, lane, options[:phase] || raise(Error, "prepare needs --phase"), options)
        phase_run&.prepare
        export_to_github(kase, lane, phase_run, continues: options[:continues]) if options[:github]
        0
      end

      def record
        options = parse(defaults)
        exit_status = Integer(options[:exit_status] || raise(Error, "record needs --exit-status"))
        kase, lane = case_and_lane(options)
        record = PhaseRun.resume(kase, lane, work_root: options[:work], results_dir: options[:results]).record(exit_status)
        summarize(kase, lane, record)
        return 0 unless failed?(record)

        @out.puts "::error title=#{kase.id} #{lane.name} #{record["phase"]}::exit_status=#{record["exit_status"]} output_ok=#{record["output_ok"].inspect}" if ENV["GITHUB_ACTIONS"] == "true"
        1
      end

      def failed?(record)
        record["exit_status"].nonzero? || record["output_ok"] == false
      end

      def probe
        options = parse(defaults)
        kase, lane = case_and_lane(options)
        phase_run(kase, lane, PHASES.first, options).probe
        @out.puts "#{kase.id} #{lane.name}: probe ok (#{lane.probe.size} checks)"
        0
      end

      def resumed
        options = parse(defaults)
        kase, lane = case_and_lane(options)
        yield PhaseRun.resume(kase, lane, work_root: options[:work], results_dir: options[:results])
      end

      def label
        @out.puts @catalog.runner_label(@argv.first)
        0
      end

      def matrix
        options = parse(defaults.except(:runner))
        raise Error, "--cli takes a CLI release tag such as v1.41.0 or vcli-canary-<sha>" if options[:cli] && !options[:cli].match?(CLI_RELEASE)
        raise Error, "rolling keeps the pinned CLI; use --cli with fresh runs" if options[:cli] && options[:rolling]
        raise Error, "--step re-runs a recorded rolling step; add --rolling" if options[:step] && !options[:rolling]

        rerun = Integer(options[:step]) if options[:step]
        cases = @catalog.project_cases(@argv.first || raise(Error, "matrix needs <project> or <tool>/<case>"), tool: options[:tool])
        entries = cases.flat_map do |kase|
          rolling = Rolling.new(kase, results_dir: options[:results], work_root: options[:work]) if options[:rolling]
          position = rolling ? (rerun ? rolling.recorded_step(rerun) || raise(Error, "#{kase.id} has no rolling step #{rerun}") : rolling.next_step) : []
          next [] if rolling && position.nil?

          step, sha = position
          kase.runs.flat_map do |lane_name, runners|
            lane = kase.tool.lane(lane_name)
            Array(runners).reject { it == "local" || (rerun && rolling.passed?(lane, it, rerun)) }.map do |runner|
              { "case" => kase.id, "lane" => lane.name, "runner" => runner, "runs_on" => @catalog.runner_label(runner), "secrets" => lane.secrets, "setup" => lane.setup.join(" "),
                "label" => [(kase.name unless kase.name == kase.project), lane.machine || @catalog.runner_machine(runner), (lane.label unless lane.machine)].compact.join(" · "),
                "step" => step&.to_s || "", "sha" => sha || "", "cache_scope" => rolling&.cache_scope(lane, runner) || "", "continues" => rolling&.continues?(lane, runner) ? "true" : "" }
            end
          end
        end
        lanes = options[:lane]&.split(/[\s,]+/)
        runners = options[:runner]&.split(/[\s,]+/)
        @out.puts JSON.generate(entries.select { (lanes.nil? || lanes.include?(it["lane"])) && (runners.nil? || runners.include?(it["runner"])) })
        0
      end

      def phase_run(kase, lane, phase, options)
        common = { phase:, runner: options[:runner], work_root: options[:work], results_dir: options[:results] }
        return PhaseRun.new(kase, lane, scope: "#{lane.name}-#{options[:runner]}-#{options[:run_id]}", **common) unless phase == ROLLING

        rolling = Rolling.new(kase, results_dir: options[:results], work_root: options[:work])
        step, sha = options[:sha] ? [Integer(options[:step]), options[:sha]] : rolling.next_step
        cache_scope = options[:cache_scope] || rolling.cache_scope(lane, options[:runner])
        newer = options[:recorded] && Rolling.new(kase, results_dir: options[:recorded], work_root: options[:work]).last_step(lane, options[:runner])
        if sha && newer && newer > step
          @out.puts "#{kase.id} #{lane.name} rolling: step #{newer} is already recorded, so step #{step} is not rebuilt"
          return nil
        end
        return PhaseRun.new(kase, lane, scope: Rolling.scope(lane, options[:runner], kase.rolling_series), cache_scope:, sha:, step:, **common) if sha

        @out.puts "#{kase.id} #{lane.name} rolling: no upstream commit after the last step"
        nil
      end

      def export_to_github(kase, lane, phase_run, continues: false)
        outputs = { "ready" => (!phase_run.nil?).to_s }
        if phase_run
          base_key = "#{kase.id.tr("/", "-")}-#{phase_run.cache_scope}"
          restore_keys = phase_run.phase != ROLLING ? [base_key] : (continues ? ["#{base_key}-"] : [])
          outputs.merge!("tool" => kase.tool.name, "provider" => lane.provider, "build_dir" => phase_run.build_dir,
                         "restore_key" => restore_keys.join("\n"), "cache_key" => [base_key, phase_run.step].compact.join("-"),
                         "cache_paths" => phase_run.cache_paths.join("\n"), "cache_dance_map" => JSON.generate(lane.setup.include?("cache-dance") ? phase_run.cache_dance_map(File.join(ENV.fetch("RUNNER_TEMP", "/tmp"), "cache-dance")) : {}), "setup" => lane.setup.join(" "), "boringcache_version" => @catalog.versions.fetch("boringcache"))
          File.open(ENV.fetch("GITHUB_ENV"), "a") { |file| phase_run.exported_env.each { |key, value| file.puts "#{key}=#{value}" } }
        end
        File.open(ENV.fetch("GITHUB_OUTPUT"), "a") { |file| outputs.each { |key, value| file.puts "#{key}<<BENCH_EOF\n#{value}\nBENCH_EOF" } }
      end

      def in_containers(kase, lane, phases, options)
        container = Container.new(@catalog, env_file: options[:env_file])
        phases.all? do |phase|
          container.bench("run", kase.id, "--lane", lane.name, "--phase", phase, "--run-id", options[:run_id],
                          "--work", "/work", "--results", "/bench/tmp/results", docker: kase.tool.name == "docker")
        end ? 0 : 1
      end

      def rolling_projects
        @catalog.rolling.each { |tool, project| @out.puts "#{tool.title}\t#{project}" }
        0
      end

      def image
        Container.new(@catalog, env_file: "").build ? 0 : 1
      end

      def report
        options = parse(results: File.join(@catalog.root, "results"), out: File.join(@catalog.root, "data"))
        runs = @catalog.cases.flat_map { |kase| kase.runs.flat_map { |lane, runners| Array(runners).map { "#{kase.id} #{lane} #{it}" } } }
        Report.new(options[:results], runs:).write(options[:out])
        @out.puts "wrote #{File.join(options[:out], "results.json")} and report.md"
        0
      end

      def defaults
        { runner: ENV.fetch("BENCH_RUNNER", "local"), run_id: ENV.fetch("GITHUB_RUN_ID") { Time.now.utc.strftime("%Y%m%d%H%M%S") },
          work: ENV.fetch("BENCH_WORK") { File.join(@catalog.root, ".work") }, results: ENV.fetch("BENCH_RESULTS") { File.join(@catalog.root, "tmp", "results") }, env_file: File.join(@catalog.root, ".env") }
      end

      def parse(defaults)
        defaults.tap do |options|
          OptionParser.new do |opts|
            opts.on("--lane NAME") { options[:lane] = it }
            opts.on("--tool NAME") { options[:tool] = it }
            opts.on("--phase PHASE", [*PHASES, ROLLING]) { options[:phase] = it }
            opts.on("--runner KEY") { options[:runner] = it }
            opts.on("--run-id ID") { options[:run_id] = it }
            opts.on("--results DIR") { options[:results] = File.expand_path(it) }
            opts.on("--work DIR") { options[:work] = File.expand_path(it) }
            opts.on("--out DIR") { options[:out] = File.expand_path(it) }
            opts.on("--container") { options[:container] = true }
            opts.on("--env-file PATH") { options[:env_file] = File.expand_path(it) }
            opts.on("--exit-status N") { options[:exit_status] = it }
            opts.on("--github") { options[:github] = true }
            opts.on("--rolling") { options[:rolling] = true }
            opts.on("--sha SHA") { options[:sha] = it }
            opts.on("--step N") { options[:step] = it }
            opts.on("--cache-scope SCOPE") { options[:cache_scope] = it }
            opts.on("--cli TAG") { options[:cli] = it }
            opts.on("--continues") { options[:continues] = true }
            opts.on("--recorded DIR") { options[:recorded] = File.expand_path(it) }
          end.parse!(@argv)
        end
      end

      def case_and_lane(options)
        kase = @catalog.find_case(@argv.first || raise(Error, "needs <tool>/<case>"))
        [kase, kase.tool.lane(options[:lane] || raise(Error, "needs --lane"))]
      end

      def summarize(kase, lane, record)
        @out.puts "#{kase.id} #{lane.name} #{[record["phase"], record["step"]].compact.join(" ")}: " \
                  "#{record["seconds"]}s exit=#{record["exit_status"]} output_ok=#{record["output_ok"].inspect} " \
                  "machine=#{record["machine"].inspect} cpu=#{record.dig("observed", "machine", "cpu").inspect}"
      end

      def skip(kase, lane, runner)
        @out.puts "skip #{kase.id} #{lane.name} on #{runner}: #{lane.actions_only? ? "needs GitHub Actions" : "not a runner this lane allows"}"
        0
      end

      def usage
        @out.puts USAGE
        1
      end
  end
end
