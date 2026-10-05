# frozen_string_literal: true

require_relative "benchmark-plan"

tool, operation, *arguments = BenchmarkPlan.command("bazel")
startup = ["--output_user_root=#{ENV.fetch('BAZEL_OUTPUT_USER_ROOT')}",
           "--output_base=#{ENV.fetch('BAZEL_OUTPUT_BASE')}"]
provider = []

case ENV.fetch("BAZEL_CACHE_STRATEGY")
when "actions-cache"
  directory = ENV.fetch("BAZEL_DISK_CACHE")
  FileUtils.mkdir_p(directory)
  provider << "--disk_cache=#{directory}"
when "buildbuddy"
  key = ENV.fetch("BUILDBUDDY_API_KEY")
  abort "BUILDBUDDY_API_KEY must not be empty" if key.empty?
  provider.concat([
    "--bes_results_url=https://app.buildbuddy.io/invocation/",
    "--bes_backend=grpcs://remote.buildbuddy.io",
    "--remote_cache=grpcs://remote.buildbuddy.io",
    "--remote_timeout=10m",
    "--remote_instance_name=#{ENV.fetch('BUILDBUDDY_REMOTE_INSTANCE_NAME')}",
    "--remote_header=x-buildbuddy-api-key=#{key}"
  ])
  provider << "--remote_upload_local_results=false" if ENV["BUILDBUDDY_REMOTE_UPLOAD_LOCAL_RESULTS"] == "false"
when "boringcache"
  # The shared Action configures the product's Bazel cache.
else
  abort "Unknown Bazel cache strategy: #{ENV.fetch('BAZEL_CACHE_STRATEGY')}"
end

exec(tool, *startup, operation, *provider, *arguments, chdir: File.join(BenchmarkPlan::ROOT, "upstream"))
