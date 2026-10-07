module Bench
  class CLI
    USAGE = <<~TEXT
      Usage:
        bin/bench check
        bin/bench list
        bin/bench run <tool>/<case> --lane LANE [--phase cold|warm] [--runner KEY] [--run-id ID] [--results DIR] [--work DIR]
                      [--container [--env-file PATH]]
        bin/bench image
        bin/bench report [--results DIR] [--out DIR]
    TEXT

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
      when "report" then report
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
        options = parse(runner: ENV.fetch("BENCH_RUNNER", "local"), run_id: default_run_id, work: File.join(@catalog.root, ".work"),
                        results: File.join(@catalog.root, "tmp", "results"), env_file: File.join(@catalog.root, ".env"))
        kase = @catalog.find_case(@argv.first || raise(Error, "run needs <tool>/<case>"))
        lane = kase.tool.lane(options[:lane] || raise(Error, "run needs --lane"))
        return skip(kase, lane, options[:runner]) unless lane.allows?(options[:runner])

        phases = options[:phase] ? [options[:phase]] : PHASES
        return in_containers(kase, lane, phases, options) if options[:container]

        records = phases.map do |phase|
          PhaseRun.new(kase, lane, phase:, runner: options[:runner], scope: "#{lane.name}-#{options[:runner]}-#{options[:run_id]}",
                                   work_root: options[:work], results_dir: options[:results]).call
        end
        records.each { @out.puts "#{kase.id} #{lane.name} #{it["phase"]}: #{it["seconds"]}s exit=#{it["exit_status"]} output_ok=#{it["output_ok"].inspect}" }
        records.all? { it["exit_status"].zero? } ? 0 : 1
      end

      def in_containers(kase, lane, phases, options)
        container = Container.new(@catalog, env_file: options[:env_file])
        phases.all? do |phase|
          container.bench("run", kase.id, "--lane", lane.name, "--phase", phase, "--run-id", options[:run_id],
                          "--work", "/work", "--results", "/bench/tmp/results")
        end ? 0 : 1
      end

      def image
        Container.new(@catalog, env_file: "").build ? 0 : 1
      end

      def report
        options = parse(results: File.join(@catalog.root, "results"), out: File.join(@catalog.root, "data"))
        Report.new(options[:results]).write(options[:out])
        @out.puts "wrote #{File.join(options[:out], "results.json")} and report.md"
        0
      end

      def parse(defaults)
        defaults.tap do |options|
          OptionParser.new do |opts|
            opts.on("--lane NAME") { options[:lane] = it }
            opts.on("--phase PHASE", PHASES) { options[:phase] = it }
            opts.on("--runner KEY") { options[:runner] = it }
            opts.on("--run-id ID") { options[:run_id] = it }
            opts.on("--results DIR") { options[:results] = File.expand_path(it) }
            opts.on("--work DIR") { options[:work] = File.expand_path(it) }
            opts.on("--out DIR") { options[:out] = File.expand_path(it) }
            opts.on("--container") { options[:container] = true }
            opts.on("--env-file PATH") { options[:env_file] = File.expand_path(it) }
          end.parse!(@argv)
        end
      end

      def skip(kase, lane, runner)
        @out.puts "skip #{kase.id} #{lane.name} on #{runner}: #{lane.actions_only? ? "needs GitHub Actions" : "not a runner this lane allows"}"
        0
      end

      def usage
        @out.puts USAGE
        1
      end

      def default_run_id
        return "#{ENV["GITHUB_RUN_ID"]}-#{ENV.fetch("GITHUB_RUN_ATTEMPT", "1")}" if ENV["GITHUB_RUN_ID"]

        "local-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
      end
  end
end
