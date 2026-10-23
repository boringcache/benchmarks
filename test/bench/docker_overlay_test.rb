require_relative "test_helper"

class DockerOverlayTest < Minitest::Test
  def test_mastodon_plus_copies_the_gemfile_ruby_version_before_bundle_install
    prepare_mastodon(mastodon_dockerfile) do |dockerfile|
      before_install = dockerfile.lines.take_while { !it.include?("bundle install") }
      gemfile_copy = before_install.find { it.start_with?("COPY ") && it.include?("Gemfile") }
      sources = Shellwords.split(gemfile_copy).drop(1)[...-1]

      assert sources.any? { File.fnmatch?(it, ".ruby-version", File::FNM_DOTMATCH) },
        "the Gemfile reads .ruby-version before the full source is copied"
    end
  end

  def test_mastodon_plus_preserves_upstream_runtime_and_dependency_updates
    upstream = mastodon_dockerfile.sub('RUBY_VERSION="4.0.7"', 'RUBY_VERSION="4.0.8"')
      .sub('NODE_MAJOR_VERSION="24"', 'NODE_MAJOR_VERSION="26"')
      .sub('VIPS_VERSION=8.18.6', 'VIPS_VERSION=8.18.7')
      .sub("COPY Gemfile*", "COPY .ruby-version Gemfile*")

    prepare_mastodon(upstream) do |dockerfile|
      %w[RUBY_VERSION NODE_MAJOR_VERSION VIPS_VERSION].each do |name|
        assert_equal upstream.lines.grep(/^ARG #{name}=/), dockerfile.lines.grep(/^ARG #{name}=/)
      end
      assert_includes dockerfile, 'ENV CC="ccache cc" CXX="ccache c++"'
      assert_includes dockerfile, "--mount=type=cache,id=mastodon-ccache"
      assert_equal 1, dockerfile.scan("COPY .ruby-version Gemfile*").size
    end
  end

  private
    def prepare_mastodon(dockerfile)
      Dir.mktmpdir("mastodon-overlay") do |dir|
        FileUtils.mkdir_p(File.join(dir, "upstream"))
        File.write(File.join(dir, "upstream/Dockerfile"), dockerfile)
        FileUtils.cp_r(File.join(Bench::ROOT, "tools/docker/mastodon/overlay"), dir)
        system("bash", File.join(Bench::ROOT, "tools/docker/mastodon/prepare.sh"), chdir: dir, exception: true)
        yield File.read(File.join(dir, "overlay/mastodon-ccache.Dockerfile"))
        assert_equal dockerfile, File.read(File.join(dir, "upstream/Dockerfile"))
      end
    end

    def mastodon_dockerfile
      File.read(File.join(Bench::ROOT, "test/bench/fixtures/mastodon.Dockerfile"))
    end
end
