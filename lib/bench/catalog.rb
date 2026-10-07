module Bench
  class Catalog
    attr_reader :root

    def initialize(root = ROOT)
      @root = root
    end

    def runners
      @runners ||= read("runners.toml")
    end

    def runner_label(key)
      runners.dig(key, "label") or raise Error, "unknown runner #{key.inspect}"
    end

    def runner_env(key)
      runners.dig(key, "env") || {}
    end

    def versions
      @versions ||= read("versions.toml")
    end

    def tools
      @tools ||= Dir.glob(File.join(root, "tools", "*", "tool.toml")).sort.map { Tool.new(self, File.dirname(it)) }
    end

    def tool(name)
      tools.find { it.name == name } or raise Error, "unknown tool #{name.inspect}"
    end

    def cases
      tools.flat_map(&:cases)
    end

    def project_cases(name)
      return [find_case(name)] if name.to_s.include?("/")

      cases.select { it.project == name }.then { it.empty? ? raise(Error, "unknown project #{name.inspect}") : it }
    end

    def find_case(id)
      tool_name, case_name = id.to_s.split("/", 2)
      tool(tool_name).find_case(case_name)
    end

    private
      def read(name)
        path = File.join(root, name)
        File.exist?(path) ? TomlRB.load_file(path) : {}
      end
  end
end
