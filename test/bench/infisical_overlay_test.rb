require_relative "test_helper"

class InfisicalOverlayTest < Minitest::Test
  def test_overlay_updates_the_two_pins_that_apt_would_downgrade
    source = <<~'DOCKERFILE'
      FROM node:26.12.1-trixie-slim AS production
      RUN apt-get install -y --only-upgrade \
          libssl3t64=3.5.7-1~deb13u3 \
          libnghttp2-14=1.64.0-1.1+deb13u1 \
          zlib1g=1:1.3.dfsg+really1.3.1-1+deb13u1
    DOCKERFILE
    expected = <<~'DOCKERFILE'
      FROM node:26.12.1-trixie-slim AS production
      RUN apt-get install -y --only-upgrade \
          libssl3t64=3.5.9-1~deb13u1 \
          libnghttp2-14=1.64.0-1.1+deb13u2 \
          zlib1g=1:1.3.dfsg+really1.3.1-1+deb13u1
    DOCKERFILE

    assert_equal expected, prepare(source)
    assert_equal expected, prepare(expected)
  end

  private
    def prepare(source)
      Dir.mktmpdir("infisical-overlay") do |dir|
        path = File.join(dir, "Dockerfile")
        File.write(path, source)
        script = File.join(Bench::ROOT, "tools/docker/infisical/overlay/upgrade-apt-pins.rb")
        output, status = Open3.capture2e(RbConfig.ruby, script, path)
        assert status.success?, output
        File.read(path)
      end
    end
end
