# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/nix-benchmark"

class NixBenchmarkTest < Minitest::Test
  def test_warm_provider_selection_excludes_public_caches
    config = {"substituters" => {"value" => ["https://cache.nixos.org", "https://helix.cachix.org", "http://127.0.0.1:23456/nix?trusted=true"]}}
    assert_equal "http://127.0.0.1:23456/nix?trusted=true", NixBenchmark.provider_substituter(config, "boringcache", "")
    assert_raises(NixBenchmark::Error) { NixBenchmark.provider_substituter(config, "cachix", "benchmark-zed") }
    config["substituters"]["value"] << "https://benchmark-zed.cachix.org"
    assert_equal "https://benchmark-zed.cachix.org", NixBenchmark.provider_substituter(config, "cachix", "benchmark-zed")
  end

  def test_ambiguous_provider_configuration_fails
    config = {"substituters" => {"value" => "http://127.0.0.1:1234/nix http://127.0.0.1:5678/nix"}}
    assert_raises(NixBenchmark::Error) { NixBenchmark.provider_substituter(config, "boringcache", "") }
  end

  def test_changed_source_can_build_after_a_provider_miss_but_warm_cannot
    config = {"substituters" => {"value" => ["https://cache.nixos.org", "https://benchmark.cachix.org"]}}
    BenchmarkPlan.stub(:command, %w[nix build pinned-source]) do
      NixBenchmark.stub(:capture, JSON.generate(config)) do
        rolling = NixBenchmark.build_command(phase: "commit", provider: "cachix", cache_name: "benchmark")
        warm = NixBenchmark.build_command(phase: "warm", provider: "cachix", cache_name: "benchmark")
        assert_includes rolling, "https://benchmark.cachix.org"
        refute_includes rolling, "https://cache.nixos.org"
        refute_includes rolling, "--max-jobs"
        assert_equal rolling + ["--max-jobs", "0", "--builders", ""], warm
        assert_equal %w[nix build pinned-source --option substitute false], NixBenchmark.build_command(phase: "cold", provider: "cachix")
        assert_raises(NixBenchmark::Error) { NixBenchmark.build_command(phase: "invalid", provider: "cachix") }
      end
    end
  end

  def test_preexisting_package_output_cannot_be_reported_as_a_warm_restore
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        File.write("existing-package", "already here")
        NixBenchmark.write("nix-evidence/baseline.json", {"outputs" => [File.expand_path("existing-package")]})
        error = assert_raises(NixBenchmark::Error) { NixBenchmark.build(phase: "warm", provider: "boringcache") }
        assert_match(/already exists/, error.message)
        refute File.exist?("nix-evidence/timing.json")
      end
    end
  end

  def test_comparison_rejects_changed_dependency_and_output_hashes
    Dir.mktmpdir do |directory|
      seed, current = %w[seed current].map { |name| File.join(directory, name) }
      baseline = {"dependencies" => {"/nix/store/dependency" => "sha256:first"}}
      output = {"output" => "/nix/store/package", "closure" => {"/nix/store/package" => "sha256:first"}}
      [seed, current].each do |path|
        NixBenchmark.write(File.join(path, "baseline.json"), baseline)
        NixBenchmark.write(File.join(path, "output.json"), output)
      end
      NixBenchmark.compare(seed: seed, current: current)
      NixBenchmark.write(File.join(current, "baseline.json"), {"dependencies" => {"/nix/store/dependency" => "sha256:changed"}})
      assert_raises(NixBenchmark::Error) { NixBenchmark.compare(seed: seed, current: current) }
      NixBenchmark.write(File.join(current, "baseline.json"), baseline)
      NixBenchmark.write(File.join(current, "output.json"), output.merge("closure" => {"/nix/store/package" => "sha256:changed"}))
      assert_raises(NixBenchmark::Error) { NixBenchmark.compare(seed: seed, current: current) }
    end
  end

  def test_dependency_archive_is_verified_before_import
    Dir.mktmpdir do |directory|
      File.write(File.join(directory, "store.nar.zst"), "changed")
      NixBenchmark.write(File.join(directory, "archive.json"), {"sha256" => Digest::SHA256.hexdigest("expected")})
      Open3.stub(:pipeline, ->(*) { flunk "Unverified archive was imported" }) do
        error = assert_raises(NixBenchmark::Error) { NixBenchmark.import_dependencies(directory: directory) }
        assert_includes error.message, "checksum differs"
      end
    end
  end

  def test_dependency_export_cannot_seed_the_measured_package
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        NixBenchmark.write("nix-evidence/baseline.json", {"outputs" => ["/nix/store/package"], "dependencies" => {"/nix/store/package" => "hash"}})
        Open3.stub(:pipeline, ->(*) { flunk "Measured package was exported as a dependency" }) do
          assert_raises(NixBenchmark::Error) { NixBenchmark.export_dependencies }
        end
      end
    end
  end
end
