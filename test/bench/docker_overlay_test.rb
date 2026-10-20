require_relative "test_helper"

class DockerOverlayTest < Minitest::Test
  def test_mastodon_plus_copies_the_gemfile_ruby_version_before_bundle_install
    dockerfile = File.read(File.join(Bench::ROOT, "tools/docker/mastodon/overlay/mastodon-ccache.Dockerfile"))
    before_install = dockerfile.lines.take_while { !it.include?("bundle install") }
    gemfile_copy = before_install.find { it.start_with?("COPY ") && it.include?("Gemfile") }
    sources = Shellwords.split(gemfile_copy).drop(1)[...-1]

    assert sources.any? { File.fnmatch?(it, ".ruby-version", File::FNM_DOTMATCH) },
      "the Gemfile reads .ruby-version before the full source is copied"
  end
end
