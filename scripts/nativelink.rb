require "digest"
require "fileutils"
require "json"
require "net/http"
require "timeout"

VERSION = "1.7.4"
SHA256 = "a8b0d2d6c3131b0a7d0437b64697819eb5f5cbf703a9a3240c2b01e81dcc3d34"
INSTANCE = "main"

state = File.join(ENV.fetch("RUNNER_TEMP"), "nativelink")
account = URI(ENV.fetch("R2_ENDPOINT")).host.split(".").first
prefix = "nativelink/#{ENV.fetch("BENCH_CASE")}"
FileUtils.mkdir_p(state)

archive = File.join(state, "release.tar.gz")
url = "https://github.com/TraceMachina/nativelink/releases/download/v#{VERSION}/nativelink-#{VERSION}-x86_64-unknown-linux-musl.tar.gz"
system("curl", "--fail", "--silent", "--show-error", "--location", "--retry", "3", "--output", archive, url) or abort "nativelink: download failed"
Digest::SHA256.file(archive).hexdigest == SHA256 or abort "nativelink: checksum mismatch"
system("tar", "-xzf", archive, "-C", state) or abort "nativelink: extraction failed"

stores = %w[cas ac].map do |kind|
  fast = kind == "cas" ? { "filesystem" => { "content_path" => "#{state}/cas", "temp_path" => "#{state}/tmp", "eviction_policy" => { "max_bytes" => 2_000_000_000 } } } : { "memory" => { "eviction_policy" => { "max_bytes" => 100_000_000 } } }
  slow = { "experimental_cloud_object_store" => { "provider" => "r2", "account_id" => account, "bucket" => ENV.fetch("R2_BUCKET"),
    "access_key_id" => "${AWS_ACCESS_KEY_ID}", "secret_access_key" => "${AWS_SECRET_ACCESS_KEY}",
    "key_prefix" => "#{prefix}/#{kind}/", "retry" => { "max_retries" => 6, "delay" => 0.3, "jitter" => 0.5 } } }
  { "name" => kind.upcase, "fast_slow" => { "fast" => fast, "slow" => slow } }
end
services = { "cas" => [{ "instance_name" => INSTANCE, "cas_store" => "CAS" }], "ac" => [{ "instance_name" => INSTANCE, "ac_store" => "AC" }],
  "bytestream" => [{ "instance_name" => INSTANCE, "cas_store" => "CAS" }], "capabilities" => [{ "instance_name" => INSTANCE }], "health" => {} }
config = File.join(state, "config.json")
File.write(config, JSON.pretty_generate({ "stores" => stores, "servers" => [{ "listener" => { "http" => { "socket_address" => "127.0.0.1:50051" } }, "services" => services }] }))

env = { "RUST_LOG" => "warn", "AWS_ACCESS_KEY_ID" => ENV.fetch("NATIVELINK_R2_ACCESS_KEY_ID"), "AWS_SECRET_ACCESS_KEY" => ENV.fetch("NATIVELINK_R2_SECRET_ACCESS_KEY") }
pid = Process.spawn(env, File.join(state, "nativelink"), config, out: File.join(state, "server.log"), err: [:child, :out], pgroup: true)
Process.detach(pid)

begin
  Timeout.timeout(60) do
    until (Net::HTTP.get_response(URI("http://127.0.0.1:50051/status")).is_a?(Net::HTTPSuccess) rescue false)
      Process.kill(0, pid)
      sleep 1
    end
  end
rescue Timeout::Error, Errno::ESRCH
  abort "nativelink: server did not become healthy\n#{File.read(File.join(state, "server.log")).lines.last(20).join}"
end
puts "nativelink #{VERSION} serving #{INSTANCE} from r2 #{prefix}/"
