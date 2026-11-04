require_relative "test_helper"
require "digest"
require "yaml"

class CliInstallTest < Minitest::Test
  def test_each_runner_installs_its_verified_executable
    [
      ["Linux", "x86_64", "Linux", ["boringcache-linux-amd64"], "boringcache"],
      ["Darwin", "arm64", "macOS", ["boringcache-macos-universal", "libboringcache_xcode_cas-macos-universal.dylib"], "boringcache"],
      ["MINGW64_NT-10.0", "x86_64", "Windows", ["boringcache-windows-amd64.exe"], "boringcache.exe"]
    ].each do |system, arch, runner_os, assets, executable|
      install(system:, arch:, runner_os:, assets:) do |dir, output, status|
        assert status.success?, output
        assert_equal "binary #{assets.first}", File.read(File.join(dir, executable))
        assert_equal "binary #{assets.last}", File.read(File.join(dir, "libboringcache_xcode_cas.dylib")) if assets.size > 1
      end
    end
  end

  def test_mismatched_checksum_stops_before_installing
    install(assets: ["boringcache-windows-amd64.exe"], corrupt: true) do |dir, output, status|
      refute status.success?
      assert_includes output, "SHA256 checksum mismatch"
      refute File.exist?(File.join(dir, "boringcache.exe"))
    end
  end

  def test_missing_checksum_stops_before_installing
    install(assets: ["boringcache-windows-amd64.exe"], missing: true) do |dir, output, status|
      refute status.success?
      assert_includes output, "missing SHA256 checksum"
      refute File.exist?(File.join(dir, "boringcache.exe"))
    end
  end

  private
    def install(assets:, system: "MINGW64_NT-10.0", arch: "x86_64", runner_os: "Windows", corrupt: false, missing: false)
      Dir.mktmpdir("cli install") do |root|
        dir = File.join(root, "boringcache-cli")
        bin = File.join(root, "bin")
        FileUtils.mkdir_p([dir, bin])
        checksums = assets.map do |asset|
          bytes = "binary #{asset}"
          File.write(File.join(dir, asset), corrupt ? "#{bytes} changed" : bytes)
          "#{Digest::SHA256.hexdigest(bytes)}  #{asset}"
        end
        File.write(File.join(dir, "SHA256SUMS"), missing ? "" : checksums.join("\n"))
        {
          "uname" => %(if [ "$1" = -s ]; then echo "#{system}"; else echo "#{arch}"; fi),
          "curl" => "exit 0",
          "cygpath" => 'printf "%s\n" "$2"'
        }.each do |name, body|
          path = File.join(bin, name)
          File.write(path, "#!/usr/bin/env bash\n#{body}\n")
          File.chmod(0o755, path)
        end
        action = YAML.load_file(File.join(Bench::ROOT, ".github/actions/phase/action.yml"))
        script = action.fetch("runs").fetch("steps").find { it["run"]&.include?("scripts/verify-checksums.rb") }.fetch("run")
        env = { "PATH" => "#{bin}:#{ENV.fetch('PATH')}", "RUNNER_OS" => runner_os,
          "RUNNER_TEMP" => root, "GITHUB_WORKSPACE" => Bench::ROOT, "VERSION" => "v1.47.0",
          "CLI_RELEASE" => "", "GITHUB_ENV" => File.join(root, "env"), "GITHUB_PATH" => File.join(root, "path") }
        output, status = Open3.capture2e(env, "bash", "-e", "-o", "pipefail", "-c", script)
        yield dir, output, status
      end
    end
end
