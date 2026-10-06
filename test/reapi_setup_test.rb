# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/reapi-setup"

class ReapiSetupTest < Minitest::Test
  def test_release_download_retries_before_installing_a_checksum_verified_binary
    Dir.mktmpdir do |directory|
      attempts = 0
      binary = "verified executable"
      download = lambda do |*command|
        attempts += 1
        raise "HTTP 500" if attempts == 1
        File.write(File.join(command[command.index("--dir") + 1], "tool"), binary)
        true
      end
      destination = File.join(directory, "bin/tool")
      ReapiSetup.stub(:run, download) do
        ReapiSetup.stub(:sleep, nil) do
          ReapiSetup.download("owner/tool", "v1.0.0", "tool", "tool", sha256: Digest::SHA256.hexdigest(binary), destination: destination)
        end
      end
      assert_equal 2, attempts
      assert_equal binary, File.read(destination)
      assert File.executable?(destination)
    end
  end

  def test_release_download_stops_after_three_failures_without_installing_a_binary
    Dir.mktmpdir do |directory|
      attempts = 0
      download = lambda do |*|
        attempts += 1
        raise "HTTP 500"
      end
      destination = File.join(directory, "bin/tool")
      ReapiSetup.stub(:run, download) do
        ReapiSetup.stub(:sleep, nil) do
          assert_raises(RuntimeError) do
            ReapiSetup.download("owner/tool", "v1.0.0", "tool", "tool", sha256: "a" * 64, destination: destination)
          end
        end
      end
      assert_equal 3, attempts
      refute File.exist?(destination)
    end
  end

  def test_restored_receipt_is_retained_outside_the_running_store
    with_store do |previous|
      ReapiSetup.rolling_seed
      refute File.exist?("reapi-store/benchmark-source.json")
      assert_equal "cached object", File.read("reapi-store/cas/object")
      evidence = JSON.parse(File.read("reapi-evidence/rolling-seed.json"))
      assert_equal previous, evidence.fetch("previous")
      assert_equal "seed-key", evidence.fetch("cache_key")
      ReapiSetup.publish_seed
      next_seed = JSON.parse(File.read("reapi-store/benchmark-source.json"))
      assert_equal "b" * 40, next_seed.dig("source", "revision")
      assert_equal "2", next_seed.fetch("run_id")
      assert_equal "cached object", File.read("reapi-store/cas/object")
    end
  end

  def test_foreign_seed_is_rejected_without_discarding_its_receipt
    with_store do |previous|
      previous["case_id"] = "another-case"
      File.write("reapi-store/benchmark-source.json", JSON.generate(previous))
      error = assert_raises(RuntimeError) { ReapiSetup.rolling_seed }
      assert_includes error.message, "belongs to another case"
      assert_equal previous, JSON.parse(File.read("reapi-store/benchmark-source.json"))
      refute File.exist?("reapi-evidence/rolling-seed.json")
    end
  end

  private

  def with_store
    original = ENV.to_h
    ENV.update("BENCHMARK_ID" => "gogs-moon", "RESTORED_CACHE_KEY" => "seed-key", "GITHUB_RUN_ID" => "2", "GITHUB_RUN_ATTEMPT" => "1")
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        FileUtils.mkdir_p(%w[reapi-store/cas reapi-evidence])
        File.write("reapi-store/cas/object", "cached object")
        previous = {"case_id" => "gogs-moon", "source" => {"revision" => "a" * 40}, "run_id" => "1"}
        File.write("reapi-store/benchmark-source.json", JSON.generate(previous))
        File.write("benchmark-context.json", JSON.generate("source" => {"revision" => "b" * 40}))
        yield previous
      end
    end
  ensure
    ENV.replace(original)
  end
end
