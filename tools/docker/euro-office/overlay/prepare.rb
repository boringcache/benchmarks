require "json"
require "open3"

version = File.read("upstream/VERSION").strip
match = /\A(\d+\.\d+\.\d+)(?:-(.+))?\z/.match(version) or abort "Unsupported VERSION: #{version.inspect}"
suffix = match[2]
number = if suffix&.match?(/\A[1-9]\d*\z/)
  suffix
elsif suffix
  "0~#{suffix}"
else
  "dev.1"
end
stamp, status = Open3.capture2("git", "-C", "upstream", "show", "-s", "--format=%cs", "HEAD")
abort "Cannot read source commit date" unless status.success?
args = { "PRODUCT_VERSION" => match[1], "BUILD_NUMBER" => number, "OS_UPDATE_STAMP" => stamp.strip }
File.write("overlay/version.json", JSON.pretty_generate("target" => { "_common" => { "args" => args } }))
