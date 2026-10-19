require "find"
require_relative "throughput"

class Deps
  KINDS = %w[seed update verify].freeze
  OPERATIONS = { "seed" => %w[install save], "update" => %w[restore install save], "verify" => %w[restore] }.freeze

  def self.plan(root = Throughput::ROOT)
    require "toml-rb"
    TomlRB.load_file(File.join(root, "deps", "plan.toml")).merge("machines" => TomlRB.load_file(File.join(root, "runners.toml")))
  end

  def initialize(plan, run_id:, step: 0, preflight: false, only: nil, runners: nil)
    raise ArgumentError, "run id must contain digits only" unless run_id.to_s.match?(/\A\d+\z/)
    raise ArgumentError, "unknown case #{only}" if only && !plan.fetch("cases").key?(only)

    @plan, @run_id, @step, @preflight, @only = plan, run_id.to_s, Integer(step), preflight, only
    @runners = runners || (@preflight ? @plan.fetch("runners").first(1) : @plan.fetch("runners"))
    raise ArgumentError, "unknown runner selection" if @runners.empty? || (@runners - @plan.fetch("machines").keys).any?
  end

  def jobs(kind)
    raise ArgumentError, "unknown kind #{kind}" unless KINDS.include?(kind)

    cases = @plan.fetch("cases").keys.select { @only.nil? || it == @only }
    jobs = cases.product(@plan.fetch("lanes"), @runners).map { |name, lane, runner| job(kind, name, lane, runner) }
    if kind == "verify" && @runners.include?("github")
      jobs += cases.product(@plan.fetch("lanes"), @runners - ["github"]).filter_map do |name, lane, runner|
        job(kind, name, lane, runner, producer: "github") if Throughput.possible?(@plan, lane, "github", runner)
      end
    end
    jobs
  end

  def job(kind, name, lane, runner, producer: runner)
    kase = @plan.fetch("cases").fetch(name)
    machine = @plan.fetch("machines").fetch(runner)
    before, after = kase.fetch("steps").fetch(@step)
    scope = "deps-#{@run_id}-#{name}-#{producer}"
    route = producer == runner ? runner : "#{producer}-to-#{runner}"
    { "name" => "#{kind}-#{name}-#{route}-#{lane}", "kind" => kind, "case" => name, "lane" => lane, "runner" => runner,
      "producer" => producer, "cache_backend" => lane == "boringcache" ? "boringcache" : Throughput.store(@plan, runner),
      "before_sha" => before, "after_sha" => after,
      "runs_on" => machine.fetch("label"), "machine" => machine.fetch("machine"), "run_id" => @run_id, "step" => @step,
      "repo" => kase.fetch("repo"), "sha" => kind == "seed" ? before : after, "tool" => kase.fetch("tool"), "ruby" => kase["ruby"].to_s,
      "lockfile" => kase.fetch("lockfile"), "path" => kase.fetch("path"), "apt" => kase.fetch("apt", []).join(" "),
      "setup" => kase.fetch("setup", []).join("\n"), "install" => kase.fetch("install"), "check" => kase.fetch("check"), "env" => kase.fetch("env", {}),
      "dir" => "bench-deps/#{name}", "key" => scope, "workspace" => @plan.fetch("workspace") }
  end

  def outputs
    KINDS.map { "#{it}=#{JSON.generate(jobs(it))}" }.join("\n")
  end
end

