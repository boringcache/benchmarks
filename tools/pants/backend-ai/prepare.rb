require "digest"
require "toml-rb"

constraints = TomlRB.load_file("upstream/pants.toml").fetch("python").fetch("interpreter_constraints")
version = constraints.first.match(/\ACPython==(\d+\.\d+\.\d+)\z/)&.captures&.first if constraints.one?
abort "backend-ai requires one exact CPython version in pants.toml" unless version

config = TomlRB.load_file("mise.toml")
config.fetch("tools")["python"] = version
File.write("mise.toml", TomlRB.dump(config))

lockfiles = Dir.glob(["upstream/python*.lock", "upstream/tools/*.lock"]).sort
abort "backend-ai Python lockfiles are missing" unless lockfiles.include?("upstream/python.lock")

inputs = ["upstream/pants.toml", "upstream/pants.ci.toml", *lockfiles]
digest = Digest::SHA256.new
inputs.each { |path| digest << path << "\0" << Digest::SHA256.file(path).digest }

plan = TomlRB.load_file(".boringcache.toml")
entry = plan.fetch("entries").fetch("pants-named-caches")
entry["tag"] = "#{entry.fetch("tag")}-#{digest.hexdigest[0, 16]}"
File.write(".boringcache.toml", TomlRB.dump(plan))
