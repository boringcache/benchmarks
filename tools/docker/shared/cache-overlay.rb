require "toml-rb"

class CacheOverlay
  def self.apply(path)
    return unless TomlRB.load_file(".boringcache.toml").dig("adapters", "docker", "mount-cache")

    overlay = new(path)
    yield overlay
    overlay.write
  end

  def initialize(path)
    @path = path
    @text = File.read(path)
  end

  def replace(pattern, replacement)
    count = @text.scan(pattern).size
    abort "#{@path}: expected one match for #{pattern.inspect}, found #{count}" unless count == 1

    @text.sub!(pattern, replacement)
  end

  def write
    File.write(@path, @text)
  end
end
