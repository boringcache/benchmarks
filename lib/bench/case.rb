module Bench
  class Case
    attr_reader :tool, :dir

    def initialize(tool, dir)
      @tool = tool
      @dir = dir
    end

    def name
      File.basename(dir)
    end

    def id
      "#{tool.name}/#{name}"
    end

    def repo
      config["repo"]
    end

    def branch
      config["branch"]
    end

    def start_sha
      config["start_sha"]
    end

    def prepare
      config.fetch("prepare", [])
    end

    def check
      config.fetch("check", "")
    end

    def runs
      config.fetch("runs", {})
    end

    def directory
      config.fetch("directory", ".")
    end

    def env(source)
      Bench.interpolate(config.fetch("env", {}), source)
    end

    def mise_path
      File.join(dir, "mise.toml")
    end

    def plan_path(lane)
      File.join(dir, lane.plan_dir, ".boringcache.toml")
    end

    def overlay_dir
      File.join(dir, "overlay")
    end

    def clone_url
      repo.include?("://") || repo.start_with?("/") ? repo : "https://github.com/#{repo}.git"
    end

    private
      def config
        @config ||= TomlRB.load_file(File.join(dir, "case.toml"))
      end
  end
end