class DepsJob < ThroughputJob
  def self.local(plan, name:, step: 0, out: nil)
    deps = Deps.new(plan, run_id: Time.now.utc.strftime("%Y%m%d%H%M%S"), step:)
    root = File.join(Throughput::ROOT, ".work", "deps")
    out ||= File.join(root, "results")
    Deps::KINDS.map do |kind|
      job = deps.job(kind, name, "boringcache", "local").merge("dir" => File.join("run", name))
      work = File.join(root, job.fetch("name"))
      FileUtils.rm_rf(work)
      FileUtils.mkdir_p(work)
      Dir.chdir(work) do
        runner = new(job, dir: work, env: ENV.to_h.merge(runner_env(job)))
        ENV.update(runner.env)
        BUNDLER_ENV.each { ENV.delete(it) }
        runner.checkout
        ENV["PATH"] = [runner.toolchain, ENV.fetch("PATH")].compact.join(File::PATH_SEPARATOR)
        raise "setup failed" unless system("bash", "-ec", job.fetch("setup"), chdir: runner.upstream)
        runner.probe
        outcomes = {}
        if kind != "seed"
          runner.mark("restore_start")
          outcomes["restore"] = status(runner.boringcache("restore"))
          runner.mark("restore_end")
        end
        if kind == "verify"
          runner.measure
          outcomes["restore_check"] = status(runner.run_command("check"))
        else
          runner.mark("install_start")
          outcomes["install"] = status(runner.run_command("install"))
          runner.mark("install_end")
          runner.measure
          runner.mark("save_start")
          outcomes["save"] = status(runner.boringcache("save"))
          runner.mark("save_end")
          outcomes["lookup"] = status(runner.boringcache("lookup"))
        end
        runner.write(out, outcomes)
      end
    end.max
  end

  BUNDLER_ENV = %w[BUNDLE_GEMFILE BUNDLE_BIN_PATH BUNDLE_LOCKFILE BUNDLER_VERSION BUNDLER_SETUP RUBYOPT RUBYLIB].freeze

  def self.runner_env(job)
    dir = File.expand_path(job.fetch("dir"))
    job.fetch("env").transform_values { it.gsub("${DIR}", dir) }
  end

  attr_reader :env

  def operations
    Deps::OPERATIONS.fetch(@job.fetch("kind"))
  end

  def upstream
    File.join(@job.fetch("dir"), "upstream")
  end

  def checkout
    FileUtils.mkdir_p(upstream)
    url = "https://github.com/#{@job.fetch("repo")}.git"
    [%w[init --quiet], ["fetch", "--quiet", "--depth", "1", url, @job.fetch("sha")], %w[checkout --quiet --force FETCH_HEAD]].each do |args|
      raise "git #{args.first} failed" unless system("git", *args, chdir: upstream)
    end
    0
  end

  def toolchain
    version = case @job.fetch("tool")
    when "pnpm" then File.read(File.join(upstream, ".nvmrc")).strip.delete_prefix("v").then { "node@#{it}" } if File.exist?(File.join(upstream, ".nvmrc"))
    when "bundler" then "ruby@#{@job.fetch("ruby")}" unless @job.fetch("ruby").empty?
    end
    capture("mise", "where", version)&.strip&.then { File.join(it, "bin") } if version
  end

  def env_lines
    self.class.runner_env(@job).map { |key, value| "#{key}=#{value}\n" }.join
  end

  def keys
    digest = Digest::SHA256.file(File.join(upstream, @job.fetch("lockfile"))).hexdigest
    "key=#{@job.fetch("key")}-#{digest[0, 16]}\nrestore_key=#{@job.fetch("key")}-\n"
  end

  def run_command(name)
    system("bash", "-c", @job.fetch(name), chdir: upstream) ? 0 : 1
  end

  def measure
    bytes = files = 0
    Find.find(cache_path) do |entry|
      stat = File.lstat(entry)
      next unless stat.file?

      bytes += stat.size
      files += 1
    end
    File.write(path("cache"), "#{bytes} #{files}\n")
    0
  rescue Errno::ENOENT
    0
  end

  def record(outcomes)
    record = super
    bytes, files = File.read(path("cache")).split.map { Integer(it) } if File.exist?(path("cache"))
    record.merge("cache" => ({ "bytes" => bytes, "files" => files } if bytes),
                 "cache_restored_key" => @env["DEPS_RESTORED_KEY"], "harness_commit" => @env["GITHUB_SHA"]).compact
  end

  private
    def fields
      %w[name kind case tool repo sha before_sha after_sha lockfile lane runner machine producer cache_backend key run_id step]
    end

    def cache_path
      File.join(@job.fetch("dir"), @job.fetch("path"))
    end
end

