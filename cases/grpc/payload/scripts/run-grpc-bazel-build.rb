# frozen_string_literal: true

require_relative "benchmark-plan"

required = lambda do |name|
  value = ENV.fetch(name)
  abort "#{name} must not be empty" if value.empty?
  value
end

tool, operation, *arguments = BenchmarkPlan.command("bazel")
startup = ["--output_user_root=#{required.call('BAZEL_OUTPUT_USER_ROOT')}",
           "--output_base=#{required.call('BAZEL_OUTPUT_BASE')}"]
provider = []

case required.call("BAZEL_CACHE_STRATEGY")
when "actions-cache"
  directory = required.call("BAZEL_DISK_CACHE")
  FileUtils.mkdir_p(directory)
  provider << "--disk_cache=#{directory}"
when "buildbuddy"
  key = required.call("BUILDBUDDY_API_KEY")
  provider.concat([
    "--bes_results_url=https://app.buildbuddy.io/invocation/",
    "--bes_backend=grpcs://remote.buildbuddy.io",
    "--remote_cache=grpcs://remote.buildbuddy.io",
    "--remote_timeout=10m",
    "--remote_instance_name=#{required.call('BUILDBUDDY_REMOTE_INSTANCE_NAME')}",
    "--remote_header=x-buildbuddy-api-key=#{key}"
  ])
  provider << "--remote_upload_local_results=false" if ENV["BUILDBUDDY_REMOTE_UPLOAD_LOCAL_RESULTS"] == "false"
when "nativelink"
  provider.concat(["--remote_cache=grpc://127.0.0.1:50051", "--remote_timeout=10m",
    "--remote_instance_name=#{required.call('NATIVELINK_INSTANCE')}"])
  provider << "--remote_upload_local_results=false" if ENV["NATIVELINK_PHASE"] == "warm"
when "boringcache"
  # The shared Action configures the product's Bazel cache.
else
  abort "Unknown Bazel cache strategy: #{ENV.fetch('BAZEL_CACHE_STRATEGY')}"
end

exec(tool, *startup, operation, *provider, *arguments, chdir: File.join(BenchmarkPlan::ROOT, "upstream"))
