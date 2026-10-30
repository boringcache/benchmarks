require_relative "test_helper"

class PantsPreparationTest < Minitest::Test
  def test_installs_the_interpreter_required_by_each_source_revision
    %w[3.13.7 3.13.18].each do |version|
      output, status, config, calls = prepare("CPython==#{version}")

      assert status.success?, output
      assert_equal version, config.dig("tools", "python")
      assert_equal "0.13.2", config.dig("tools", "scie-pants")
      assert_equal ["trust #{version}", "install #{version}"], calls
    end
  end

  def test_rejects_a_non_exact_interpreter_before_installation
    output, status, config, calls = prepare("CPython>=3.13")

    refute status.success?
    assert_includes output, "requires one exact CPython version"
    assert_equal "3.13.7", config.dig("tools", "python")
    assert_empty calls
  end

  def test_interpreter_discovery_uses_the_selected_toolchain
    kase = Bench::Catalog.new(Bench::ROOT).find_case("pants/backend-ai")
    assert_equal '["<PATH>"]', kase.env({}).fetch("PANTS_PYTHON_BOOTSTRAP_SEARCH_PATH")
  end

  private
    def prepare(constraint)
      Dir.mktmpdir("pants-python") do |dir|
        FileUtils.mkdir_p([File.join(dir, "upstream"), File.join(dir, "bin")])
        FileUtils.cp(File.join(Bench::ROOT, "tools/pants/backend-ai/mise.toml"), dir)
        File.write(File.join(dir, "upstream/pants.toml"), TomlRB.dump("python" => { "interpreter_constraints" => [constraint] }))
        calls = File.join(dir, "calls")
        mise = File.join(dir, "bin/mise")
        File.write(mise, <<~SH)
          #!/usr/bin/env bash
          version=$(ruby -rtoml-rb -e 'puts TomlRB.load_file("mise.toml").fetch("tools").fetch("python")')
          echo "$1 $version" >> "$CALLS"
        SH
        File.chmod(0o755, mise)
        kase = Bench::Catalog.new(Bench::ROOT).find_case("pants/backend-ai")
        output, status = Open3.capture2e(
          { "PATH" => "#{dir}/bin:#{File.dirname(RbConfig.ruby)}:#{ENV.fetch("PATH")}", "CALLS" => calls, "BENCH_ROOT" => Bench::ROOT },
          "bash", "-c", kase.prepare.first, chdir: dir
        )
        [output, status, TomlRB.load_file(File.join(dir, "mise.toml")), File.exist?(calls) ? File.readlines(calls, chomp: true) : []]
      end
    end
end
