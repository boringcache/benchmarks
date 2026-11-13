require_relative "test_helper"
require "open3"

class BakeBuildArgsTest < Minitest::Test
  SCRIPT = File.join(Bench::ROOT, "tools/docker/shared/bake-build-args.rb")

  def test_n8n_plans_build_with_the_arguments_their_bake_target_resolves
    { "n8n" => "n8n", "n8n-runners" => "runners", "n8n-runners-distroless" => "runners-distroless" }.each do |kase, target|
      prepare = TomlRB.load_file(File.join(Bench::ROOT, "tools/docker", kase, "case.toml")).fetch("prepare")
      assert_equal %(ruby "$BENCH_ROOT/tools/docker/shared/bake-build-args.rb" upstream/docker/docker-bake.hcl #{target}), prepare.last
      command = TomlRB.load_file(File.join(Bench::ROOT, "tools/docker", kase, ".boringcache.toml")).dig("adapters", "docker", "command")
      refute_includes command, "--build-arg"
    end
  end

  def test_resolved_arguments_follow_the_dockerfile
    run_script(args: { "BUILDER_IMAGE" => "node:26.13.0-alpine3.24@sha256:aa", "RUNTIME_IMAGE" => "n8nio/base:26.13.0@sha256:bb" }) do |command, output, status|
      assert status.success?, output
      assert_equal ["docker", "buildx", "build", "--file", "upstream/docker/images/n8n/Dockerfile",
                    "--build-arg", "BUILDER_IMAGE=node:26.13.0-alpine3.24@sha256:aa", "--build-arg", "RUNTIME_IMAGE=n8nio/base:26.13.0@sha256:bb",
                    "--tag", "n8n-benchmark:local", "--load", "upstream"], command
    end
  end

  def test_failed_bake_resolution_stops_preparation
    run_script(resolve: false) do |command, output, status|
      refute status.success?
      assert_includes output, "Cannot resolve the n8n Bake target"
      refute_includes command, "--build-arg"
    end
  end

  def test_a_target_for_another_dockerfile_stops_preparation
    run_script(dockerfile: "docker/images/n8n/Dockerfile.debian") do |command, output, status|
      refute status.success?
      assert_includes output, "builds upstream/docker/images/n8n/Dockerfile.debian"
      refute_includes command, "--build-arg"
    end
  end

  def test_an_argument_set_by_the_plan_and_the_target_stops_preparation
    run_script(planned: ["--build-arg", "BUILDER_IMAGE=node:22"], args: { "BUILDER_IMAGE" => "node:26" }) do |command, output, status|
      refute status.success?
      assert_includes output, "both set BUILDER_IMAGE"
      assert_equal 1, command.count("--build-arg")
    end
  end

  private
    def run_script(args: {}, resolve: true, dockerfile: "docker/images/n8n/Dockerfile", planned: [])
      Dir.mktmpdir("bake-args") do |dir|
        FileUtils.mkdir_p(File.join(dir, "bin"))
        command = ["docker", "buildx", "build", "--file", "upstream/docker/images/n8n/Dockerfile", *planned, "--tag", "n8n-benchmark:local", "--load", "upstream"]
        File.write(File.join(dir, ".boringcache.toml"), TomlRB.dump("adapters" => { "docker" => { "tag" => "n8n-docker", "command" => command } }))
        definition = { "target" => { "n8n" => { "context" => ".", "dockerfile" => dockerfile, "args" => args } } }
        File.write(File.join(dir, "bin/docker"), <<~RUBY)
          #!#{RbConfig.ruby}
          abort "Expected Bake inspection" unless ARGV == %w[buildx bake --file upstream/docker/docker-bake.hcl --print n8n]
          exit 1 unless #{resolve}
          puts #{JSON.generate(definition).inspect}
        RUBY
        File.chmod(0o755, File.join(dir, "bin/docker"))
        output, status = Open3.capture2e({ "PATH" => "#{dir}/bin:#{ENV.fetch("PATH")}" }, RbConfig.ruby, SCRIPT, "upstream/docker/docker-bake.hcl", "n8n", chdir: dir)
        yield TomlRB.load_file(File.join(dir, ".boringcache.toml")).dig("adapters", "docker", "command"), output, status
      end
    end
end
