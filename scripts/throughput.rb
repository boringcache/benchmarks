require "digest"
require "etc"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "time"
require "tmpdir"

class Throughput
  ROOT = File.expand_path("..", __dir__)
  KINDS = %w[same produce consume].freeze
  OPERATIONS = { "same" => %w[save restore], "produce" => %w[save], "consume" => %w[restore second_restore] }.freeze

  def self.plan(root = ROOT)
    require "toml-rb"
    TomlRB.load_file(File.join(root, "throughput", "plan.toml")).merge("machines" => TomlRB.load_file(File.join(root, "runners.toml")))
  end

  def self.possible?(plan, lane, producer, consumer)
    lane != "actions-cache" || store(plan, producer) == store(plan, consumer)
  end

  def self.store(plan, runner)
    plan.fetch("actions_cache_store", {}).fetch(runner, "github")
  end

  def initialize(plan, run_id:, bytes: nil, preflight: false)
    raise ArgumentError, "run id must contain digits only" unless run_id.to_s.match?(/\A\d+\z/)

    @plan, @run_id = plan, run_id.to_s
    @bytes = bytes || plan.fetch(preflight ? "preflight_bytes" : "bytes")
  end

  def jobs(kind)
    case kind
    when "same", "produce"
      @plan.fetch("runners").product(@plan.fetch("lanes"), @plan.fetch("payloads")).map do |runner, lane, payload|
        job(kind, lane, payload, runner:)
      end
    when "consume"
      @plan.fetch("consumers").flat_map do |producer, consumers|
        consumers.product(@plan.fetch("lanes"), @plan.fetch("payloads")).filter_map do |consumer, lane, payload|
          job(kind, lane, payload, runner: consumer, producer:) if self.class.possible?(@plan, lane, producer, consumer)
        end
      end
    else raise ArgumentError, "unknown kind #{kind}"
    end
  end

  def job(kind, lane, payload, runner:, producer: runner)
    machines = @plan.fetch("machines")
    source = kind == "consume" ? "produce" : kind
    { "name" => kind == "consume" ? "consume-#{producer}-to-#{runner}-#{lane}-#{payload}" : "#{kind}-#{runner}-#{lane}-#{payload}",
      "kind" => kind, "lane" => lane, "payload" => payload, "bytes" => @bytes, "run_id" => @run_id,
      "runner" => runner, "runs_on" => machines.fetch(runner).fetch("label"), "machine" => machines.fetch(runner).fetch("machine"),
      "producer" => producer, "producer_machine" => machines.fetch(producer).fetch("machine"),
      "producer_artifact" => "throughput-produce-#{producer}-#{lane}-#{payload}",
      "key" => "#{prefix}#{source}-#{producer}-#{lane}-#{payload}", "workspace" => @plan.fetch("workspace") }
  end

  def prefix
    "throughput-#{@run_id}-"
  end

  def outputs
    KINDS.map { "#{it}=#{JSON.generate(jobs(it))}" }.join("\n")
  end
end

