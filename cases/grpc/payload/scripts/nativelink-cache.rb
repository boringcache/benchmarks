# frozen_string_literal: true

require "json"
require "fileutils"
require "digest"
require "open3"
require "net/http"
require "timeout"

# NativeLink is a comparator, not the BoringCache product proxy.
module NativeLinkCache
  VERSION = "1.7.4"
  ARCHIVE_SHA256 = "a8b0d2d6c3131b0a7d0437b64697819eb5f5cbf703a9a3240c2b01e81dcc3d34"
  ACCOUNT = "efc17f9311838cfc4a3c41ce37b4246b"
  BUCKET = "benchmarks"
  DIRECTORY = File.expand_path("benchmark-results/nativelink")
  STATE = File.expand_path(".nativelink")

  def self.write(path, value)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(value) + "\n")
  end

  def self.scope
    value = ENV.fetch("NATIVELINK_INSTANCE")
    abort "Invalid NativeLink cache scope" unless value.match?(/\A[a-zA-Z0-9._-]+\z/)
    value
  end

  def self.prefix
    "nativelink/#{scope}/"
  end

  def self.config(instance, state)
    stores = %w[cas ac].map do |kind|
      fast = if kind == "cas"
        {"filesystem" => {"content_path" => "#{state}/cas", "temp_path" => "#{state}/tmp",
          "eviction_policy" => {"max_bytes" => 2_000_000_000}}}
      else
        {"memory" => {"eviction_policy" => {"max_bytes" => 100_000_000}}}
      end
      {"name" => kind.upcase, "fast_slow" => {"fast" => fast, "slow" => {
        "experimental_cloud_object_store" => {"provider" => "r2", "account_id" => ACCOUNT, "bucket" => BUCKET,
          "access_key_id" => "${AWS_ACCESS_KEY_ID}", "secret_access_key" => "${AWS_SECRET_ACCESS_KEY}",
          "key_prefix" => "nativelink/#{instance}/#{kind}/", "retry" => {"max_retries" => 6, "delay" => 0.3, "jitter" => 0.5}}}}}
    end
    {"stores" => stores, "servers" => [{"listener" => {"http" => {"socket_address" => "127.0.0.1:50051"}},
      "services" => {"cas" => [{"instance_name" => instance, "cas_store" => "CAS"}],
        "ac" => [{"instance_name" => instance, "ac_store" => "AC"}],
        "bytestream" => [{"instance_name" => instance, "cas_store" => "CAS"}],
        "capabilities" => [{"instance_name" => instance}], "health" => {}}}]}
  end

  def self.install
    abort "NativeLink benchmark requires Linux x86_64" unless RUBY_PLATFORM.include?("linux") && RUBY_PLATFORM.include?("x86_64")
    FileUtils.mkdir_p(STATE)
    archive = "#{STATE}/release.tar.gz"
    url = "https://github.com/TraceMachina/nativelink/releases/download/v#{VERSION}/nativelink-#{VERSION}-x86_64-unknown-linux-musl.tar.gz"
    abort "NativeLink download failed" unless system("curl", "--fail", "--location", "--retry", "3", "--output", archive, url)
    abort "NativeLink release checksum mismatch" unless Digest::SHA256.file(archive).hexdigest == ARCHIVE_SHA256
    abort "NativeLink extraction failed" unless system("tar", "-xzf", archive, "-C", STATE)
    abort "NativeLink binary missing" unless File.executable?("#{STATE}/nativelink")
    write("#{DIRECTORY}/release.json", {"version" => VERSION, "url" => url, "sha256" => ARCHIVE_SHA256})
  end

  def self.s3(*arguments)
    stdout, _stderr, status = Open3.capture3({"AWS_DEFAULT_REGION" => "auto", "AWS_PAGER" => ""}, "aws", "s3api",
      *arguments, "--endpoint-url", "https://#{ACCOUNT}.r2.cloudflarestorage.com", "--output", "json")
    abort "NativeLink R2 #{arguments.first} failed" unless status.success?
    stdout.empty? ? {} : JSON.parse(stdout)
  end

  def self.objects
    # AWS CLI follows continuation tokens unless pagination is explicitly disabled.
    s3("list-objects-v2", "--bucket", BUCKET, "--prefix", prefix).fetch("Contents", [])
  end

  def self.start
    %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY].each { |name| abort "Missing #{name}" if ENV.fetch(name, "").empty? }
    FileUtils.mkdir_p(DIRECTORY)
    entries = objects
    cold = ENV.fetch("CACHE_LANE") == "fresh" && ENV.fetch("PHASE") == "publish"
    abort "Fresh NativeLink cache prefix is not empty" if cold && !entries.empty?
    previous = nil
    if entries.any? { |row| row["Key"] == "#{prefix}seed.json" }
      path = "#{DIRECTORY}/previous-seed.json"
      s3("get-object", "--bucket", BUCKET, "--key", "#{prefix}seed.json", path)
      previous = JSON.parse(File.read(path))
    end
    if ENV.fetch("PHASE") == "warm"
      abort "NativeLink warm run has no matching R2 seed" unless previous && previous["source_sha"] == ENV.fetch("SOURCE_SHA") && previous["scope"] == scope
    end
    write("#{DIRECTORY}/lineage.json", {"scope" => scope, "prefix" => prefix, "previous_seed" => previous,
      "source_sha" => ENV.fetch("SOURCE_SHA"), "local_cache_initially_empty" => !File.exist?("#{STATE}/cas")})
    abort "NativeLink local cache already exists" if File.exist?("#{STATE}/cas")
    path = "#{DIRECTORY}/config.json"
    write(path, config(scope, STATE))
    log = File.open("#{DIRECTORY}/server.log", "w")
    pid = Process.spawn({"RUST_LOG" => "warn"}, "#{STATE}/nativelink", path, out: log, err: log, pgroup: true)
    log.close
    File.write("#{STATE}/pid", pid.to_s)
    Process.detach(pid)
    Timeout.timeout(60) do
      loop do
        begin
          response = Net::HTTP.start("127.0.0.1", 50051, open_timeout: 2, read_timeout: 5) { |http| http.get("/status") }
          break if response.is_a?(Net::HTTPSuccess)
        rescue IOError, SystemCallError, Timeout::Error
          # Wait for the owned process to bind and initialize its stores.
        end
        Process.kill(0, pid)
        sleep 1
      end
    end
  rescue Timeout::Error, Errno::ESRCH
    abort "NativeLink did not become healthy; inspect retained server.log"
  end

  def self.finish
    log = File.read("#{DIRECTORY}/build.log")
    hits = log.scan(/(\d+) remote cache hits?/).flatten.map(&:to_i).sum
    abort "NativeLink warm run reported no remote cache hits" if ENV.fetch("PHASE") == "warm" && hits.zero?
    outputs = %w[client server].to_h do |name|
      path = "upstream/bazel-bin/examples/cpp/csm/csm_greeter_#{name}"
      abort "NativeLink output missing: #{path}" unless File.executable?(path) && File.size?(path)
      [name, Digest::SHA256.file(path).hexdigest]
    end
    if ENV.fetch("PHASE") == "warm"
      previous = JSON.parse(File.read("#{DIRECTORY}/previous-seed.json"))
      abort "NativeLink warm output hashes differ from seed" unless previous.fetch("outputs") == outputs
    else
      path = "#{DIRECTORY}/seed.json"
      write(path, {"scope" => scope, "source_sha" => ENV.fetch("SOURCE_SHA"), "outputs" => outputs,
        "run_id" => ENV.fetch("GITHUB_RUN_ID"), "run_attempt" => ENV.fetch("GITHUB_RUN_ATTEMPT")})
      s3("put-object", "--bucket", BUCKET, "--key", "#{prefix}seed.json", "--body", path)
    end
    entries = objects.select { |row| row.fetch("Key").start_with?("#{prefix}cas/", "#{prefix}ac/") }
    abort "NativeLink R2 cache contains no objects" if entries.empty?
    bytes = entries.sum { |row| Integer(row.fetch("Size")) }
    write("#{DIRECTORY}/storage.json", {"bytes" => bytes, "source" => "cloudflare-r2-list-objects-v2",
      "breakdown" => {"bucket" => BUCKET, "prefix" => prefix, "complete" => true,
        "total_bytes" => bytes, "observations" => entries}})
    write("#{DIRECTORY}/verification.json", {"remote_cache_hits" => hits, "outputs" => outputs, "version" => VERSION})
    File.open(ENV.fetch("GITHUB_OUTPUT"), "a") { |file| file.puts "cache_hit=#{hits.positive?}" }
  end

  def self.stop
    return unless File.file?("#{STATE}/pid")
    Process.kill("TERM", Integer(File.read("#{STATE}/pid")))
  rescue Errno::ESRCH
    nil
  end
end

if $PROGRAM_NAME == __FILE__
  command = ARGV.fetch(0)
  abort "Use install, start, finish, or stop" unless %w[install start finish stop].include?(command)
  NativeLinkCache.public_send(command)
end
