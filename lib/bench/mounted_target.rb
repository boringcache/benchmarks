module Bench
  class MountedTarget
    LANE = "boringcache-cargo-plus-mounted"
    BUDGET = { "nushell" => "3GiB", "zed" => "6GiB", "ferrum-fuzz" => "12GiB", "codex" => "24GiB" }.freeze
    READY = "benchmark-target-mounted"
    HOLD = 'mountpoint -q -- "$1" && echo benchmark-target-mounted && read -r decision && { [ "$decision" = publish ] || exit 75; }'

    def self.remove_archive(plan)
      targets = plan.fetch("entries").select { |_, entry| entry["kind"] == "cargo-target" }.keys
      raise Error, "Mounted Cargo requires one target entry" unless targets.size == 1

      plan.fetch("entries").delete(targets.first)
      plan.fetch("profiles").each_value { |profile| profile.fetch("entries").delete(targets.first) }
      plan
    end

    def initialize(kase, workspace, scope, phase)
      @budget = BUDGET.fetch(kase.name)
      @mount = File.join(workspace.upstream_dir, "target")
      @tag = "mounted-#{kase.name}-#{scope}"
      @phase = phase
      @receipt = File.join(ENV.fetch("RUNNER_TEMP"), "diagnostics", "archive-mount.json")
    end

    def run
      raise Error, "Select a candidate artifact for a branch series" unless ENV["BENCH_BRANCH_SERIES"] == "true" && ENV["CANDIDATE_CLI_ARTIFACT"].to_s.match?(/\Aart_[0-9a-f]{24}\z/)
      return false unless @phase == "cold" || system("boringcache", "check", "boringcache/benchmarks", @tag, "--no-platform", "--no-git", "--fail-on-miss")

      FileUtils.mkdir_p([@mount, File.dirname(@receipt)])
      raise Error, "Cargo target already contains files before mounting" unless Dir.empty?(@mount)

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
      entry.fetch("error_count").to_i.zero? && (@phase == "cold" ? mount["initial_root"].nil? : !mount["initial_root"].nil?) &&
        (@phase == "warm" ? mount["initial_root"] == mount["final_root"] : !mount["final_root"].nil?)
    end

    private
      def save_digest
        library = Dir.glob(File.join(@mount, "**", "deps", "*.rlib")).find { |path| File.file?(path) && File.size(path).between?(1, 2 * 1024 * 1024) }
        raise Error, "The mounted target has no compiled library for verification" unless library

        File.write(File.join(File.dirname(@receipt), "archive-library.sha256"), "#{Digest::SHA256.file(library).hexdigest}  #{library}\n")
      end
  end
end
