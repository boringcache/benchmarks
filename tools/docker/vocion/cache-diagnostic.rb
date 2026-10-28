require "digest"
require "etc"
require "fileutils"
require "json"
require "open3"
require "time"

class VocionCacheDiagnostic
  CACHE = "/app/packages/core/.next/cache"
  SEED_SHA = "dbada6a11fcaaf934123fd99feb8c8c1a6e46d23"
  TARGET_SHA = "cdd2ebf260d16192bf29b838f3f037eb6faaefb3"
  BUILD_MOUNT = "--mount=type=cache,id=vocion-core-next-build-cache,sharing=locked,target=#{CACHE}"
  ENVIRONMENT = {
    "NEXT_PUBLIC_APP_URL" => "https://example.com",
    "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY" => "pk_test_Y2xlcmsuYWNjb3VudHMuZGV2JA",
    "NEXT_PUBLIC_LANGFUSE_BASE_URL" => "http://localhost:3200",
    "NEXT_PUBLIC_LANGFUSE_PROJECT_ID" => "demo"
  }.freeze

  def self.recipe(source)
    instructions = source.gsub(/\\\n/, " ").lines
    builds = instructions.select { |line| line.start_with?("RUN #{BUILD_MOUNT} ") }
    raise "Expected one Vocion cache build instruction" unless builds.size == 1
    command = builds.first.delete_prefix("RUN #{BUILD_MOUNT} ").strip
    raise "Vocion staged build command changed" unless command.match?(/npm run build:next:staged\s+&& npm run docs:index\z/)
    prefix = source.split("RUN #{BUILD_MOUNT}", 2).first
    raise "Vocion builder stage changed" unless prefix.scan(/^FROM .* AS builder$/).size == 1
    [prefix, command]
  end

  def initialize(root)
    @root = File.expand_path(root)
    raise "Diagnostic directory already exists: #{@root}" if File.exist?(@root)
    @results = File.join(@root, "results")
    @seed = File.join(@root, "seed-cache")
    @commands = {}
    @images = {}
    FileUtils.mkdir_p([@results, @seed])
  end

  def run
    @machine = {
      "cpu" => File.read("/proc/cpuinfo")[/^model name\s*:\s*(.+)$/, 1],
      "cores" => Etc.nprocessors,
      "memory" => File.read("/proc/meminfo"),
      "kernel" => capture("uname", "-a"),
      "docker" => capture("docker", "version"),
      "runner_image" => ENV["ImageVersion"]
    }
    prepare(SEED_SHA)
    raise "Seed build failed" unless trial("seed", SEED_SHA, storage: "disk", restored: false, seed: true)
    raise "Seed cache is empty" unless Dir.glob(File.join(@seed, "**", "*"), File::FNM_DOTMATCH).any? { File.file?(it) }
    prepare(TARGET_SHA)
    trials = [
      ["identical-restored-disk", SEED_SHA, "disk", true, true],
      ["changed-empty-disk", TARGET_SHA, "disk", false, true],
      ["changed-restored-disk", TARGET_SHA, "disk", true, true],
      ["changed-restored-tmpfs", TARGET_SHA, "tmpfs", true, true],
      ["changed-cache-disabled", TARGET_SHA, "disk", false, false]
    ]
    trials.reverse! if ENV["TRIAL_ORDER"] == "reverse"
    outcomes = trials.map do |name, sha, storage, restored, enabled|
      trial(name, sha, storage: storage, restored: restored, enabled: enabled)
    end
    outcomes.all? ? 0 : 1
  end

  private
    def prepare(sha)
      directory = File.join(@root, sha)
      upstream = File.join(directory, "upstream")
      FileUtils.mkdir_p(File.join(directory, "overlay"))
      capture("git", "init", upstream)
      capture("git", "-C", upstream, "fetch", "--depth=1", "https://github.com/vocion/vocion-core.git", sha)
      capture("git", "-C", upstream, "checkout", "--detach", "FETCH_HEAD")
      raise "Unexpected source revision" unless capture("git", "-C", upstream, "rev-parse", "HEAD").strip == sha
      capture(RbConfig.ruby, File.expand_path("overlay/prepare.rb", __dir__), chdir: directory)
      source = File.read(File.join(directory, "overlay/Dockerfile"))
      prefix, @commands[sha] = self.class.recipe(source)
      File.write(File.join(@results, "#{sha}.Dockerfile"), source)
      dockerfile = File.join(@results, "#{sha}.input.Dockerfile")
      File.write(dockerfile, prefix)
      File.write(File.join(@results, "#{sha}.build.sh"), @commands.fetch(sha) + "\n")
      @images[sha] = "vocion-cache-diagnostic:#{sha}"
      status = logged("#{sha}-prepare", "docker", "buildx", "build", "--progress=plain", "--provenance=false", "--load",
        "--build-arg", "NEXT_PUBLIC_APP_URL=https://example.com", "--target", "builder", "-f", dockerfile,
        "-t", @images.fetch(sha), upstream)
      raise "Input image preparation failed" unless status.zero?
    end

    def trial(name, sha, storage:, restored:, enabled: true, seed: false)
      cache = seed ? @seed : File.join(@root, "trial-cache")
      FileUtils.mkdir_p(cache)
      container = "vocion-cache-#{name}"
      args = ["docker", "run", "--detach", "--name", container, "--entrypoint", "sh"]
      args += ["--mount", "type=bind,src=#{@seed},dst=/seed,readonly"] if restored
      args += if storage == "tmpfs"
        ["--tmpfs", "#{CACHE}:rw,size=10g,mode=0755"]
      else
        ["--mount", "type=bind,src=#{cache},dst=#{CACHE}"]
      end
      ENVIRONMENT.merge("VOCION_BUILD_FS_CACHE" => enabled ? "1" : "0").each { |key, value| args += ["--env", "#{key}=#{value}"] }
      record = {
        "schema" => "vocion-cache-diagnostic-v1", "case" => "docker/vocion", "trial" => name,
        "sha" => sha, "cache_source_sha" => restored ? SEED_SHA : nil, "cache_storage" => storage,
        "filesystem_cache_enabled" => enabled, "sample_count" => 1, "trial_order" => ENV.fetch("TRIAL_ORDER", "forward"),
        "scope" => "staged Next.js build and docs index; image preparation, seed copy and output check excluded",
        "machine" => @machine, "harness_sha" => ENV["GITHUB_SHA"],
        "run_url" => "https://github.com/#{ENV['GITHUB_REPOSITORY']}/actions/runs/#{ENV['GITHUB_RUN_ID']}",
        "started_at" => Time.now.utc.iso8601, "command_sha256" => Digest::SHA256.hexdigest(@commands.fetch(sha)),
        "tmpfs_size_bytes" => storage == "tmpfs" ? 10 * 1024**3 : nil,
        "exit_status" => nil, "output_ok" => false
      }
      begin
        capture(*args, @images.fetch(sha), "-c", "exec tail -f /dev/null")
        started = clock
        capture("docker", "exec", container, "cp", "-a", "/seed/.", "#{CACHE}/") if restored
        record["seed_copy_seconds"] = clock - started
        record["cache_before_kib"] = cache_size(container)
        record["versions"] = capture("docker", "exec", container, "sh", "-c", "node --version && npm --version && node -p 'require(\"next/package.json\").version'")
        record["image_id"] = capture("docker", "image", "inspect", "--format", "{{.Id}}", @images.fetch(sha)).strip
        record["mounts"] = capture("docker", "exec", container, "cat", "/proc/mounts")
        record["host_before"] = host_snapshot
        started = clock
        record["exit_status"] = sampled(name) { logged(name, "docker", "exec", container, "sh", "-c", @commands.fetch(sha)) }
        record["seconds"] = clock - started
        record["host_after"] = host_snapshot
        before = record.fetch("host_before").fetch("vmstat").lines.to_h { it.split }
        after = record.fetch("host_after").fetch("vmstat").lines.to_h { it.split }
        record["host_vmstat_delta"] = %w[pswpin pswpout pgmajfault].to_h { |key| [key, after.fetch(key).to_i - before.fetch(key).to_i] }
        record["page_size_bytes"] = Etc.sysconf(Etc::SC_PAGESIZE)
        record["container_resources"] = capture("docker", "exec", container, "sh", "-c",
          "for file in memory.peak memory.events memory.swap.current cpu.stat io.stat; do echo \"$file\"; cat \"/sys/fs/cgroup/$file\"; done")
        record["cache_after_kib"] = cache_size(container)
        _, status = Open3.capture2e("docker", "exec", container, "sh", "-c",
          "test -s .next/standalone/packages/core/server.js && test -d .next/static")
        record["output_ok"] = record["exit_status"].zero? && status.success?
        record["compilation"] = File.read(File.join(@results, "#{name}.log")).lines.grep(/Compiled successfully/).map(&:strip)
      rescue StandardError => error
        record["error"] = error.message
      ensure
        File.write(File.join(@results, "#{name}.json"), JSON.pretty_generate(record) + "\n")
        puts JSON.generate(record.slice("trial", "seconds", "exit_status", "output_ok", "compilation", "error"))
        system("docker", "rm", "--force", container, out: File::NULL, err: File::NULL)
        capture("sudo", "rm", "-rf", "--", cache) unless seed
      end
      record["exit_status"] == 0 && record["output_ok"]
    end

    def cache_size(container)
      capture("docker", "exec", container, "du", "-sk", CACHE).split.first.to_i
    end

    def host_snapshot
      %w[stat vmstat meminfo diskstats pressure/cpu pressure/io pressure/memory].to_h do |path|
        [path, File.read("/proc/#{path}")]
      end
    end

    def sampled(name)
      sampler = File.expand_path("../../../scripts/build-sampler.sh", __dir__)
      pid = Process.spawn("bash", sampler, File.join(@results, "#{name}-resources.log"), "5", pgroup: true)
      yield
    ensure
      if pid
        Process.kill("TERM", -pid) rescue Errno::ESRCH
        Process.wait(pid)
      end
    end

    def capture(*args, **options)
      output, status = Open3.capture2e(*args, **options)
      raise "#{args.first} failed (#{status.exitstatus}): #{output}" unless status.success?
      output
    end

    def logged(name, *args)
      puts "Starting #{name}"
      File.open(File.join(@results, "#{name}.log"), "w") do |log|
        Open3.popen2e(*args) do |input, output, wait|
          input.close
          output.each_line { |line| log.write(line); log.flush; $stdout.write(line) }
          wait.value.exitstatus || 1
        end
      end
    end

    def clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
end

exit VocionCacheDiagnostic.new(ARGV.fetch(0)).run if $PROGRAM_NAME == __FILE__
