require_relative "test_helper"

class PosthogOverlayTest < Minitest::Test
  SOURCE = <<~'DOCKERFILE'
    FROM node:24 AS frontend-build
    COPY packages/agent/packages/agent-contracts/src/ packages/agent/packages/agent-contracts/src/

    COPY frontend/ frontend/
    RUN bin/turbo --filter=@posthog/frontend build


    FROM node:24 AS node-scripts-build
    COPY common/plugin_transpiler/ common/plugin_transpiler/
    RUN --mount=type=cache,id=pnpm,target=/tmp/pnpm-store-v24 \
        NODE_OPTIONS="--max-old-space-size=4096" CI=1 pnpm --filter=@posthog/plugin-transpiler... install --frozen-lockfile --store-dir /tmp/pnpm-store-v24 && \
        NODE_OPTIONS="--max-old-space-size=4096" bin/turbo --filter=@posthog/plugin-transpiler build

    COPY products/canvas/packages/canvas_builder/ products/canvas/packages/canvas_builder/
  DOCKERFILE

  def setup
    @dir = Dir.mktmpdir("posthog-overlay")
    @case_dir = File.expand_path("../../tools/docker/posthog", __dir__)
    FileUtils.cp_r(File.join(@case_dir, "overlay"), @dir)
    FileUtils.mkdir_p(File.join(@dir, "upstream"))
    File.write(File.join(@dir, "upstream/Dockerfile"), SOURCE)
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def test_preparation_preserves_upstream_changes_and_adds_only_cache_wiring
    output, status = prepare
    assert status.success?, output
    generated = File.read(File.join(@dir, "overlay/PostHog.Dockerfile"))
    assert_includes generated, "COPY packages/agent/packages/agent-contracts/src/ packages/agent/packages/agent-contracts/src/"
    assert_equal 2, generated.scan("--mount=type=cache,id=posthog-turbo").size
    assert_equal 2, generated.scan("--mount=type=secret,id=boringcache-tool-cache-env").size
    assert_equal SOURCE, File.read(File.join(@dir, "upstream/Dockerfile"))

    output, status = Open3.capture2e("git", "apply", "--reverse", "--no-index", "--directory=overlay", "overlay/cache.patch", chdir: @dir)
    assert status.success?, output
    assert_equal SOURCE, File.read(File.join(@dir, "overlay/PostHog.Dockerfile"))
  end

  def test_preparation_regenerates_the_overlay_from_the_checked_out_source
    output, status = prepare
    assert status.success?, output
    File.write(File.join(@dir, "upstream/Dockerfile"), SOURCE.sub("node:24", "node:25"))

    output, status = prepare
    assert status.success?, output
    assert_includes File.read(File.join(@dir, "overlay/PostHog.Dockerfile")), "FROM node:25 AS frontend-build"
  end

  def test_preparation_preserves_product_copies_before_the_frontend_build
    source = SOURCE.sub("COPY frontend/ frontend/", "COPY products/ products/\nCOPY frontend/ frontend/")
    File.write(File.join(@dir, "upstream/Dockerfile"), source)

    output, status = prepare
    assert status.success?, output
    generated = File.read(File.join(@dir, "overlay/PostHog.Dockerfile"))
    assert_includes generated, "COPY products/ products/\nCOPY frontend/ frontend/"
    assert_equal 2, generated.scan("--mount=type=cache,id=posthog-turbo").size
    assert_equal 2, generated.scan("--mount=type=secret,id=boringcache-tool-cache-env").size
    assert_equal source, File.read(File.join(@dir, "upstream/Dockerfile"))

    output, status = Open3.capture2e("git", "apply", "--reverse", "--no-index", "--directory=overlay", "overlay/cache.patch", chdir: @dir)
    assert status.success?, output
    assert_equal source, File.read(File.join(@dir, "overlay/PostHog.Dockerfile"))
  end

  def test_preparation_fails_when_upstream_changes_the_patched_build_command
    File.write(File.join(@dir, "upstream/Dockerfile"), SOURCE.sub("RUN bin/turbo", "RUN pnpm exec turbo"))

    output, status = prepare
    refute status.success?, output
    assert_includes output, "patch does not apply"
  end

  private
    def prepare
      commands = TomlRB.load_file(File.join(@case_dir, "case.toml")).fetch("prepare")
      Open3.capture2e({ "RUNNER_ENVIRONMENT" => nil }, "bash", "-ec", commands.join("\n"), chdir: @dir)
    end
end
