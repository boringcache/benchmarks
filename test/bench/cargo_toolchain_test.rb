require_relative "test_helper"

class CargoToolchainTest < Minitest::Test
  def test_nushell_installs_the_exact_toolchain_of_each_source_revision
    %w[1.97.1 1.98.1].each do |version|
      output, status, config, calls = prepare("nushell", "channel" => version, "profile" => "default")

      assert status.success?, output
      assert_equal({ "version" => version, "profile" => "minimal" }, config.dig("tools", "rust"))
      assert_equal "0.17.0", config.dig("tools", "sccache")
      assert_equal ["trust #{version}", "install #{version}"], calls
    end
    kase = Bench::Catalog.new(Bench::ROOT).find_case("cargo/nushell")
    refute kase.env({}).key?("RUSTUP_TOOLCHAIN")
  end

  def test_zed_installs_the_toolchain_components_and_targets_of_each_source_revision
    components = %w[rustfmt clippy rust-analyzer rust-src]
    targets = %w[wasm32-wasip2 wasm32-unknown-unknown x86_64-unknown-linux-musl]

    %w[1.98.1 1.100.0].each do |version|
      output, status, config, calls = prepare("zed", "channel" => version, "components" => components, "targets" => targets)

      assert status.success?, output
      assert_equal({ "version" => version, "profile" => "minimal", "components" => components.join(","), "targets" => targets.join(",") },
                   config.dig("tools", "rust"))
      assert_equal "0.17.0", config.dig("tools", "sccache")
      assert_equal ["trust #{version}", "install #{version}"], calls
    end
  end

  def test_rejects_floating_toolchains_before_installation
    %w[stable nightly 1.98].each do |version|
      output, status, config, calls = prepare("zed", "channel" => version)

      refute status.success?
      assert_includes output, "requires one exact Rust version"
      refute config.fetch("tools").key?("rust")
      assert_empty calls
    end
  end

  private
    def prepare(project, toolchain)
      Dir.mktmpdir("cargo-toolchain") do |dir|
        FileUtils.mkdir_p([File.join(dir, "upstream"), File.join(dir, "bin")])
        FileUtils.cp(File.join(Bench::ROOT, "tools/cargo", project, "mise.toml"), dir)
        source = TomlRB.dump("toolchain" => toolchain)
        toolchain_path = File.join(dir, "upstream/rust-toolchain.toml")
        File.write(toolchain_path, source)
        calls = File.join(dir, "calls")
        mise = File.join(dir, "bin/mise")
        File.write(mise, <<~SH)
          #!/usr/bin/env bash
          version=$(ruby -rtoml-rb -e 'puts TomlRB.load_file("mise.toml").dig("tools", "rust", "version")')
          echo "$1 $version" >> "$CALLS"
        SH
        File.chmod(0o755, mise)
        kase = Bench::Catalog.new(Bench::ROOT).find_case("cargo/#{project}")
        setup = kase.prepare.find { |command| command.include?("mise install") }
        output, status = Open3.capture2e(
          { "PATH" => "#{dir}/bin:#{File.dirname(RbConfig.ruby)}:#{ENV.fetch("PATH")}", "CALLS" => calls, "BENCH_ROOT" => Bench::ROOT },
          "bash", "-e", "-c", setup, chdir: dir
        )
        assert_equal source, File.read(toolchain_path)
        [output, status, TomlRB.load_file(File.join(dir, "mise.toml")), File.exist?(calls) ? File.readlines(calls, chomp: true) : []]
      end
    end
end
