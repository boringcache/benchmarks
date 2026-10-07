module Bench
  class Lane
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

    def allowed_runners
      config["runners"]
    end

    def allows?(runner)
      return false if runner == "local" && actions_only?

      allowed_runners.nil? || allowed_runners.include?(runner)
    end

    def env(phase, source = ENV)
      config.fetch("env", {}).merge(config.dig(phase, "env") || {}).transform_values do |value|
        value.to_s.gsub(/\$\{?([A-Z0-9_]+)\}?/) { source.fetch(it[/[A-Z0-9_]+/], "") }
      end
    end

    private
      def config
        @config ||= TomlRB.load_file(path)
      end
  end
end
