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

  def test_scope_cannot_escape_r2_prefix
    with_env("NATIVELINK_INSTANCE" => "../other") do
      capture_io { assert_raises(SystemExit) { NativeLinkCache.prefix } }
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
