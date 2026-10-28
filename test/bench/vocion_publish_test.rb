require_relative "test_helper"
require_relative "../../tools/docker/vocion/overlay/publish"

class VocionPublishTest < Minitest::Test
  include BenchFixture

  def test_publication_is_isolated_by_lane_and_records_the_source_revision
    Dir.mktmpdir("vocion-publish") do |dir|
      FileUtils.mkdir_p(File.join(dir, "overlay"))
      FileUtils.cp(File.join(Bench::ROOT, "tools/docker/vocion/.boringcache.toml"), File.join(dir, ".boringcache.toml"))
      FileUtils.cp_r(File.join(@root, "upstream"), File.join(dir, "upstream"))
      Dir.chdir(dir) do
        VocionPublish.prepare("GITHUB_REPOSITORY" => "example/benchmarks", "BENCH_SCOPE" => "vocion-ghcr-rolling-3")
        image = "ghcr.io/example/benchmarks-vocion/vocion-ghcr-rolling-3:#{@upstream_sha}"
        assert_equal image, File.read("overlay/image.txt").strip
        command = TomlRB.load_file(".boringcache.toml").dig("adapters", "docker", "command")
        assert_equal image, command[command.index("--tag") + 1]
        assert_includes command, "VOCION_BUILD_FS_CACHE=0"
        assert_includes command, "--push"
        refute_includes command, "--load"
        File.write("overlay/image-metadata.json", JSON.generate("containerimage.digest" => "bad"))
        assert_raises(RuntimeError) { VocionPublish.check }
      end
    end
  end
end
