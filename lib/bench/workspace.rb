module Bench
  class Workspace
    attr_reader :kase, :scope, :dir

    def self.scope_plan(plan, scope)
      plan.values_at("adapters", "entries").compact.flat_map(&:values).each do |table|
        table["tag"] = "#{table["tag"]}-#{scope}" if table.is_a?(Hash) && table["tag"]
      end
      plan
    end

    def initialize(kase, scope:, phase:, root:)
      @kase = kase
      @scope = scope
      @dir = File.join(root, kase.tool.name, kase.name, scope, phase)
    end

    def prepare(sha)
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)
      write_plans
      copy_overlay
      checkout(sha)
    end

    def plan_dir(lane)
      File.join(dir, lane.plan_dir)
    end

    def upstream_dir
      File.join(dir, "upstream")
    end

    private
      def write_plans
        Dir.glob("**/.boringcache.toml", File::FNM_DOTMATCH, base: kase.dir).each do |relative|
          target = File.join(dir, relative)
          FileUtils.mkdir_p(File.dirname(target))
          File.write(target, TomlRB.dump(self.class.scope_plan(TomlRB.load_file(File.join(kase.dir, relative)), scope)))
        end
      end

      def copy_overlay
        FileUtils.cp_r(kase.overlay_dir, dir) if Dir.exist?(kase.overlay_dir)
      end

      def checkout(sha)
        FileUtils.mkdir_p(upstream_dir)
        git "init", "--quiet"
        git "remote", "add", "origin", kase.clone_url
        git "fetch", "--quiet", "--depth", "1", "origin", sha
        git "checkout", "--quiet", "--detach", "FETCH_HEAD"
      end

      def git(*args)
        output, status = Open3.capture2e("git", *args, chdir: upstream_dir)
        raise Error, "git #{args.first} failed for #{kase.id}: #{output.strip}" unless status.success?
      end
  end
end
