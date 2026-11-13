require "json"
require "open3"
require "toml-rb"

bake_file, name = ARGV
abort "Usage: bake-build-args.rb BAKE_FILE TARGET" unless bake_file && name

output, status = Open3.capture2("docker", "buildx", "bake", "--file", bake_file, "--print", name)
abort "Cannot resolve the #{name} Bake target" unless status.success?
target = JSON.parse(output).fetch("target").fetch(name)

plan = TomlRB.load_file(".boringcache.toml")
command = plan.fetch("adapters").fetch("docker").fetch("command")
file = command.index("--file") or abort "The plan command has no --file"
dockerfile = File.join(command.last, target.fetch("dockerfile", "Dockerfile"))
abort "The #{name} Bake target builds #{dockerfile}; the plan builds #{command[file + 1]}" unless command[file + 1] == dockerfile

args = target.fetch("args", {})
planned = command.each_cons(2).filter_map { |flag, value| value.split("=", 2).first if flag == "--build-arg" }
duplicates = planned & args.keys
abort "The plan and the #{name} Bake target both set #{duplicates.join(", ")}" if duplicates.any?

command.insert(file + 2, *args.flat_map { |key, value| ["--build-arg", "#{key}=#{value}"] })
File.write(".boringcache.toml", TomlRB.dump(plan))
