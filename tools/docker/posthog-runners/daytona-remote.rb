require "toml-rb"

plan = TomlRB.load_file(".boringcache.toml")
remote = plan.fetch("remotes").fetch("daytona")
remote["known-hosts-file"] = File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/posthog-runners/daytona_known_hosts")
remote.fetch("worker")["binary"] = File.join(ENV.fetch("RUNNER_TEMP"), "boringcache-cli", "boringcache")
File.write(".boringcache.toml", TomlRB.dump(plan))
