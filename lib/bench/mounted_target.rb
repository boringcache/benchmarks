module Bench
  class MountedTarget
    LANE = "boringcache-cargo-plus-mounted"
    BAZEL_LANE = "boringcache-bazel-mounted"
    READY = "benchmark-target-mounted"
    HOLD = 'mountpoint -q -- "$1" && [ "$(findmnt -n -o SOURCE --mountpoint "$1")" = boringcache-archive ] && echo benchmark-target-mounted && read -r decision && { [ "$decision" = publish ] || exit 75; }'

    Check = Data.define(:env, :command, :dir) do
      def call
        system(env, "bash", "-c", command, chdir: dir, unsetenv_others: true)
      end

      def script
        exports = env.map { |key, value| "#{key}=#{Shellwords.escape(value)}" }.join(" ")
        "cd #{Shellwords.escape(dir)} && exec env -i #{exports} bash -c #{Shellwords.escape(command)}\n"
      end
    end

    def self.lane?(name)
      [LANE, BAZEL_LANE].include?(name)
    end

    def self.verify_seconds
      path = File.join(ENV.fetch("RUNNER_TEMP"), "diagnostics", "archive-verify-seconds")
      File.file?(path) ? Float(File.read(path)) : nil
    end

    def self.require_target_entry(plan)
      targets = plan.fetch("entries").select { |_, entry| entry["kind"] == "cargo-target" }.keys
      raise Error, "Mounted Cargo requires one target entry" unless targets.size == 1

      plan
    end

    def initialize(kase, workspace, scope, phase)
      @bazel = kase.tool.name == "bazel"
      @budget = @bazel ? "8GiB" : "auto"
      if kase.name == "zed"
        @budget = ENV["BENCH_ZED_MOUNT_BUDGET"] unless ENV["BENCH_ZED_MOUNT_BUDGET"].to_s.empty?
      end
      @workspace = workspace
      @tag = "mounted-#{kase.name}-#{scope}"
      @phase = phase
      @seed_root = ENV["BENCH_ZED_SEED_ROOT"].to_s
      run_id = ENV["GITHUB_RUN_ID"]
      if kase.name == "zed" && phase == "rolling" && run_id && !scope.end_with?("-#{run_id}") &&
          !@seed_root.match?(/\Asha256:[0-9a-f]{64}\z/)
        raise Error, "A rolling build from another Zed run requires its verified catalog root"
      end
      @receipt = File.join(ENV.fetch("RUNNER_TEMP"), "diagnostics", "archive-mount.json")
      @verify_seconds = 0.0
    end

    def run(check)
      branch = ENV["GITHUB_REF"].to_s
      raise Error, "Select a candidate artifact on a qualification branch" unless branch.start_with?("refs/heads/") && branch != "refs/heads/main" && ENV["CANDIDATE_CLI_ARTIFACT"].to_s.match?(/\Aart_[0-9a-f]{24}\z/)
      raise Error, "Mounted Cargo requires a branch series" unless @bazel || ENV["BENCH_BRANCH_SERIES"] == "true"
      return false unless @phase == "cold" || verifying { check_catalog }

      @mount = @bazel ? bazel_output_path : File.join(@workspace.upstream_dir, "target")
      FileUtils.mkdir_p([@mount, File.dirname(@receipt)])
      raise Error, "Output directory already contains files before mounting" unless Dir.empty?(@mount)
      File.write(File.join(File.dirname(@receipt), "archive-mountpoint"), @mount)
      puts "Mounting #{@mount} with writable spool budget #{@budget}"

      spool = Dir.mktmpdir("mounted-target-", ENV.fetch("RUNNER_TEMP"))
      budget_args = @budget == "auto" ? [] : ["--disk-budget", @budget]
      args = ["boringcache", "archive-mount", "boringcache/benchmarks", @tag, @mount, "--spool", spool,
              *budget_args, "--receipt", @receipt, "--", "sh", "-c", HOLD, "bench", @mount]
      passed = false
      status = Open3.popen2(*args) do |input, output, process|
        begin
          ready = output.each_line.any? { |line| line.chomp == READY }
          check_seed_usage if ready && !@seed_root.empty?
          passed = ready && yield && verifying do
            check.call && (@phase == "warm" || (save_digest && save_check(check))) &&
              (@seed_root.empty? || check_catalog)
          end
          input.puts(passed && @phase != "warm" ? "publish" : "discard") if ready
        ensure
          input.close
        end
        output.each_line { |line| $stdout.write(line) }
        process.value
      end
      File.write(File.join(File.dirname(@receipt), "archive-verify-seconds"), @verify_seconds.round(3).to_s)
      return false unless passed && status.exitstatus == (@phase == "warm" ? 75 : 0) && File.file?(@receipt)

      doc = JSON.parse(File.read(@receipt))
      entry = doc.fetch("entries").fetch(0)
      mount = entry.fetch("archive_mount")
      return false if @bazel && @phase == "cold" && mount.fetch("stats").fetch("peak_resident_bytes").zero?
      return false unless @seed_root.empty? || mount["initial_root"] == @seed_root

      entry.fetch("error_count").to_i.zero? && (@phase == "cold" ? mount["initial_root"].nil? : !mount["initial_root"].nil?) &&
        (@phase == "warm" ? mount["initial_root"] == mount["final_root"] : !mount["final_root"].nil?)
    end

    private
      def verifying
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        yield
      ensure
        @verify_seconds += Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
      end

      def save_check(check)
        File.write(File.join(File.dirname(@receipt), "archive-check.sh"), check.script) unless @bazel || check.command.empty?
        true
      end

      def check_seed_usage
        path = File.join(@mount, ".boringcache", "cargo-pruning-v1.json")
        record = JSON.parse(File.read(path)) if File.file?(path)
        return if record && record["version"] == 1 && record["complete"] && !record.fetch("groups").empty?

        raise Error, "The cold Zed mount has no complete Cargo pruning record"
      end

      def check_catalog
        args = ["boringcache", "check", "boringcache/benchmarks", @tag, "--no-platform", "--no-git", "--fail-on-miss"]
        return system(*args) if @seed_root.empty?

        output, status = Open3.capture2(*args, "--json")
        matches = status.success? && JSON.parse(output).fetch("results").any? do |entry|
          entry["tag"] == @tag && entry["manifest_root_digest"] == @seed_root
        end
        raise Error, "The mounted catalog no longer matches the verified cold run" unless matches

        true
      end

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
        pattern = @bazel ? "*/testlogs/**/test.log" : "**/*.rlib"
        matches = Dir.glob(pattern, base: @mount).map { |path| File.join(@mount, path) }
        output = matches.select { |path| File.lstat(path).file? && File.size(path).positive? }.min_by { |path| [File.size(path), path] }
        unless output
          raise Error, "The mounted output has no matching file for checksum verification (#{matches.size} paths match #{pattern})"
        end

        File.write(File.join(File.dirname(@receipt), "archive-library.sha256"), "#{Digest::SHA256.file(output).hexdigest}  #{output}\n")
        true
      end
  end
end
