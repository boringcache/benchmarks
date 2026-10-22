require "minitest/autorun"
require "digest"
require "fileutils"
require "open3"
require "tmpdir"

class JavaCaTrustTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  HELPER = File.join(ROOT, "tools/shared/JavaCaTrust.java")

  def setup
    _output, properties, status = Open3.capture3("java", "-XshowSettings:properties", "-version")
    skip "A JDK is required for Java trust-store tests" unless status.success?
    version = properties[/^\s*java.specification.version = (.+)$/, 1].to_i
    skip "Java 17 or newer is required for Java trust-store tests" if version < 17
    @java_home = properties[/^\s*java.home = (.+)$/, 1]&.strip
    skip "Could not locate the JDK trust store" unless @java_home
    @java = File.join(@java_home, "bin/java")
    @keytool = File.join(@java_home, "bin/keytool")
  rescue Errno::ENOENT
    skip "A JDK is required for Java trust-store tests"
  end

  def with_store
    Dir.mktmpdir("java-ca-trust") do |directory|
      store = File.join(directory, "cacerts")
      FileUtils.cp(File.join(@java_home, "lib/security/cacerts"), store)
      File.chmod(0o644, store)
      yield store
    end
  end

  def fingerprints(store)
    output, error, status = Open3.capture3(@keytool, "-J-Duser.language=en", "-list", "-rfc", "-keystore", store, "-storepass", "changeit")
    assert status.success?, error
    output.split("Alias name: ").drop(1).to_h do |entry|
      alias_name = entry.lines.first.strip
      certificate = entry[/-----BEGIN CERTIFICATE-----(.*?)-----END CERTIFICATE-----/m, 1].unpack1("m")
      [alias_name, Digest::SHA256.hexdigest(certificate)]
    end
  end

  def test_repair_preserves_other_roots_permissions_and_original_backup_and_is_idempotent
    with_store do |store|
      baseline = fingerprints(store)
      %w[emsign-ecc-root-g3.pem aaa-certificate-services.pem].each_with_index do |fixture, index|
        _output, error, status = Open3.capture3(@keytool, "-importcert", "-noprompt", "-alias", "affected-#{index}",
          "-keystore", store, "-storepass", "changeit", "-file", File.join(ROOT, "test/fixtures/ca-trust", fixture))
        assert status.success?, error
      end
      original = File.binread(store)
      _output, error, status = Open3.capture3(@java, HELPER, "--store", store)
      refute status.success?
      assert_includes error, "affected root certificates"
      assert_equal original, File.binread(store)

      output, error, status = Open3.capture3(@java, HELPER, "--store", store, "--apply")
      assert status.success?, error
      assert_includes output, "Removed"
      expected = baseline.reject { |_alias_name, fingerprint| %w[86a1ecba089c4a8d3bbe2734c612ba341d813e043cf9e8a862cd5c57a36bbe6b d7a7a0fb5d7e2731d771e9484ebcdef71d5f0c3e0a2948782bc83ee0ea699ef4].include?(fingerprint) }
      assert_equal expected, fingerprints(store)
      assert_equal original, File.binread("#{store}.before-emudhra-20261021")
      assert_equal 0o644, File.stat(store).mode & 0o777

      repaired = File.binread(store)
      _output, error, status = Open3.capture3(@java, HELPER, "--store", store, "--apply")
      assert status.success?, error
      assert_equal repaired, File.binread(store)
    end
  end

  def test_invalid_store_is_not_modified
    with_store do |store|
      File.binwrite(store, "invalid keystore")
      _output, _error, status = Open3.capture3(@java, HELPER, "--store", store, "--apply")
      refute status.success?
      assert_equal "invalid keystore", File.binread(store)
      refute File.exist?("#{store}.before-emudhra-20261021")
    end
  end

  def test_existing_backup_is_not_overwritten
    with_store do |store|
      _output, error, status = Open3.capture3(@keytool, "-importcert", "-noprompt", "-alias", "affected",
        "-keystore", store, "-storepass", "changeit", "-file", File.join(ROOT, "test/fixtures/ca-trust/emsign-ecc-root-g3.pem"))
      assert status.success?, error
      original = File.binread(store)
      backup = "#{store}.before-emudhra-20261021"
      File.binwrite(backup, "earlier backup")
      _output, _error, status = Open3.capture3(@java, HELPER, "--store", store, "--apply")
      refute status.success?
      assert_equal original, File.binread(store)
      assert_equal "earlier backup", File.binread(backup)
      assert_empty Dir[File.join(File.dirname(store), "cacerts-emudhra-*.tmp")]
    end
  end
end
