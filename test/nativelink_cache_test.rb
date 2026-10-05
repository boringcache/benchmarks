# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "tmpdir"
require_relative "../cases/grpc/payload/scripts/nativelink-cache"

class NativeLinkCacheTest < Minitest::Test
  def test_configuration_exposes_only_loopback_cache_services_and_preserves_secret_placeholders
    config = NativeLinkCache.config("grpc-series-one", "/tmp/native-check")
    server = config.fetch("servers").first
    assert_equal "127.0.0.1:50051", server.dig("listener", "http", "socket_address")
    assert_equal %w[ac bytestream capabilities cas health], server.fetch("services").keys.sort
    refute config.key?("workers")
    refute config.key?("schedulers")
    stores = config.fetch("stores")
    assert_equal 2_000_000_000, stores.first.dig("fast_slow", "fast", "filesystem", "eviction_policy", "max_bytes")
    stores.each do |store|
      remote = store.dig("fast_slow", "slow", "experimental_cloud_object_store")
      assert_equal "r2", remote.fetch("provider")
      assert_equal "${AWS_SECRET_ACCESS_KEY}", remote.fetch("secret_access_key")
      assert_equal "nativelink/grpc-series-one/#{store.fetch('name').downcase}/", remote.fetch("key_prefix")
    end
  end

  def test_fresh_run_rejects_existing_remote_objects_before_starting_server
    with_env("NATIVELINK_INSTANCE" => "test-one", "CACHE_LANE" => "fresh", "PHASE" => "publish",
      "AWS_ACCESS_KEY_ID" => "test", "AWS_SECRET_ACCESS_KEY" => "test") do
      NativeLinkCache.stub(:objects, [{"Key" => "nativelink/test-one/cas/blob"}]) do
        _, stderr = capture_io { assert_raises(SystemExit) { NativeLinkCache.start } }
        assert_includes stderr, "prefix is not empty"
      end
    end
  end

  def test_warm_run_rejects_missing_seed
    with_env("NATIVELINK_INSTANCE" => "test-one", "CACHE_LANE" => "fresh", "PHASE" => "warm",
      "AWS_ACCESS_KEY_ID" => "test", "AWS_SECRET_ACCESS_KEY" => "test") do
      NativeLinkCache.stub(:objects, []) do
        _, stderr = capture_io { assert_raises(SystemExit) { NativeLinkCache.start } }
        assert_includes stderr, "no matching R2 seed"
      end
    end
  end

  def test_seed_lookup_limits_the_prefix_query
    with_env("NATIVELINK_INSTANCE" => "test-one") do
      request = lambda do |*arguments|
        assert_equal ["list-objects-v2", "--bucket", "benchmarks", "--prefix", "nativelink/test-one/seed.json", "--max-keys", "1", "--no-paginate"], arguments
        {"Contents" => []}
      end
      NativeLinkCache.stub(:s3, request) do
        assert_empty NativeLinkCache.objects(key_prefix: "nativelink/test-one/seed.json", limit: 1)
      end
    end
  end

  def test_scope_cannot_escape_r2_prefix
    with_env("NATIVELINK_INSTANCE" => "../other") do
      capture_io { assert_raises(SystemExit) { NativeLinkCache.prefix } }
    end
  end

  def test_warm_requires_remote_hits_and_identical_outputs_before_reporting_storage
    script = File.expand_path("../cases/grpc/payload/scripts/nativelink-cache.rb", __dir__)
    Dir.mktmpdir do |directory|
      evidence = File.join(directory, "benchmark-results/nativelink")
      outputs = File.join(directory, "upstream/bazel-bin/examples/cpp/csm")
      tools = File.join(directory, "tools")
      FileUtils.mkdir_p([evidence, outputs, tools])
      hashes = %w[client server].to_h do |name|
        path = File.join(outputs, "csm_greeter_#{name}")
        File.write(path, "#!/bin/sh\nexit 0\n")
        File.chmod(0o755, path)
        [name, Digest::SHA256.file(path).hexdigest]
      end
      File.write(File.join(evidence, "previous-seed.json"), JSON.generate("outputs" => hashes))
      aws = File.join(tools, "aws")
      File.write(aws, "#!/bin/sh\nprintf '%s' '{\"Contents\":[{\"Key\":\"nativelink/test-one/cas/blob\",\"Size\":42}]}'\n")
      File.chmod(0o755, aws)
      env = {"PATH" => "#{tools}:#{ENV.fetch('PATH')}", "PHASE" => "warm", "NATIVELINK_INSTANCE" => "test-one",
        "NATIVELINK_ARTIFACT" => "nativelink-grpc-bazel-fresh-warm", "GITHUB_OUTPUT" => File.join(directory, "outputs")}
      File.write(File.join(evidence, "build.log"), "INFO: 3 processes: 3 internal.\n")
      _, stderr, status = Open3.capture3(env, RbConfig.ruby, script, "finish", chdir: directory)
      refute status.success?
      assert_includes stderr, "no remote cache hits"
      File.write(File.join(evidence, "build.log"), "INFO: 5 processes: 3 remote cache hit, 2 internal.\n")
      _, stderr, status = Open3.capture3(env, RbConfig.ruby, script, "finish", chdir: directory)
      assert status.success?, stderr
      storage = JSON.parse(File.read(File.join(evidence, "storage.json")))
      assert_equal 42, storage.fetch("bytes")
      assert_equal 1, storage.dig("breakdown", "object_count")
      assert_equal env.fetch("NATIVELINK_ARTIFACT"), storage.dig("breakdown", "inventory_artifact")
      assert_equal Digest::SHA256.file(File.join(evidence, "objects.json")).hexdigest, storage.dig("breakdown", "inventory_sha256")
      refute storage.fetch("breakdown").key?("observations")
      assert_equal "cache_hit=true\n", File.read(env.fetch("GITHUB_OUTPUT"))
      File.write(File.join(outputs, "csm_greeter_client"), "changed output")
      _, stderr, status = Open3.capture3(env, RbConfig.ruby, script, "finish", chdir: directory)
      refute status.success?
      assert_includes stderr, "output hashes differ"
    end
  end

  private

  def with_env(values)
    previous = ENV.to_h
    ENV.update(values)
    yield
  ensure
    ENV.replace(previous)
  end
end
