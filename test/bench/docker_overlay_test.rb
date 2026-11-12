require_relative "test_helper"
require "open3"

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

  def test_dspace_plus_loads_the_build_cache_and_always_runs_the_installer_assembly
    awk_implementations.each do |awk|
      prepare_dspace(dspace_dockerfile, awk:) do |dockerfile, status|
        assert status.success?, "#{awk} preparation failed"
        lines = dockerfile.lines(chomp: true)
        copy = lines.index("COPY --chown=dspace . /app/")
        assert_equal "COPY --chown=dspace <<EOF /app/.mvn/extensions.xml", lines[copy + 1], awk
        assert_includes dockerfile, "<artifactId>maven-build-cache-extension</artifactId>"
        build = lines.index { it.start_with?("RUN mvn --no-transfer-progress package") }
        assert_equal 'RUN mvn --no-transfer-progress package ${MAVEN_FLAGS} -Dmaven.build.cache.alwaysRunPlugins=maven-assembly-plugin:single && \\', lines[build], awk
        assert_equal "  mv /app/dspace/target/${TARGET_DIR}/* /install && \\", lines[build + 1], awk
        assert_equal dspace_dockerfile.lines.size + 10, lines.size, awk
      end
    end
  end

  def test_dspace_plus_refuses_an_upstream_build_line_it_cannot_change
    changed = dspace_dockerfile.sub("RUN mvn --no-transfer-progress package ${MAVEN_FLAGS} && \\", "RUN mvn package ${MAVEN_FLAGS} && \\")
    refute_equal dspace_dockerfile, changed

    prepare_dspace(changed) do |_dockerfile, status|
      refute status.success?
    end
  end

  private
    def prepare_dspace(dockerfile, awk: "awk")
      Dir.mktmpdir("dspace-overlay") do |dir|
        FileUtils.mkdir_p([File.join(dir, "upstream"), File.join(dir, "bin")])
        File.symlink(executable(awk), File.join(dir, "bin/awk"))
        File.write(File.join(dir, "upstream/Dockerfile"), dockerfile)
        env = { "PATH" => [File.join(dir, "bin"), ENV.fetch("PATH")].join(File::PATH_SEPARATOR) }
        _output, status = Open3.capture2e(env, "bash", File.join(Bench::ROOT, "tools/docker/dspace/prepare.sh"), chdir: dir)
        target = File.join(dir, "overlay/dspace-maven.Dockerfile")
        yield File.exist?(target) ? File.read(target) : "", status
        assert_equal dockerfile, File.read(File.join(dir, "upstream/Dockerfile"))
      end
    end

    def awk_implementations
      %w[awk mawk gawk].select { executable(it) }
    end

    def executable(name)
      ENV.fetch("PATH").split(File::PATH_SEPARATOR).map { File.join(it, name) }.find { File.executable?(it) }
    end

    def dspace_dockerfile
      File.read(File.join(Bench::ROOT, "test/bench/fixtures/dspace.Dockerfile"))
    end

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
