module Bench
  class Upstream
    def initialize(kase, root:)
      @kase = kase
      @dir = File.join(root, "history", kase.tool.name, kase.name)
    end

    def next_commit(after)
      init unless File.exist?(File.join(@dir, "HEAD"))
      Bench.git("fetch", "--quiet", "--filter=tree:0", "origin", @kase.branch, chdir: @dir)
      Bench.git("rev-list", "--first-parent", "--reverse", "#{after}..FETCH_HEAD", chdir: @dir).lines.first&.strip
    end

    private
      def init
        FileUtils.mkdir_p(@dir)
        Bench.git("init", "--quiet", "--bare", chdir: @dir)
        Bench.git("remote", "add", "origin", @kase.clone_url, chdir: @dir)
      end
  end
end
