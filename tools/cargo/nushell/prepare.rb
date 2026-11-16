require "toml-rb"

version = TomlRB.load_file("upstream/rust-toolchain.toml").fetch("toolchain").fetch("channel")
abort "nushell requires one exact Rust version in rust-toolchain.toml" unless version.match?(/\A\d+\.\d+\.\d+\z/)

config = TomlRB.load_file("mise.toml")
config.fetch("tools")["rust"] = { "version" => version, "profile" => "minimal" }
File.write("mise.toml", TomlRB.dump(config))
