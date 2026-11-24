require_relative "test_helper"
require_relative "../../tools/docker/shared/image-publication"

class PosthogPublishTest < Minitest::Test
  include BenchFixture

  def test_runner_and_remote_plans_push_the_same_amd64_output
    plans = %w[plus plus-remote].map do |profile|
      TomlRB.load_file(File.join(Bench::ROOT, "tools/docker/posthog-runners", profile, ".boringcache.toml"))
    end
    commands = plans.map { |plan| plan.dig("adapters", "docker", "command") }
    assert_equal commands.first, commands.last
    command = commands.first
    assert_includes command.each_cons(2).to_a, ["--platform", "linux/amd64"]
    assert_includes command.each_cons(2).to_a, ["--metadata-file", "overlay/image-metadata.json"]
    assert_includes command, "--push"
    refute_includes command, "--load"

    write ".boringcache.toml", TomlRB.dump(plans.first)
    FileUtils.mkdir_p(File.join(@root, "overlay"))
    Dir.chdir(@root) do
      DockerImagePublication.prepare("posthog-runners",
        { "GITHUB_REPOSITORY" => "example/benchmarks", "BENCH_SCOPE" => "docker-posthog-runners-hetzner-github-rolling-4" })
      image = "ghcr.io/example/benchmarks-posthog-runners/docker-posthog-runners-hetzner-github-rolling-4:#{@upstream_sha}"
      assert_equal image, DockerImagePublication.image_tag
      prepared = TomlRB.load_file(".boringcache.toml").dig("adapters", "docker", "command")
      assert_includes prepared.each_cons(2).to_a, ["--tag", image]
    end
  end

  def test_verifies_the_registry_digest_and_rejects_the_wrong_platform
    image = "ghcr.io/example/benchmarks-posthog-runners/hetzner"
    digest = "sha256:#{'a' * 64}"
    write "overlay/image.txt", "#{image}:tag\n"
    write "overlay/image-metadata.json", JSON.generate("containerimage.digest" => digest)
    write "bin/docker", <<~'SH'
      #!/usr/bin/env bash
      printf '%s\n' "$@" > "$STUB_LOG"
      cat overlay/config.json
    SH
    File.chmod(0o755, File.join(@root, "bin/docker"))

    with_fixture_env do
      Dir.chdir(@root) do
        write "overlay/config.json", JSON.generate("os" => "linux", "architecture" => "amd64")
        output, = capture_io { DockerImagePublication.verify("linux/amd64") }
        assert_includes output, "#{image}@#{digest}"
        assert_equal ["buildx", "imagetools", "inspect", "--format", "{{json .Image}}", "#{image}@#{digest}"],
          File.readlines(ENV.fetch("STUB_LOG"), chomp: true)

        write "overlay/config.json", JSON.generate("os" => "linux", "architecture" => "arm64")
        assert_raises(RuntimeError) { DockerImagePublication.verify("linux/amd64") }
      end
    end
  end
end
