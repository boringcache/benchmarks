# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"
require "json"
require "yaml"
require "toml-rb"

class DenoCargoLifecycleTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_job_plan_restores_once_and_both_commands_keep_the_reviewed_arguments
    Dir.mktmpdir("deno-cargo-session-") do |directory|
      scripts = File.join(directory, "scripts")
      FileUtils.mkdir_p([scripts, File.join(directory, "upstream"), File.join(directory, "bin")])
      %w[select-deno-cargo-phase.rb deno-release-recipe.env].each do |name|
        FileUtils.cp(File.join(ROOT, "cases/deno/payload/scripts", name), scripts)
      end
      FileUtils.cp(File.join(ROOT, "scripts/benchmark-plan.rb"), scripts)
      plan = File.join(directory, ".boringcache.toml")
      FileUtils.cp(File.join(ROOT, "cases/deno/payload/.boringcache.toml"), plan)
      original = TomlRB.load_file(plan)
      selector = File.join(scripts, "select-deno-cargo-phase.rb")
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, selector, "job")
      assert status.success?, "#{stdout}\n#{stderr}"
      expected = Marshal.load(Marshal.dump(original))
      expected.fetch("adapters").fetch("cargo").delete("command")
      assert_equal expected, TomlRB.load_file(plan)

      cargo = File.join(directory, "bin/cargo")
      File.write(cargo, "#!#{RbConfig.ruby}\nrequire 'json'\nputs JSON.generate({argv: ARGV, directory: Dir.pwd})\nexit Integer(ENV.fetch('CARGO_EXIT', '0'))\n")
      FileUtils.chmod(0o755, cargo)
      env = {"PATH" => "#{File.dirname(cargo)}:#{ENV.fetch('PATH')}"}
      stdout, stderr, status = Open3.capture3(env, RbConfig.ruby, selector, "run", "primary")
      assert status.success?, stderr
      primary = JSON.parse(stdout)
      assert_equal original.dig("adapters", "cargo", "command").drop(1), primary.fetch("argv")
      assert_equal File.realpath(File.join(directory, "upstream")), primary.fetch("directory")
      stdout, stderr, status = Open3.capture3(env, RbConfig.ruby, selector, "run", "desktop")
      assert status.success?, stderr
      assert_equal original.dig("adapters", "cargo", "command")[1, 4] + ["-p", "denort_desktop"], JSON.parse(stdout).fetch("argv")
      _stdout, _stderr, status = Open3.capture3(env.merge("CARGO_EXIT" => "42"), RbConfig.ruby, selector, "run", "desktop")
      assert_equal 42, status.exitstatus
    end
  end

  def test_each_deno_job_uses_one_product_lifecycle_before_both_commands
    %w[deno-deno-cargo-product.yml deno-deno-cargo-rolling-chain.yml].each do |name|
      workflow = YAML.load_file(File.join(ROOT, ".github/workflows", name))
      workflow.fetch("jobs").each_value do |job|
        steps = job.fetch("steps", [])
        sessions = steps.select { |step| step["uses"] == "./.github/actions/boringcache" }
        next if sessions.empty?
        assert_equal 1, sessions.length, name
        commands = steps.filter_map { |step| step["run"] if step["run"]&.include?("select-deno-cargo-phase.rb") }
        assert_equal ["ruby ./scripts/select-deno-cargo-phase.rb job", "ruby ./scripts/select-deno-cargo-phase.rb run primary", "ruby ./scripts/select-deno-cargo-phase.rb run desktop"], commands.first(3), name
        assert_operator steps.index(sessions.first), :<, steps.index { |step| step["run"] == commands[1] }
      end
    end
  end
end