class DepsReport
  COLUMNS = ["Lane", "Cache backend", "Runner", "Cache from", "Before", "After", "Source CPU", "Consumer CPU", "Version", "Samples", "Failed", "Restore before s", "Install s", "Save s", "Save network MB",
             "Restore after s", "Restore after network MB", "Cache MB", "Cache files"].freeze

  def initialize(results_dir)
    @results_dir = results_dir
  end

  def records
    @records ||= Dir.glob(File.join(@results_dir, "**", "*.json")).sort.map { JSON.parse(File.read(it)) }.reject { it["excluded"] }
  end

  def rows
    seeds = records.select { it["kind"] == "seed" }.to_h { [identity(it), it] }
    updates = records.select { it["kind"] == "update" }.to_h { [identity(it), it] }
    observations = records.select { it["kind"] == "verify" }.map do |verify|
      source = identity(verify, verify["producer"] || verify["runner"])
      seed, update = seeds[source], updates[source]
      [seed, update, verify]
    end
    verified = observations.to_h { [identity(it.last), true] }
    updates.each { |id, update| observations << [seeds[id], update, nil] unless verified.key?(id) }
    seeds.each { |id, seed| observations << [seed, nil, nil] unless updates.key?(id) || verified.key?(id) }
    groups = observations.group_by do |seed, update, verify|
      row = verify || update || seed
      [row["case"], row["lane"], row["machine"], row["producer"] || row["runner"], row["cache_backend"] || row["lane"],
       row["before_sha"] || seed&.dig("sha"), row["after_sha"] || update&.dig("sha"), update&.dig("observed", "cpu"), row.dig("observed", "cpu"), version(row)]
    end
    groups.sort_by { |key, _| key.map(&:to_s) }.map do |(kase, lane, machine, producer, backend, before, after, source_cpu, cpu, version), group|
      complete = group.select { |cycle| cycle.all? { it && it["exit_status"] == 0 && it["output_ok"] == true } }
      update = complete.map { it[1] }
      verify = complete.map { it[2] }
      { "case" => kase, "lane" => lane, "machine" => machine, "producer" => producer, "backend" => backend, "before" => before, "after" => after, "source_cpu" => source_cpu, "cpu" => cpu,
        "version" => version, "samples" => group.size, "failed" => group.size - complete.size,
        "restore_before" => seconds(update, "restore"), "install" => seconds(update, "install"), "save" => seconds(update, "save"),
        "save_network" => megabytes(update, "save"), "restore_after" => seconds(verify, "restore"), "restore_after_network" => megabytes(verify, "restore"),
        "cache_bytes" => median(verify.filter_map { it.dig("cache", "bytes") }), "cache_files" => median(verify.filter_map { it.dig("cache", "files") }) }
    end
  end

  def markdown
    lines = ["# Dependency cache update", ""]
    rows.group_by { it["case"] }.each do |kase, rows|
      body = rows.map do |row|
        [*row.values_at("lane", "backend", "machine", "producer"), row["before"]&.slice(0, 12), row["after"]&.slice(0, 12),
         *row.values_at("source_cpu", "cpu", "version", "samples", "failed", "restore_before", "install", "save", "save_network", "restore_after", "restore_after_network"),
         row["cache_bytes"] ? (row["cache_bytes"] / 1e6).round : nil, row["cache_files"]].map { it.nil? ? "-" : it }
      end
      lines += ["## #{kase}", "", line(COLUMNS), line(COLUMNS.map { "---" }), *body.map { line(it) }, ""]
    end
    lines.join("\n")
  end

  private
    def identity(record, runner = record["runner"])
      [record["run_id"], record["case"], record["lane"], runner, record["step"], record["attempt"]]
    end

    def version(record)
      record.dig("versions", "boringcache") || record.dig("versions", "actions_cache")
    end

    def seconds(records, name)
      median(records.filter_map { it.dig(name, "seconds") if it.dig(name, "ok") })
    end

    def megabytes(records, name)
      median(records.filter_map { it.dig(name, "network_bytes") if it.dig(name, "ok") })&.then { (it / 1e6).round }
    end

    def median(values)
      return if values.empty?

      values = values.sort
      middle = values.size / 2
      values.size.odd? ? values[middle] : ((values[middle - 1] + values[middle]) / 2.0).round(3)
    end

    def line(cells)
      "| #{cells.join(" | ")} |"
    end
end

if $PROGRAM_NAME == __FILE__
  command = ARGV.shift
  options = {}
  OptionParser.new do |parser|
    parser.on("--run-id ID") { options[:run_id] = it }
    parser.on("--step N", Integer) { options[:step] = it }
    parser.on("--preflight") { options[:preflight] = true }
    parser.on("--case NAME") { options[:case] = it }
    parser.on("--runner KEYS") { options[:runners] = it.split(/[\s,]+/) }
    parser.on("--daily") { options[:daily] = true }
    parser.on("--results DIR") { options[:results] = it }
    parser.on("--out PATH") { options[:out] = it }
  end.parse!(ARGV)
  job = -> { DepsJob.load(ENV.fetch("THROUGHPUT_DIR")) }
  outcomes = -> { ENV.filter_map { |key, value| [key.delete_prefix("THROUGHPUT_OUTCOME_").downcase, value] if key.start_with?("THROUGHPUT_OUTCOME_") }.to_h }
  exit case command
  when "matrix"
    plan = Deps.plan
    selected = options[:case]
    selected ||= plan.fetch("cases").keys[Time.now.utc.to_i.div(86400) % plan.fetch("cases").size] if options[:daily]
    puts Deps.new(plan, run_id: options.fetch(:run_id), step: options.fetch(:step, 0), preflight: options[:preflight], only: selected, runners: options[:runners]).outputs
    0
  when "env" then print job.call.env_lines; 0
  when "keys" then print job.call.keys; 0
  when "probe", "measure" then job.call.public_send(command)
  when "mark", "boringcache" then job.call.public_send(command, ARGV.fetch(0))
  when "record" then job.call.write(options.fetch(:out), outcomes.call)
  when "local" then DepsJob.local(Deps.plan, name: options.fetch(:case), step: options.fetch(:step, 0), out: options[:out])
  when "report" then File.write(options.fetch(:out), DepsReport.new(options.fetch(:results)).markdown); 0
  else abort "usage: scripts/deps.rb matrix|env|keys|probe|measure|mark|boringcache|record|local|report"
  end
end
