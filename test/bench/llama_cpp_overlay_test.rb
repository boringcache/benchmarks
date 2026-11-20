require_relative "test_helper"

class LlamaCppOverlayTest < Minitest::Test
  SOURCE = <<~'DOCKERFILE'
    FROM node:24 AS web
    COPY ui/apps/chat/package-lock.json .
    FROM ${BASE_CUDA_DEV_CONTAINER} AS build
    COPY --from=web /app/ui/apps/chat/dist ui/apps/chat/dist
    RUN if [ "${CUDA_DOCKER_ARCH}" != "default" ]; then \
        export CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=${CUDA_DOCKER_ARCH}"; \
        fi && \
        cmake -B build -DGGML_CUDA=ON ${CMAKE_ARGS} . && \
        cmake --build build --config Release -j$(nproc)
    FROM base AS server
  DOCKERFILE

  def test_overlay_uses_the_checked_out_cuda_dockerfile
    body, output, status = prepare(SOURCE)

    assert status.success?, output
    assert_includes body, "COPY ui/apps/chat/package-lock.json ."
    assert_includes body, "COPY --from=web /app/ui/apps/chat/dist ui/apps/chat/dist"
    assert_includes body, "type=cache,id=llama-cpp-ccache,target=/root/.cache/ccache"
    %w[C CXX CUDA].each { |language| assert_includes body, "-DCMAKE_#{language}_COMPILER_LAUNCHER=ccache" }
    assert_includes body, 'cmake --build build --config Release -j$(nproc) && ccache --show-stats'
    assert_includes body, "FROM base AS server"
  end

  def test_overlay_fails_when_upstream_changes_the_compile_step
    body, output, status = prepare(SOURCE.sub("cmake -B build ", "cmake -B revised "))

    refute status.success?
    assert_includes output, "llama.cpp CUDA Dockerfile changed"
    assert_nil body
  end

  private
    def prepare(source)
      Dir.mktmpdir("llama-overlay") do |dir|
        input = File.join(dir, "upstream.Dockerfile")
        overlay = File.join(dir, "overlay.Dockerfile")
        File.write(input, source)
        script = File.join(Bench::ROOT, "tools/docker/llama-cpp/overlay/prepare.rb")
        output, status = Open3.capture2e(RbConfig.ruby, script, input, overlay)
        [(File.read(overlay) if File.exist?(overlay)), output, status]
      end
    end
end
