require "fileutils"
require "set"

profile = ARGV.fetch(0)
exit unless File.directory?(profile)

Dir.children(profile).each do |name|
  path = File.join(profile, name)
  FileUtils.rm_rf(path) if name == "examples" || (File.file?(path) && !name.start_with?("."))
end

deps = File.join(profile, "deps")
exit unless File.directory?(deps)

hash = ->(name) { name[/-(\h{16})(?:\.|\z)/, 1] }
names = Dir.children(deps)
libraries = names.grep(/\.(?:rlib|rmeta|so|dylib|dll)\z/).filter_map { hash.(it) }.to_set
names.each do |name|
  id = hash.(name)
  FileUtils.rm_rf(File.join(deps, name)) if id && !libraries.include?(id)
end