class ThroughputJob
  ACTIONS_CACHE = "6.1.0"
  COMPRESSIBLE = "[a*64][b*64][c*64][d*64]"
  PAYLOAD = "payload"

  def self.load(dir, env: ENV)
    new(JSON.parse(File.read(File.join(dir, "job.json"))), dir:, env:)
  end

  def self.marks(text)
    text.lines.to_h do |line|
      name, at, rx, tx = line.split
      [name, { "at" => Float(at), "rx" => (Integer(rx) unless rx == "-"), "tx" => (Integer(tx) unless tx == "-") }]
    end
  end

  def self.probe(text)
    text.lines.filter_map { it.chomp.split("=", 2) if it.include?("=") }.to_h
  end

  def self.local(plan, payload:, bytes: nil, preflight: false, out: nil)
    throughput = Throughput.new(plan, run_id: Time.now.utc.strftime("%Y%m%d%H%M%S"), bytes:, preflight:)
    job = throughput.job("same", "boringcache", payload, runner: "local")
    dir = File.join(Throughput::ROOT, ".work", "throughput", job.fetch("name"))
    out ||= File.join(Throughput::ROOT, ".work", "throughput", "results")
    FileUtils.rm_rf(dir)
    FileUtils.mkdir_p(dir)
    runner = new(job, dir:)
    Dir.chdir(dir) do
      runner.probe
      runner.generate
      outcomes = {}
      runner.mark("save_start")
      outcomes["save"] = status(runner.boringcache("save"))
      runner.mark("save_end")
      outcomes["lookup"] = status(runner.boringcache("lookup"))
      runner.clear
      runner.mark("restore_start")
      outcomes["restore"] = status(runner.boringcache("restore"))
      runner.mark("restore_end")
      outcomes["restore_check"] = status(runner.check)
      runner.clear
      runner.write(out, outcomes)
    ensure
      runner.delete_tag
    end
  end

  def self.status(code)
    code.zero? ? "success" : "failure"
  end

  attr_reader :job

  def initialize(job, dir:, env: ENV)
    @job, @dir, @env = job, dir, env
  end

  def probe
    values = { "cpu" => cpu, "cores" => Etc.nprocessors, "disk_free_bytes" => disk_free }
    values["auth_seconds"] = auth_seconds if boringcache? && actions?
    File.write(path("probe"), values.compact.map { |key, value| "#{key}=#{value}\n" }.join)
    0
  end

  def generate
    FileUtils.rm_rf(PAYLOAD)
    FileUtils.mkdir_p(PAYLOAD)
    source = "head -c #{Integer(@job.fetch("bytes"))} /dev/urandom"
    command = case @job.fetch("payload")
    when "random" then source
    when "compressible" then "#{source} | LC_ALL=C tr '\\000-\\377' '#{COMPRESSIBLE}'"
    else raise ArgumentError, "unknown payload #{@job.fetch("payload")}"
    end
    raise "payload generation failed" unless system("bash", "-o", "pipefail", "-c", "#{command} > #{file}")
    raise "payload has #{File.size(file)} bytes" unless File.size(file) == @job.fetch("bytes")

    File.write(path("sha256"), Digest::SHA256.file(file).hexdigest)
    system("sync")
    0
  end

  def mark(name)
    at = Process.clock_gettime(Process::CLOCK_REALTIME)
    rx, tx = network
    File.open(path("marks"), "a") { it.puts [name, format("%.6f", at), rx || "-", tx || "-"].join(" ") }
    0
  end

  def boringcache(operation)
    entry = "#{@job.fetch("key")}:#{PAYLOAD}"
    args = case operation
    when "save" then ["save", workspace, "--entry", entry, "--no-platform", "--no-git", "--fail-on-cache-error"]
    when "lookup" then ["restore", workspace, "--entry", "#{entry}-lookup", "--no-platform", "--no-git", "--lookup-only", "--fail-on-cache-miss", "--fail-on-cache-error"]
    when "restore" then ["restore", workspace, "--entry", entry, "--no-platform", "--no-git", "--fail-on-cache-miss", "--fail-on-cache-error"]
    else raise ArgumentError, "unknown operation #{operation}"
    end
    system(*cli_prefix, "boringcache", *args) ? 0 : 1
  end

  def clear
    FileUtils.rm_rf(PAYLOAD)
    FileUtils.rm_rf(@env["BORINGCACHE_BLOB_READ_CACHE_DIR"]) unless @env["BORINGCACHE_BLOB_READ_CACHE_DIR"].to_s.empty?
    FileUtils.rm_rf(File.join(Dir.tmpdir, "boringcache-blob-cache"))
    system("sync")
    0
  end

  def check
    File.exist?(file) && File.exist?(path("sha256")) && Digest::SHA256.file(file).hexdigest == File.read(path("sha256")).strip ? 0 : 1
  end

  def producer(dir)
    record = JSON.parse(File.read(File.join(dir, "#{@job.fetch("producer_artifact").delete_prefix("throughput-")}.json")))
    raise "producer #{record["name"]} failed; nothing to restore" unless record["exit_status"] == 0 && record["output_ok"] == true && record["key"] == @job.fetch("key")

    File.write(path("sha256"), record.fetch("sha256"))
    0
  end

  def delete_tag
    warn "throughput: could not delete #{@job.fetch("key")}" unless system("boringcache", "rm", "--no-platform", "--no-git", workspace, @job.fetch("key"))
  end

  def record(outcomes)
    marks = File.exist?(path("marks")) ? self.class.marks(File.read(path("marks"))) : {}
    probe = File.exist?(path("probe")) ? self.class.probe(File.read(path("probe"))) : {}
    operations = Throughput::OPERATIONS.fetch(@job.fetch("kind")).to_h { [it, operation(it, marks, outcomes)] }
    record = {
      **@job.slice("name", "kind", "lane", "payload", "bytes", "runner", "machine", "producer", "producer_machine", "key", "run_id"),
      "attempt" => @env.fetch("GITHUB_RUN_ATTEMPT", "1").to_i, "run_url" => run_url, "recorded_at" => Time.now.utc.iso8601,
      "versions" => boringcache? ? { "boringcache" => cli_version } : { "actions_cache" => ACTIONS_CACHE },
      "observed" => { "cpu" => probe["cpu"], "cores" => probe["cores"]&.to_i, "disk_free_bytes" => probe["disk_free_bytes"]&.to_i }.compact,
      "auth_seconds" => probe["auth_seconds"]&.to_f, "sha256" => (File.read(path("sha256")).strip if File.exist?(path("sha256"))),
      **operations
    }.compact
    record["exit_status"] = operations.values.all? { it["step_ok"] } ? 0 : 1
    record["output_ok"] = operations.values.all? { it["ok"] }
    record
  end

  def write(out, outcomes)
    record = record(outcomes)
    FileUtils.mkdir_p(out)
    File.write(File.join(out, "#{@job.fetch("name")}.json"), JSON.pretty_generate(record) + "\n")
    puts Throughput::OPERATIONS.fetch(@job.fetch("kind")).map { "#{it}: #{record.dig(it, "seconds") || "unmeasured"} s#{" (failed)" unless record.dig(it, "ok")}" }.join(", ")
    record["exit_status"].zero? && record["output_ok"] ? 0 : 1
  end

  private
    def operation(name, marks, outcomes)
      started, finished = marks["#{name}_start"], marks["#{name}_end"]
      step_ok = outcomes[name] == "success"
      check = name == "save" ? outcomes["lookup"] : outcomes["#{name}_check"]
      counter = name == "save" ? "tx" : "rx"
      measured = { "seconds" => (finished["at"] - started["at"]).round(3) } if started && finished
      measured["network_bytes"] = finished[counter] - started[counter] if measured && finished[counter] && started[counter]
      { **measured.to_h, "step_ok" => step_ok, "ok" => step_ok && check == "success" }
    end

    def path(name)
      File.join(@dir, name)
    end

    def file
      File.join(PAYLOAD, "data.bin")
    end

    def workspace
      @job.fetch("workspace")
    end

    def boringcache?
      @job.fetch("lane") == "boringcache"
    end

    def actions?
      @env["GITHUB_ACTIONS"] == "true"
    end

    def cli_prefix
      actions? ? %w[boringcache ci run --oidc-provider github-actions --] : []
    end

    def run_url
      "https://github.com/#{@env["GITHUB_REPOSITORY"]}/actions/runs/#{@job.fetch("run_id")}" if actions? && @env["GITHUB_REPOSITORY"]
    end

    def cli_version
      capture("boringcache", "--version")&.split&.last
    end

    def auth_seconds
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise "BoringCache OIDC login failed" unless system(*cli_prefix, "true")

      (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(3)
    end

    def cpu
      capture("lscpu")&.[](/^Model name:\s*(.+)$/, 1)&.strip || capture("sysctl", "-n", "machdep.cpu.brand_string")&.strip
    end

    def disk_free
      capture("df", "-Pk", ".")&.lines&.last&.split&.[](3)&.then { Integer(it) * 1024 }
    end

    def network
      if File.readable?("/proc/net/dev")
        rows = File.readlines("/proc/net/dev").drop(2).map { it.sub(":", " ").split }.reject { it[0] == "lo" }
        [rows.sum { Integer(it[1]) }, rows.sum { Integer(it[9]) }]
      elsif (output = capture("netstat", "-ibn"))
        rows = output.lines.drop(1).map(&:split).select { it[2].to_s.start_with?("<Link") && !it[0].start_with?("lo") }
        [rows.sum { Integer(it[-5]) }, rows.sum { Integer(it[-2]) }]
      end
    end

    def capture(*args)
      output, status = Open3.capture2(*args, err: File::NULL)
      output if status.success?
    rescue Errno::ENOENT
      nil
    end
end

class ThroughputReport
  OPERATION_LABELS = { "save" => "Save", "restore" => "Restore", "second_restore" => "Second restore" }.freeze
  SECTIONS = [%w[consume Independent\ consumer], %w[produce Producer\ save], %w[same Same\ job]].freeze

  def initialize(results_dir, plan)
    @results_dir, @plan = results_dir, plan
  end

  def records
    @records ||= Dir.glob(File.join(@results_dir, "**", "*.json")).sort.map { JSON.parse(File.read(it)) }.reject { it["excluded"] }
  end

  def rows(kind)
    groups = records.select { it["kind"] == kind }.group_by { [*it.values_at("lane", "payload", "producer_machine", "machine"), version(it)] }
    groups.sort_by { |key, _| key.map(&:to_s) }.map do |(lane, payload, producer, machine, version), group|
      row = { "lane" => lane, "payload" => payload, "producer" => producer, "machine" => machine, "version" => version, "samples" => group.size,
              "failed" => group.count { it["exit_status"] != 0 || it["output_ok"] != true },
              "auth_seconds" => median(group.filter_map { it["auth_seconds"] }.sort) }
      Throughput::OPERATIONS.fetch(kind).each do |name|
        passed = group.filter_map { it[name] if it.dig(name, "ok") && it.dig(name, "seconds") }
        seconds = passed.map { it["seconds"] }.sort
        row[name] = { "median" => median(seconds), "p10" => percentile(seconds, 0.1), "p90" => percentile(seconds, 0.9),
                      "network_bytes" => median(passed.filter_map { it["network_bytes"] }.sort) }
      end
      row
    end
  end

  def markdown
    lines = ["# Cache throughput", ""]
    SECTIONS.each do |kind, title|
      operations = Throughput::OPERATIONS.fetch(kind)
      head = ["Lane", "Data", *("Producer" if kind == "consume"), "Runner", "Version", "Samples", "Failed",
              *operations.flat_map { ["#{OPERATION_LABELS.fetch(it)} median s", "p10–p90 s", "#{OPERATION_LABELS.fetch(it)} network MB"] }, "Login s"]
      body = rows(kind).map do |row|
        [row["lane"], row["payload"], *(row["producer"] if kind == "consume"), row["machine"], row["version"], row["samples"], row["failed"],
         *operations.flat_map { |name| measured(row[name]) }, row["auth_seconds"] || "-"]
      end
      lines += ["## #{title}", "", line(head), line(head.map { "---" }), *body.map { line(it) }, ""]
    end
    lines.join("\n")
  end

  private
    def version(record)
      record.dig("versions", "boringcache") || record.dig("versions", "actions_cache")
    end

    def measured(op)
      [op["median"] || "unmeasured", op["p10"] ? "#{op["p10"]}–#{op["p90"]}" : "-", op["network_bytes"] ? (op["network_bytes"] / 1e6).round : "-"]
    end

    def median(values)
      return if values.empty?

      middle = values.size / 2
      values.size.odd? ? values[middle] : ((values[middle - 1] + values[middle]) / 2.0).round(3)
    end

    def percentile(values, fraction)
      return if values.empty?

      position = (values.size - 1) * fraction
      lower, upper = values[position.floor], values[position.ceil]
      (lower + (upper - lower) * (position - position.floor)).round(3)
    end

    def line(cells)
      "| #{cells.join(" | ")} |"
    end
end

class ThroughputCleanup
  def initialize(plan, prefix:, env: ENV, out: $stdout)
    raise ArgumentError, "prefix must start with throughput-" unless prefix.start_with?("throughput-")

    @plan, @prefix, @env, @out = plan, prefix, env, out
  end

  def call
    repo = @env.fetch("GITHUB_REPOSITORY")
    ids = capture("gh", "api", "--paginate", "repos/#{repo}/actions/caches?per_page=100&key=#{@prefix}", "--jq", ".actions_caches[] | .id").split
    ids.each { capture("gh", "api", "-X", "DELETE", "repos/#{repo}/actions/caches/#{it}") }
    @out.puts "Deleted #{ids.size} GitHub Actions cache entries under `#{@prefix}`."
    if @env["BORINGCACHE_ADMIN_TOKEN"].to_s.empty?
      @out.puts "BoringCache tags under `#{@prefix}` were not deleted: BORINGCACHE_ADMIN_TOKEN is not set."
    else
      tags = boringcache_tags
      tags.each_slice(50) { capture("boringcache", "rm", "--no-platform", "--no-git", @plan.fetch("workspace"), it.join(",")) }
      @out.puts "Deleted #{tags.size} BoringCache tags under `#{@prefix}`."
    end
    @plan.fetch("actions_cache_store", {}).each do |runner, store|
      @out.puts "#{store} keeps the actions/cache entries saved on #{runner} under `#{@prefix}`; delete them in the #{store} dashboard."
    end
    0
  end

  private
    def boringcache_tags
      (1..).each_with_object([]) do |page, tags|
        listing = JSON.parse(capture("boringcache", "ls", @plan.fetch("workspace"), "--json", "--limit", "100", "--page", page.to_s))
        tags.concat(listing.fetch("entries").map { it.fetch("tag") }.select { it.start_with?(@prefix) })
        break tags if listing.fetch("entries").empty? || page * 100 >= listing.fetch("total")
      end
    end

    def capture(*args)
      output, error, status = Open3.capture3(*args)
      raise "#{args.first(2).join(" ")} failed: #{error.strip}" unless status.success?

      output
    end
end

if $PROGRAM_NAME == __FILE__
  command = ARGV.shift
  options = {}
  OptionParser.new do |parser|
    parser.on("--run-id ID") { options[:run_id] = it }
    parser.on("--preflight") { options[:preflight] = true }
    parser.on("--bytes N", Integer) { options[:bytes] = it }
    parser.on("--payload NAME") { options[:payload] = it }
    parser.on("--prefix PREFIX") { options[:prefix] = it }
    parser.on("--results DIR") { options[:results] = it }
    parser.on("--out PATH") { options[:out] = it }
  end.parse!(ARGV)
  job = -> { ThroughputJob.load(ENV.fetch("THROUGHPUT_DIR")) }
  outcomes = -> { ENV.filter_map { |key, value| [key.delete_prefix("THROUGHPUT_OUTCOME_").downcase, value] if key.start_with?("THROUGHPUT_OUTCOME_") }.to_h }
  exit case command
  when "matrix" then puts Throughput.new(Throughput.plan, run_id: options.fetch(:run_id), preflight: options[:preflight]).outputs; 0
  when "probe", "generate", "clear", "check" then job.call.public_send(command)
  when "mark", "boringcache", "producer" then job.call.public_send(command, ARGV.fetch(0))
  when "record" then job.call.write(options.fetch(:out), outcomes.call)
  when "local" then ThroughputJob.local(Throughput.plan, payload: options.fetch(:payload, "random"), bytes: options[:bytes], preflight: options[:preflight], out: options[:out])
  when "report" then File.write(options.fetch(:out), ThroughputReport.new(options.fetch(:results), Throughput.plan).markdown); 0
  when "cleanup" then ThroughputCleanup.new(Throughput.plan, prefix: options.fetch(:prefix)).call
  else abort "usage: scripts/throughput.rb matrix|probe|generate|mark|boringcache|clear|check|producer|record|local|report|cleanup"
  end
end
