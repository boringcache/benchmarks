require "open3"
require "toml-rb"

revision, status = Open3.capture2("git", "-C", "upstream", "rev-parse", "HEAD")
abort "Cannot determine the checked-out Semgrep revision" unless status.success?

plan = TomlRB.load_file(".boringcache.toml")
command = plan.fetch("adapters").fetch("docker").fetch("command")
command.insert(-2, "--build-arg", "VCS_REF_HEAD_REVISION=#{revision.strip}")
File.write(".boringcache.toml", TomlRB.dump(plan))
