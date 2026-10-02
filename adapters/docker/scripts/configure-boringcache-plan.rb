#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
args = {"metadata_hint" => [], "platform" => "", "tool_cache" => "", "mount_cache" => false, "no_cache" => false}
OptionParser.new do |parser|
  %w[plan_directory cache_scope image_repository image_tag platform tool_cache].each do |name|
    parser.on("--#{name.tr('_','-')} VALUE") { |value| args[name] = value }
  end
  parser.on("--metadata-hint VALUE") { |value| args["metadata_hint"] << value }
  parser.on("--mount-cache") { args["mount_cache"] = true }
  parser.on("--no-cache") { args["no_cache"] = true }
end.parse!
root = BenchmarkPlan::ROOT
path = File.realpath(File.join(root, args.fetch("plan_directory"), ".boringcache.toml"))
raise "Plan directory must stay inside the case checkout" unless path.start_with?(root + "/")
plan = BenchmarkPlan.load(path)
docker = plan.fetch("adapters").fetch("docker")
command = docker.fetch("command")
indices = command.each_index.select { |i| command[i].start_with?(args.fetch("image_repository") + ":") }
raise "Expected one declared image reference" unless indices.length == 1
command[indices.first] = "#{args.fetch('image_repository')}:#{args.fetch('image_tag')}"
platforms = command.each_index.select { |i| command[i] == "--platform" }
raise "Expected at most one platform flag" if platforms.length > 1
unless args["platform"].empty?
  if platforms.empty?
    command.insert(command.index("--file") + 2, "--platform", args["platform"])
  else
    command[platforms.first + 1] = args["platform"]
  end
end
command.insert(command.index("build") + 1, "--no-cache") if args["no_cache"] && !command.include?("--no-cache")
docker["tag"] = args.fetch("cache_scope")
docker["metadata-hints"] = docker.fetch("metadata-hints", []).reject { |hint| %w[benchmark case fidelity phase].include?(hint.split("=", 2).first) } + args["metadata_hint"]
args["tool_cache"].empty? ? docker.delete("tool-cache") : docker["tool-cache"] = [args["tool_cache"]]
args["mount_cache"] ? docker["mount-cache"] = true : docker.delete("mount-cache")
rendered = TomlRB.dump(plan)
raise "Configured plan differs from the requested values" unless TomlRB.parse(rendered) == plan
File.write(path, rendered)
