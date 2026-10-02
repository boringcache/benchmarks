#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"

args = {"plan" => File.join(BenchmarkPlan::ROOT, ".boringcache.toml"), "load" => "false", "tool_cache" => "false"}
OptionParser.new do |parser|
  %w[push image plan source_tag source_sha workload tool_cache prerelease dockerfile node_version scenario build_id source_ref platform mount_cache no_cache sourcemap_secret load].each do |name|
    parser.on("--#{name.tr('_', '-')} VALUE") { |value| args[name] = value }
  end
end.parse!
case_id = JSON.parse(File.read(File.join(BenchmarkPlan::ROOT, "benchmark-context.json"))).fetch("case_id")
path = args.fetch("plan")
text = File.read(path)
plan = TomlRB.parse(text)
replace = lambda do |old, value|
  raise "Committed #{case_id} plan must contain one #{old.inspect}" unless text.scan(Regexp.new(Regexp.escape(old))).length == 1
  text = text.sub(old, value)
end
boolean = lambda do |name|
  value = args.fetch(name, "false")
  raise "--#{name.tr('_','-')} must be true or false" unless %w[true false].include?(value)
  value == "true"
end
push = boolean.call("push")
raise "Publishing requires --image" if push && args.fetch("image", "").empty?
sha = args["source_sha"]
raise "Source SHA must be a full lowercase commit SHA" if sha && !sha.match?(/\A[0-9a-f]{40}\z/)
case case_id
when "hugo", "chroma", "linkerd2", "duckgres", "n8n"
  case case_id
  when "linkerd2"
    replace.call('"LINKERD_VERSION=__SOURCE_TAG__"', JSON.generate("LINKERD_VERSION=#{args.fetch('source_tag')}"))
  when "duckgres"
    replace.call("VERSION=build-__SOURCE_SHA__", "VERSION=build-#{args.fetch('source_sha')}")
    replace.call("COMMIT=__SOURCE_SHA__", "COMMIT=#{args.fetch('source_sha')}")
  when "n8n"
    dockerfile = args.fetch("dockerfile")
    raise "Dockerfile must stay below upstream/docker" unless dockerfile.start_with?("upstream/docker/") && !dockerfile.split("/").include?("..")
    version = args.fetch("node_version")
    raise "Node version must be an exact release" unless version.match?(/\A\d+\.\d+\.\d+\z/)
    replace.call('"__N8N_DOCKERFILE__"', JSON.generate(dockerfile))
    replace.call("NODE_VERSION=__NODE_VERSION__", "NODE_VERSION=#{version}")
  end
  if push
    image = case_id == "linkerd2" ? "linkerd2-web" : case_id
    replace.call("  \"--tag\", \"#{image}-benchmark:local\",\n  \"upstream\",", "  \"--tag\", #{JSON.generate(args.fetch('image'))},\n  \"--push\",\n  \"upstream\",")
  end
when "mastodon"
  workload = args.fetch("workload")
  raise "Workload must be server or streaming" unless %w[server streaming].include?(workload)
  tool_cache = boolean.call("tool_cache")
  raise "sccache is available only for server" if tool_cache && workload != "server"
  prerelease = args.fetch("prerelease")
  raise "Prerelease must use nightly.YYYY-MM-DD" unless prerelease.match?(/\Anightly\.\d{4}-\d{2}-\d{2}\z/)
  dockerfile = tool_cache ? "scenarios/mastodon-sccache/Dockerfile" : workload == "server" ? "upstream/Dockerfile" : "upstream/streaming/Dockerfile"
  replace.call('"__DOCKERFILE__"', JSON.generate(dockerfile))
  replace.call("MASTODON_VERSION_PRERELEASE=__PRERELEASE__", "MASTODON_VERSION_PRERELEASE=#{prerelease}")
  replace.call("SOURCE_COMMIT=__SOURCE_SHA__", "SOURCE_COMMIT=#{args.fetch('source_sha')}")
  replace.call('"__IMAGE__"', JSON.generate(push ? args.fetch("image") : "mastodon-#{workload}-benchmark:local"))
  if tool_cache
    needle = 'metadata-hints = ["benchmark=mastodon", "upstream-job=build-image-amd64"]'
    replace.call(needle, needle + "\ntool-cache = [\"sccache\"]")
  end
  replace.call("  \"upstream\",\n]", "  \"--push\",\n  \"upstream\",\n]") if push
when "posthog", "immich"
  docker = plan.fetch("adapters").fetch("docker")
  if case_id == "posthog"
    tool_cache = boolean.call("tool_cache")
    expected = tool_cache ? ".benchmark/PostHog.Dockerfile" : "upstream/Dockerfile"
    raise "Expected Dockerfile #{expected}" unless args.fetch("dockerfile") == expected
    platform = args.fetch("platform")
    raise "Unsupported platform" unless %w[linux/amd64 linux/arm64].include?(platform)
    load = boolean.call("load")
    raise "Choose either push or load" if push && load
    command = ["docker", "buildx", "build", "--file", expected, "--platform", platform, "--provenance", "false"]
    command += ["--secret", "id=posthog_upload_sourcemaps_cli_api_key,env=POSTHOG_SOURCEMAP_API_KEY"] if boolean.call("sourcemap_secret")
    command << "--no-cache" if boolean.call("no_cache")
    command += ["--tag", push ? args.fetch("image") : "posthog-benchmark:local"]
    command << "--push" if push
    command << "--load" if load
    command << "upstream"
    docker["tool-cache"] = ["turbo"] if tool_cache
    docker.delete("tool-cache") unless tool_cache
    boolean.call("mount_cache") ? docker["mount-cache"] = true : docker.delete("mount-cache")
  else
    scenario = args.fetch("scenario")
    if scenario == "server"
      raise "Server plans require source SHA, build ID and source ref" unless sha && args["build_id"] && args["source_ref"]
      command = ["docker", "buildx", "build", "--file", "upstream/server/Dockerfile", "--platform", "linux/amd64",
        "--build-arg", "BUILD_ID=#{args['build_id']}", "--build-arg", "BUILD_IMAGE=ghcr.io/immich-app/immich-server:#{args['source_ref']}",
        "--build-arg", "BUILD_SOURCE_REF=#{args['source_ref']}", "--build-arg", "BUILD_SOURCE_COMMIT=#{sha}", "--build-arg", "DEVICE=cpu",
        "--tag", push ? args.fetch("image") : "immich-server-benchmark:local"]
      command << "--push" if push
      command << "upstream"
      docker["metadata-hints"] = ["benchmark=immich-server", "upstream-job=server-amd64"]
      docker.delete("tool-cache")
    elsif scenario == "base-images"
      raise "Base-images plans do not publish an image" if push
      command = ["docker", "buildx", "build", "--file", "base-images-upstream/server/Dockerfile", "--platform", "linux/amd64",
        "--target", "libvips", "--tag", "immich-base-images-benchmark:local", "base-images-upstream/server"]
      docker["metadata-hints"] = ["benchmark=immich-base-images", "upstream-job=server-native-amd64"]
      boolean.call("tool_cache") ? docker["tool-cache"] = ["ccache"] : docker.delete("tool-cache")
    else
      raise "Scenario must be server or base-images"
    end
  end
  docker["command"] = command
  text = TomlRB.dump(plan)
else
  raise "No Docker projection for #{case_id}"
end
TomlRB.parse(text)
File.write(path, text)
