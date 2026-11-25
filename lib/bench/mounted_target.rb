module Bench
  class MountedTarget
    LANE = "boringcache-cargo-plus-mounted"
    BAZEL_LANE = "boringcache-bazel-mounted"
    BUDGET = { "nushell" => "3GiB", "nushell-path" => "128MiB", "zed" => "6GiB", "ferrum-fuzz" => "12GiB", "codex" => "24GiB" }.freeze
    READY = "benchmark-target-mounted"
    HOLD = 'mountpoint -q -- "$1" && [ "$(findmnt -n -o SOURCE --mountpoint "$1")" = boringcache-archive ] && echo benchmark-target-mounted && read -r decision && { [ "$decision" = publish ] || exit 75; }'

    def self.lane?(name)
      [LANE, BAZEL_LANE].include?(name)
    end

    def self.remove_archive(plan)
      targets = plan.fetch("entries").select { |_, entry| entry["kind"] == "cargo-target" }.keys
      raise Error, "Mounted Cargo requires one target entry" unless targets.size == 1

      plan.fetch("entries").delete(targets.first)
      plan.fetch("profiles").each_value { |profile| profile.fetch("entries").delete(targets.first) }
      plan
    end

    def initialize(kase, workspace, scope, phase)
      @bazel = kase.tool.name == "bazel"
      @budget = @bazel ? "8GiB" : BUDGET.fetch(kase.name)
      @workspace = workspace
      @tag = "mounted-#{kase.name}-#{scope}"
      @phase = phase
      @receipt = File.join(ENV.fetch("RUNNER_TEMP"), "diagnostics", "archive-mount.json")
    end

    def run
      branch = ENV["GITHUB_REF"].to_s
      raise Error, "Select a candidate artifact on a qualification branch" unless branch.start_with?("refs/heads/") && branch != "refs/heads/main" && ENV["CANDIDATE_CLI_ARTIFACT"].to_s.match?(/\Aart_[0-9a-f]{24}\z/)
      raise Error, "Mounted Cargo requires a branch series" unless @bazel || ENV["BENCH_BRANCH_SERIES"] == "true"
      return false unless @phase == "cold" || system("boringcache", "check", "boringcache/benchmarks", @tag, "--no-platform", "--no-git", "--fail-on-miss")

      @mount = @bazel ? bazel_output_path : File.join(@workspace.upstream_dir, "target")
      FileUtils.mkdir_p([@mount, File.dirname(@receipt)])
      raise Error, "Output directory already contains files before mounting" unless Dir.empty?(@mount)
      File.write(File.join(File.dirname(@receipt), "archive-mountpoint"), @mount)
      puts "Mounting #{@mount} with a #{@budget} writable-file budget"

      spool = Dir.mktmpdir("mounted-target-", ENV.fetch("RUNNER_TEMP"))
      args = ["boringcache", "archive-mount", "boringcache/benchmarks", @tag, @mount, "--spool", spool,
              "--disk-budget", @budget, "--receipt", @receipt, "--", "sh", "-c", HOLD, "bench", @mount]
      passed = false
      status = Open3.popen2(*args) do |input, output, process|
        begin
          ready = output.each_line.any? { |line| line.chomp == READY }
          passed = ready && yield
          save_digest if passed && @phase != "warm"
          input.puts(passed && @phase != "warm" ? "publish" : "discard") if ready
        ensure
          input.close
        end
        output.each_line { |line| $stdout.write(line) }
        process.value
      end
      return false unless passed && status.exitstatus == (@phase == "warm" ? 75 : 0) && File.file?(@receipt)

      doc = JSON.parse(File.read(@receipt))
      entry = doc.fetch("entries").fetch(0)
      mount = entry.fetch("archive_mount")
      return false if @bazel && @phase == "cold" && mount.fetch("stats").fetch("peak_resident_bytes").zero?

      entry.fetch("error_count").to_i.zero? && (@phase == "cold" ? mount["initial_root"].nil? : !mount["initial_root"].nil?) &&
        (@phase == "warm" ? mount["initial_root"] == mount["final_root"] : !mount["final_root"].nil?)
    end

    private
      def bazel_output_path
        env = ENV.to_h.slice("PATH", "HOME", "USER", "TMPDIR", "LANG")
        output, status = Open3.capture2(env, "../bazel", "--bazelrc=../bench.bazelrc", "info", "output_path",
                                        chdir: @workspace.upstream_dir, unsetenv_others: true)
        path = output.chomp
        unless status.success? && path.match?(%r{\A/[^\n]+/execroot/[^/\n]+/bazel-out\z})
          raise Error, "Bazel did not report its output directory"
        end
        path
      end

      def save_digest
        pattern = @bazel ? "*/testlogs/**/test.log" : "**/deps/*.rlib"
        output = Dir.glob(pattern, base: @mount).lazy.map { |path| File.join(@mount, path) }.find do |path|
          File.lstat(path).file? && File.size(path).between?(1, 2 * 1024 * 1024)
        end
        raise Error, "The mounted output has no matching file for checksum verification" unless output

        File.write(File.join(File.dirname(@receipt), "archive-library.sha256"), "#{Digest::SHA256.file(output).hexdigest}  #{output}\n")
      end
  end
end
