require "toml-rb"

constraints = TomlRB.load_file("upstream/pants.toml").fetch("python").fetch("interpreter_constraints")
version = constraints.first.match(/\ACPython==(\d+\.\d+\.\d+)\z/)&.captures&.first if constraints.one?
abort "backend-ai requires one exact CPython version in pants.toml" unless version

config = TomlRB.load_file("mise.toml")
config.fetch("tools")["python"] = version
File.write("mise.toml", TomlRB.dump(config))
