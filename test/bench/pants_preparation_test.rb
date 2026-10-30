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
    assert_equal '["/work/backend-ai/.bin"]', kase.env("BENCH_DIR" => "/work/backend-ai").fetch("PANTS_PYTHON_BOOTSTRAP_SEARCH_PATH")

    prepare("CPython==3.13.18") do |dir|
      interpreter = File.join(dir, ".bin/python3")
      assert_equal File.realpath(File.join(dir, "installed-python")), File.realpath(interpreter)
      output, status = Open3.capture2e(interpreter)
      assert status.success?, output
      assert_equal "installed-python\n", output
    end
  end

  private
    def prepare(constraint)
      Dir.mktmpdir("pants-python") do |dir|
        FileUtils.mkdir_p([File.join(dir, "upstream"), File.join(dir, "bin")])
        File.write(File.join(dir, "installed-python"), "#!/bin/sh\necho installed-python\n")
        File.chmod(0o755, File.join(dir, "installed-python"))
        FileUtils.cp(File.join(Bench::ROOT, "tools/pants/backend-ai/mise.toml"), dir)
        File.write(File.join(dir, "upstream/pants.toml"), TomlRB.dump("python" => { "interpreter_constraints" => [constraint] }))
        calls = File.join(dir, "calls")
        mise = File.join(dir, "bin/mise")
        File.write(mise, <<~SH)
          #!/usr/bin/env bash
          if [ "$1" = which ]; then
            if [ "$2" = python ]; then echo "$BENCH_DIR/installed-python"; else echo "$BENCH_DIR/installed-pants"; fi
            exit 0
          fi
          version=$(ruby -rtoml-rb -e 'puts TomlRB.load_file("mise.toml").fetch("tools").fetch("python")')
          echo "$1 $version" >> "$CALLS"
        SH
        File.chmod(0o755, mise)
        kase = Bench::Catalog.new(Bench::ROOT).find_case("pants/backend-ai")
        output, status = Open3.capture2e(
          { "PATH" => "#{dir}/bin:#{File.dirname(RbConfig.ruby)}:#{ENV.fetch("PATH")}", "CALLS" => calls, "BENCH_ROOT" => Bench::ROOT, "BENCH_DIR" => dir },
          "bash", "-e", "-c", kase.prepare.first(2).join(" && "), chdir: dir
        )
        yield dir if block_given?
        [output, status, TomlRB.load_file(File.join(dir, "mise.toml")), File.exist?(calls) ? File.readlines(calls, chomp: true) : []]
      end
    end
end
