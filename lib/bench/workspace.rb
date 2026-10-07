module Bench
  class Workspace
    attr_reader :kase, :lane, :scope, :dir

    def self.scope_plan(plan, scope)
      plan.values_at("adapters", "entries").compact.flat_map(&:values).grep(Hash).each do |table|
        table["tag"] = "#{table["tag"]}-#{scope}" if table["tag"]
        table["tool-cache"] = table["tool-cache"].map { it.include?(":") ? "#{it}-#{scope}" : it } if table["tool-cache"]
      end
      plan
    end

    def initialize(kase, lane:, scope:, root:)
      @kase = kase
      @lane = lane
      @scope = scope
      @dir = File.join(root, kase.tool.name, kase.name, lane.name)
    end

    def prepare(sha)
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)
      write_plan
      copy_overlay
      checkout(sha)
    end

    def plan_path
      File.join(dir, ".boringcache.toml")
    end

    def upstream_dir
      File.join(dir, "upstream")
    end

    private
      def write_plan
        File.write(plan_path, TomlRB.dump(self.class.scope_plan(TomlRB.load_file(kase.plan_path(lane)), scope)))
      end

      def copy_overlay
        FileUtils.cp_r(kase.overlay_dir, dir) if Dir.exist?(kase.overlay_dir)
        FileUtils.cp(kase.mise_path, dir) if File.exist?(kase.mise_path)
      end

      def checkout(sha)
        FileUtils.mkdir_p(upstream_dir)
        [%w[init --quiet], ["remote", "add", "origin", kase.clone_url], ["fetch", "--quiet", "--depth", "1", "origin", sha],
         %w[checkout --quiet --detach FETCH_HEAD]].each { Bench.git(*it, chdir: upstream_dir) }
      end
  end
end
