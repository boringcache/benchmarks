require "json"
require "open3"
require "fileutils"
require "toml-rb"

FileUtils.mkdir_p("overlay")

version = File.read("upstream/VERSION").strip
match = /\A(\d+\.\d+\.\d+)(?:-(.+))?\z/.match(version) or abort "Unsupported VERSION: #{version.inspect}"
suffix = match[2]
number = if suffix&.match?(/\A[1-9]\d*\z/)
  suffix
elsif suffix
  "0~#{suffix}"
else
  "dev.1"
end
stamp, status = Open3.capture2("git", "-C", "upstream", "show", "-s", "--format=%cs", "HEAD")
abort "Cannot read source commit date" unless status.success?
args = { "PRODUCT_VERSION" => match[1], "BUILD_NUMBER" => number, "OS_UPDATE_STAMP" => stamp.strip }
File.write("overlay/version.json", JSON.pretty_generate("target" => { "_common" => { "args" => args } }))

output, status = Open3.capture2(
  "docker", "buildx", "bake",
  "--file", "upstream/build/docker-bake.hcl",
  "--file", "overlay/version.json",
  "--set=*.context=upstream",
  "--set=*.tags=",
  "--set=standalone.tags=euro-office-benchmark:local",
  "--set=standalone.output=type=docker",
  "--print", "standalone",
)
abort "Cannot resolve standalone Bake targets" unless status.success?
definition = JSON.parse(output)
definition.fetch("target").each_value do |target|
  target.delete("cache-from")
  target.delete("cache-to")
end
plan = TomlRB.load_file(".boringcache.toml").fetch("adapters").fetch("docker")
if Array(plan["tool-cache"]).any?
  require_relative "euro-office-cache"
  local_cache = ENV["EURO_OFFICE_LOCAL_CCACHE"] == "1"
  { "core" => :core, "core-wasm" => :wasm }.each do |name, method|
    target = definition.fetch("target").fetch(name)
    path = File.join(target.fetch("context"), target.fetch("dockerfile"))
    File.write("overlay/#{name}.Dockerfile", EuroOfficeCache.public_send(method, File.read(path), local_cache:))
    target["dockerfile"] = "../overlay/#{name}.Dockerfile"
  end
  system("bash", File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/stage-ccache-binary.sh"), "upstream/bench-ccache", exception: true)
end
File.write("overlay/build.json", JSON.pretty_generate(definition))
