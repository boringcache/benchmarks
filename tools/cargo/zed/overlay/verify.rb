require "open3"
require "timeout"

sha, status = Open3.capture2("git", "-C", "upstream", "rev-parse", "HEAD")
abort "Cannot read the checked-out Zed commit" unless status.success?

output, status = Timeout.timeout(60) do
  Open3.capture2e("upstream/target/release/zed", "--system-specs")
end
puts output
abort "Zed could not report its embedded commit" unless status.success?
abort "Zed executable does not match checkout #{sha.strip}" unless output.lines.any? { it.start_with?("Zed:") && it.include?(sha.strip) }

changes, status = Open3.capture2("git", "-C", "upstream", "status", "--porcelain=v1", "--untracked-files=all")
abort "Zed checkout changed during the build" unless status.success? && changes.empty?
