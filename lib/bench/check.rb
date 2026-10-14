module Bench
  class Check
    SHA = /\A[0-9a-f]{40}\z/
    VERSION = /\A\d+\.\d+\.\d+\z/

    def initialize(catalog)
      @catalog = catalog
    end

    def problems
      runner_problems + version_problems + rolling_problems + @catalog.tools.flat_map { tool_problems(it) }
    end

    private
      def runner_problems
        problems = @catalog.runners.reject { |_, runner| runner.is_a?(Hash) && runner["label"].to_s != "" && runner["machine"].to_s != "" }.keys.map { "runners.toml: #{it} needs a label and a machine" }
        @catalog.runners.each do |name, runner|
          if runner.is_a?(Hash) && runner["label"] == "ubuntu-latest"
            problems << "runners.toml: #{name} must use an explicit Ubuntu version"
          end
        end
        @catalog.runners.key?("local") ? problems : problems << "runners.toml must define local"
      end

      def rolling_problems
        @catalog.rolling.filter_map do |tool, project|
          "rolling.toml: no #{tool.name} cases for project #{project.inspect}" unless tool.cases.any? { it.project.casecmp?(project) }
        end
      rescue Error => error
        ["rolling.toml: #{error.message}"]
      end

      def version_problems
        version = @catalog.versions["boringcache"].to_s
        problems = version.match?(VERSION) ? [] : ["versions.toml: boringcache must be x.y.z, got #{version.inspect}"]
        cases = @catalog.versions.fetch("cases", {})
        return problems << "versions.toml: [cases] must map case ids to CLI release tags" unless cases.is_a?(Hash)

        ids = @catalog.cases.map(&:id)
        problems + cases.flat_map do |id, tag|
          [("versions.toml: [cases] names unknown case #{id}" unless ids.include?(id)),
           ("versions.toml: #{id} must be a CLI release tag such as v1.41.0 or vcli-canary-<sha>" unless tag.to_s.match?(CLI::CLI_RELEASE))].compact
        end
      end

      def tool_problems(tool)
        problems = tool.levels.empty? ? ["#{tool.name}: tool.toml needs [levels]"] : []
        problems + tool.lanes.flat_map { lane_problems(it) } + tool.cases.flat_map { case_problems(it) }
      end

      def lane_problems(lane)
        where = "#{lane.tool.name}/lanes/#{lane.name}"
        problems = []
        problems << "#{where}: needs a provider" if lane.provider.to_s.empty?
        problems << "#{where}: level #{lane.level.inspect} is not in tool.toml" unless lane.tool.levels.key?(lane.level)
        problems += (lane.setup - Lane::SETUPS).map { "#{where}: unknown setup #{it}" }
        problems << "#{where}: program needs replaces" if lane.program && lane.replaces.empty?
        problems << "#{where}: post_job_save must list actions (owner/repo) or step ids" unless lane.post_job_save.is_a?(Array) && lane.post_job_save.all?(String)
        problems << "#{where}: experimental must be true or left out" unless [nil, true].include?(lane.experimental)
        problems << "#{where}: cli_args must be BoringCache CLI flags on a BoringCache lane" unless lane.cli_args.is_a?(Array) && lane.cli_args.all? { it.is_a?(String) && it.start_with?("--") } && (lane.cli_args.empty? || lane.boringcache?)
        problems << "#{where}: cache_keys must list key prefixes that name ${BENCH_SCOPE}" unless lane.cache_key_templates.is_a?(Array) && lane.cache_key_templates.all? { it.is_a?(String) && it.include?("${BENCH_SCOPE}") }
        problems + Array(lane.allowed_runners).reject { @catalog.runners.key?(it) }.map { "#{where}: unknown runner #{it}" }
      end

      def case_problems(kase)
        problems = []
        problems << "#{kase.id}: repo is required" if kase.repo.to_s.empty?
        problems << "#{kase.id}: branch is required" if kase.branch.to_s.empty?
        problems << "#{kase.id}: start_sha must be a full 40-character sha" unless kase.start_sha.to_s.match?(SHA)
        problems << "#{kase.id}: prepare must be a list of commands" unless kase.prepare.is_a?(Array)
        problems << "#{kase.id}: check must be a command" unless kase.check.is_a?(String)
        problems << "#{kase.id}: [runs] lists no lanes" if kase.runs.empty?
        problems << "#{kase.id}: exclude must be a list of paths" unless kase.exclude.is_a?(Array) && kase.exclude.all?(String)
        problems << "#{kase.id}: script must be a command list" unless kase.script.nil? || (kase.script.is_a?(Array) && kase.script.any? && kase.script.all?(String))
        problems << "#{kase.id}: rolling_stride must be an integer above 1" unless kase.rolling_stride.nil? || (kase.rolling_stride.is_a?(Integer) && kase.rolling_stride > 1)
        problems << "#{kase.id}: rolling_series must be an integer above 1" unless kase.rolling_series.nil? || (kase.rolling_series.is_a?(Integer) && kase.rolling_series > 1)
        problems + kase.runs.flat_map { |lane_name, runners| run_problems(kase, lane_name, Array(runners)) } + nightly_problems(kase)
      end

      def nightly_problems(kase)
        return ["#{kase.id}: [nightly] must map lanes to runner keys"] unless kase.nightly.is_a?(Hash)

        kase.nightly.flat_map do |lane_name, runners|
          Array(runners).reject { Array(kase.runs[lane_name]).include?(it) }.map { "#{kase.id}: nightly #{lane_name} on #{it} is not in [runs]" }
        end
      end

      def run_problems(kase, lane_name, runners)
        lane = kase.tool.lanes.find { it.name == lane_name }
        return ["#{kase.id}: unknown lane #{lane_name}"] unless lane

        return ["#{kase.id}: #{lane_name} replaces the plan command, which a script case does not run"] if kase.script && (lane.program || lane.phases?)

        problems = runners.filter_map do |runner|
          if !@catalog.runners.key?(runner)
            "#{kase.id}: #{lane_name} uses unknown runner #{runner}"
          elsif !lane.allows?(runner)
            "#{kase.id}: #{lane_name} cannot run on #{runner}"
          end
        end
        problems << "#{kase.id}: #{lane_name} mounts the Namespace cache volume without cache paths" if lane.setup.include?("namespace-cache") && lane.paths.empty? && kase.shared.empty?
        return problems unless lane.boringcache?
        return problems << "#{kase.id}: #{lane_name} has no plan at #{File.join(lane.plan_dir, ".boringcache.toml")}" unless File.exist?(kase.plan_path(lane))

        problems + (kase.shared - kase.cached_paths(lane)).map { "#{kase.id}: #{lane_name} does not cache shared path #{it}" }
      end
  end
end
