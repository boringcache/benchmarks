module Bench
  class Check
    SHA = /\A[0-9a-f]{40}\z/
    VERSION = /\A\d+\.\d+\.\d+\z/

    def initialize(catalog)
      @catalog = catalog
    end

    def problems
      runner_problems + version_problems + @catalog.tools.flat_map { tool_problems(it) }
    end

    private
      def runner_problems
        problems = @catalog.runners.reject { |_, runner| runner.is_a?(Hash) && runner["label"].to_s != "" }.keys.map { "runners.toml: #{it} needs a label" }
        @catalog.runners.key?("local") ? problems : problems << "runners.toml must define local"
      end

      def version_problems
        version = @catalog.versions["boringcache"].to_s
        version.match?(VERSION) ? [] : ["versions.toml: boringcache must be x.y.z, got #{version.inspect}"]
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
        problems + kase.runs.flat_map { |lane_name, runners| run_problems(kase, lane_name, Array(runners)) }
      end

      def run_problems(kase, lane_name, runners)
        lane = kase.tool.lanes.find { it.name == lane_name }
        return ["#{kase.id}: unknown lane #{lane_name}"] unless lane

        problems = runners.filter_map do |runner|
          if !@catalog.runners.key?(runner)
            "#{kase.id}: #{lane_name} uses unknown runner #{runner}"
          elsif !lane.allows?(runner)
            "#{kase.id}: #{lane_name} cannot run on #{runner}"
          end
        end
        return problems unless lane.boringcache?
        return problems << "#{kase.id}: #{lane_name} has no plan at #{File.join(lane.plan_dir, ".boringcache.toml")}" unless File.exist?(kase.plan_path(lane))

        problems + (kase.shared - kase.cached_paths(lane)).map { "#{kase.id}: #{lane_name} does not cache shared path #{it}" }
      end
  end
end
