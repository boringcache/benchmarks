require_relative "test_helper"

class ZedVerificationTest < Minitest::Test
  include BenchFixture

  def test_output_check_rejects_a_stale_executable_and_dirty_sources
    verifier = File.expand_path("../../tools/cargo/zed/overlay/verify.rb", __dir__)
    write "upstream/.git/info/exclude", "/target/\n"
    binary = File.join(@root, "upstream/target/release/zed")
    write "upstream/target/release/zed", "#!/bin/sh\necho 'Zed: v1 (dev #{@upstream_sha})'\n"
    File.chmod(0o755, binary)

    output, status = Open3.capture2e(RbConfig.ruby, verifier, chdir: @root)
    assert status.success?, output

    File.write(binary, "#!/bin/sh\necho 'Zed: v1 (dev #{"0" * 40})'\n")
    output, status = Open3.capture2e(RbConfig.ruby, verifier, chdir: @root)
    refute status.success?
    assert_includes output, "does not match checkout"

    File.write(binary, "#!/bin/sh\necho 'Zed: v1 (dev #{@upstream_sha})'\n")
    write "upstream/README", "changed source\n"
    output, status = Open3.capture2e(RbConfig.ruby, verifier, chdir: @root)
    refute status.success?
    assert_includes output, "checkout changed"
  end
end
