require "json"
require "open3"
require "toml-rb"

module DockerImagePublication
  def self.prepare(package, env = ENV)
    repository = env.fetch("GITHUB_REPOSITORY")
    scope = env.fetch("BENCH_SCOPE")
    raise "Invalid GitHub repository" unless repository.match?(%r{\A[a-z0-9-]+/[a-z0-9_.-]+\z})
    raise "Invalid benchmark scope" unless scope.match?(/\A[a-z0-9][a-z0-9_.-]*\z/)

    sha, status = Open3.capture2("git", "-C", "upstream", "rev-parse", "HEAD")
    raise "Could not resolve the upstream commit" unless status.success? && sha.strip.match?(/\A[0-9a-f]{40}\z/)

    image = "ghcr.io/#{repository}-#{package}/#{scope}:#{sha.strip}"
    plan = TomlRB.load_file(".boringcache.toml")
    command = plan.fetch("adapters").fetch("docker").fetch("command")
    index = command.index("--tag") or raise "The build has no image tag"
    raise "The build must push its output image" unless command.include?("--push") && !command.include?("--load")

    command[index + 1] = image
    File.write(".boringcache.toml", TomlRB.dump(plan))
    File.write("overlay/image.txt", image + "\n")
  end

  def self.image_tag
    File.read("overlay/image.txt").strip
  end

  def self.image_reference(image = image_tag)
    digest = JSON.parse(File.read("overlay/image-metadata.json")).fetch("containerimage.digest")
    raise "Invalid published image digest" unless digest.match?(/\Asha256:[0-9a-f]{64}\z/)

    "#{image.split(":").first}@#{digest}"
  end

  def self.verify(platform)
    reference = image_reference
    output, status = Open3.capture2("docker", "buildx", "imagetools", "inspect", "--format", "{{json .Image}}", reference)
    raise "Could not inspect the published image" unless status.success?

    actual = JSON.parse(output).values_at("os", "architecture").join("/")
    raise "Published image is #{actual}. Expected #{platform}." unless actual == platform

    puts "Verified #{platform} image #{reference}"
  end
end

if $PROGRAM_NAME == __FILE__
  case ARGV.fetch(0)
  when "prepare" then DockerImagePublication.prepare(ARGV.fetch(1))
  when "check" then DockerImagePublication.verify(ARGV.fetch(1))
  else raise "Expected prepare or check"
  end
end
