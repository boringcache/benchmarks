require "toml-rb"

plan = TomlRB.load_file(".boringcache.toml").fetch("adapters").fetch("docker")
exit unless plan["mount-cache"]

source = File.read("upstream/core/.docker/core.bake.Dockerfile")
require File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/euro-office-cache")
File.write("overlay/core.Dockerfile", EuroOfficeCache.core(source, third_party: EuroOfficeCache.third_party_key("upstream/core")))
system("bash", File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/stage-ccache-binary.sh"), "upstream/bench-ccache", exception: true)
