module Bench
  class Tool
    attr_reader :catalog, :dir

    def initialize(catalog, dir)
      @catalog = catalog
      @dir = dir
    end

    def name
      File.basename(dir)
    end

    def levels
      config.fetch("levels", {})
    end

    def lanes
      @lanes ||= Dir.glob(File.join(dir, "lanes", "*.toml")).sort.map { Lane.new(self, it) }
    end

    def lane(name)
      lanes.find { it.name == name } or raise Error, "#{self.name} has no lane #{name.inspect}"
    end

    def cases
      @cases ||= Dir.glob(File.join(dir, "*", "case.toml")).sort.map { Case.new(self, File.dirname(it)) }
    end

    def find_case(name)
      cases.find { it.name == name } or raise Error, "#{self.name} has no case #{name.inspect}"
    end

    private
      def config
        @config ||= TomlRB.load_file(File.join(dir, "tool.toml"))
      end
  end
end
