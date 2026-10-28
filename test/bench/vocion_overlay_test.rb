require_relative "test_helper"

class VocionOverlayTest < Minitest::Test
  SOURCE = <<~DOCKERFILE
    FROM public.ecr.aws/docker/library/node:20-alpine AS deps
    RUN npm ci --ignore-scripts
    FROM public.ecr.aws/docker/library/node:20-alpine AS builder
    COPY . .
    RUN --mount=type=cache,id=vocion-core-next-build-cache,target=/app/packages/core/.next/cache npm run build:next:staged
    FROM public.ecr.aws/docker/library/node:20-alpine AS runner
    COPY --from=builder /app/packages/core/.next/standalone ./
  DOCKERFILE

  def test_registry_projection_preserves_build_commands_mounts_and_source_changes
    Dir.mktmpdir("vocion-overlay") do |dir|
      FileUtils.mkdir_p(File.join(dir, "upstream/packages/core"))
      FileUtils.mkdir_p(File.join(dir, "overlay"))
      source = SOURCE.sub("COPY . .", "COPY packages ./packages")
      File.write(File.join(dir, "upstream/packages/core/Dockerfile"), source)
      output, status = prepare(dir)
      assert status.success?, output
      generated = File.read(File.join(dir, "overlay/Dockerfile"))
      projected = generated.gsub(%r{docker.io/library/node:20-alpine@sha256:[0-9a-f]{64}}, "public.ecr.aws/docker/library/node:20-alpine")
      assert_equal source, projected
      assert_equal source, File.read(File.join(dir, "upstream/packages/core/Dockerfile"))
      assert_equal 3, generated.scan("sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293").size
    end
  end

  def test_upstream_image_changes_require_review
    Dir.mktmpdir("vocion-overlay") do |dir|
      FileUtils.mkdir_p(File.join(dir, "upstream/packages/core"))
      FileUtils.mkdir_p(File.join(dir, "overlay"))
      File.write(File.join(dir, "upstream/packages/core/Dockerfile"), SOURCE.sub("node:20-alpine", "node:22-alpine"))
      output, status = prepare(dir)
      refute status.success?, output
      assert_includes output, "Vocion Node image stages changed"
      refute File.exist?(File.join(dir, "overlay/Dockerfile"))
    end
  end

  private
    def prepare(dir)
      Open3.capture2e(RbConfig.ruby, File.join(Bench::ROOT, "tools/docker/vocion/overlay/prepare.rb"), chdir: dir)
    end
end
