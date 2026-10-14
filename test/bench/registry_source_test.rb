require "minitest/autorun"
require "tmpdir"
require "zlib"
require_relative "../../scripts/registry-source"

class RegistrySourceTest < Minitest::Test
  def config
    { "source" => RegistrySource::IMAGE, "source_commit" => "a" * 40, "source_run_id" => "123",
      "platform" => "linux/amd64", "image_id" => "sha256:#{'b' * 64}", "archive_sha256" => "c" * 64 }
  end

  def test_source_metadata_cannot_change_registry_destinations
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "source.json"), JSON.generate(config.merge("workspace" => "another/workspace")))
      result = RegistrySource.config(dir, run_id: "123")
      assert_equal config, result
      assert_raises(RuntimeError) { RegistrySource.config(dir, run_id: "456") }
    end
  end

  def test_modified_archive_is_rejected_before_loading_docker
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "image.tar.gz"), "changed image")
      error = assert_raises(RuntimeError) { RegistrySource.load(dir, config:) }
      assert_equal "PostHog image archive checksum differs", error.message
    end
  end

  def test_export_keeps_the_image_identity_and_detects_docker_save_failures
    Dir.mktmpdir do |dir|
      docker = File.join(dir, "docker")
      File.write(docker, <<~RUBY)
        #!#{RbConfig.ruby}
        if ARGV[1] == "inspect"
          puts #{JSON.generate([{ "Os" => "linux", "Architecture" => "amd64", "Id" => config.fetch("image_id"), "Size" => 100 }]).inspect}
        else
          print "saved image"
          exit ENV.fetch("SAVE_STATUS", "0").to_i
        end
      RUBY
      FileUtils.chmod(0755, docker)
      old_path, old_status = ENV.values_at("PATH", "SAVE_STATUS")
      begin
        ENV["PATH"] = "#{dir}:#{old_path}"
        ENV["SAVE_STATUS"] = "0"
        destination = File.join(dir, "source")
        RegistrySource.export(destination, commit: config.fetch("source_commit"), run_id: "123")
        source = RegistrySource.config(destination, run_id: "123")
        assert_equal config.fetch("image_id"), source.fetch("image_id")
        archive = File.join(destination, "image.tar.gz")
        assert_equal "saved image", Zlib::GzipReader.open(archive, &:read)
        assert_equal Digest::SHA256.file(archive).hexdigest, source.fetch("archive_sha256")
        ENV["SAVE_STATUS"] = "3"
        error = assert_raises(RuntimeError) { RegistrySource.export(destination, commit: config.fetch("source_commit"), run_id: "123") }
        assert_equal "PostHog image export failed", error.message
      ensure
        ENV["PATH"], ENV["SAVE_STATUS"] = old_path, old_status
      end
    end
  end
end
