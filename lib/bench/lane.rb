module Bench
  class Lane
    SETUPS = %w[buildx actions-runtime ghcr depot vercel namespace nix cachix nativelink bitrise kache mbx].freeze

    attr_reader :tool, :path

    def initialize(tool, path)
      @tool = tool
      @path = path
    end

    def name
      File.basename(path, ".toml")
    end

    def provider
      config["provider"]
    end

    def boringcache?
      provider == "boringcache"
    end

    def label
      boringcache? ? ["boringcache", ("plus" if level == "plus")].compact.join(" ") : name
    end

    def level
      config["level"]
    end

    def capabilities
      tool.levels.fetch(level, [])
    end

    def plan_dir
      config.fetch("plan", ".")
    end

    def actions_only?
      config.fetch("actions_only", false)
    end

    def paths
      config.fetch("paths", [])
    end

    def setup
      [*tool.setup, *Array(config["setup"])].uniq
    end

    def args(phase, source = ENV)
      (config.dig(phase, "args") || config.fetch("args", [])).map { Bench.expand(it, source) }
    end

    def program
      config["program"]
    end

    def replaces
      config.fetch("replaces", [])
    end

    def wrap(phase, source = ENV)
      (config.dig(phase, "wrap") || config.fetch("wrap", [])).map { Bench.expand(it, source) }
    end

    def prepare(phase)
      config.fetch("prepare", []) + (config.dig(phase, "prepare") || [])
    end

    def probe
      config.fetch("probe", [])
    end

    def finish(phase)
      config.fetch("finish", []) + (config.dig(phase, "finish") || [])
    end

    def secrets
      config.fetch("secrets", [])
    end

    def allowed_runners
      config["runners"]
    end

    def allows?(runner)
      return false if runner == "local" && actions_only?

      allowed_runners.nil? || allowed_runners.include?(runner)
    end

    def env(phase, source = ENV)
      Bench.interpolate(config.fetch("env", {}).merge(config.dig(phase, "env") || {}), source)
    end

    private
      def config
        @config ||= TomlRB.load_file(path)
      end
  end
end
