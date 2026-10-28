require_relative "test_helper"
require_relative "../../tools/docker/vocion/cache-diagnostic"

class VocionCacheDiagnosticTest < Minitest::Test
  def source
    <<~DOCKERFILE
      FROM node@sha256:abc AS deps
      RUN npm ci
      FROM node@sha256:abc AS builder
      COPY . .
      RUN node scripts/write-version.mjs
      RUN #{VocionCacheDiagnostic::BUILD_MOUNT} \\
          VOCION_BUILD_FS_CACHE="${VOCION_BUILD_FS_CACHE}" \\
          npm run build:next:staged \\
       && npm run docs:index
      RUN rm -rf .next/standalone/packages/core/tests
      FROM node@sha256:abc AS runner
    DOCKERFILE
  end

  def test_input_image_stops_before_compilation_and_preserves_command
    prefix, command = VocionCacheDiagnostic.recipe(source)
    assert_includes prefix, "RUN node scripts/write-version.mjs"
    refute_includes prefix, "build:next:staged"
    refute_includes prefix, "AS runner"
    assert_match(/\AVOCION_BUILD_FS_CACHE="\$\{VOCION_BUILD_FS_CACHE\}"\s+npm run build:next:staged\s+&& npm run docs:index\z/, command)
  end

  def test_changed_mount_or_build_command_requires_review
    assert_raises(RuntimeError) { VocionCacheDiagnostic.recipe(source.sub("sharing=locked", "sharing=shared")) }
    assert_raises(RuntimeError) { VocionCacheDiagnostic.recipe(source.sub("docs:index", "docs:generate")) }
    assert_raises(RuntimeError) { VocionCacheDiagnostic.recipe(source + source) }
  end
end
