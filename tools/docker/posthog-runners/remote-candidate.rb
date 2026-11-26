require "toml-rb"

name = ARGV.fetch(0)
plan = TomlRB.load_file(".boringcache.toml")
remote = plan.fetch("remotes").fetch(name)
known_hosts = File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/posthog-runners/#{name}_known_hosts")
remote["known-hosts-file"] = known_hosts if File.exist?(known_hosts)
remote.fetch("worker")["binary"] = File.join(ENV.fetch("RUNNER_TEMP"), "boringcache-cli", "boringcache")
File.write(".boringcache.toml", TomlRB.dump(plan))
