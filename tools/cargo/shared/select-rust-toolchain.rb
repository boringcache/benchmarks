require "toml-rb"

toolchain = TomlRB.load_file("upstream/rust-toolchain.toml").fetch("toolchain")
version = toolchain.fetch("channel")
abort "upstream/rust-toolchain.toml requires one exact Rust version" unless /\A\d+\.\d+\.\d+\z/.match?(version.to_s)

config = TomlRB.load_file("mise.toml")
rust = { "version" => version, "profile" => "minimal" }
toolchain.slice("components", "targets").each { |key, values| rust[key] = values.join(",") }
config.fetch("tools")["rust"] = rust
File.write("mise.toml", TomlRB.dump(config))
