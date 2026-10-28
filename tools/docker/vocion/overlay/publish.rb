require "json"
require "open3"
require "toml-rb"

module VocionPublish
  def self.prepare(env = ENV)
    repository = env.fetch("GITHUB_REPOSITORY")
    scope = env.fetch("BENCH_SCOPE")
    raise "Invalid GitHub repository" unless repository.match?(%r{\A[a-z0-9-]+/[a-z0-9_.-]+\z})
    raise "Invalid benchmark scope" unless scope.match?(/\A[a-z0-9][a-z0-9_.-]*\z/)
    sha, status = Open3.capture2("git", "-C", "upstream", "rev-parse", "HEAD")
    raise "Could not resolve Vocion source" unless status.success? && sha.strip.match?(/\A[0-9a-f]{40}\z/)
    image = "ghcr.io/#{repository}-vocion/#{scope}:#{sha.strip}"
    plan = TomlRB.load_file(".boringcache.toml")
    command = plan.fetch("adapters").fetch("docker").fetch("command")
    index = command.index("--tag") or raise "Vocion build has no image tag"
    raise "Vocion build must publish an image" unless command.include?("--push") && !command.include?("--load")
    command[index + 1] = image
    File.write(".boringcache.toml", TomlRB.dump(plan))
    File.write("overlay/image.txt", image + "\n")
  end

  def self.check
    image = File.read("overlay/image.txt").strip
    digest = JSON.parse(File.read("overlay/image-metadata.json")).fetch("containerimage.digest")
    raise "Invalid published image digest" unless digest.match?(/\Asha256:[0-9a-f]{64}\z/)
    reference = "#{image.split(":").first}@#{digest}"
    puts "Published image: #{reference}"
    system("docker", "pull", reference) || raise("Published image pull failed")
    system("docker", "tag", reference, image) || raise("Published image tag failed")
    system("docker", "run", "--rm", "--entrypoint", "sh", reference, "-c",
      "test -s /app/packages/core/server.js && test -d /app/packages/core/.next/static") || raise("Published image output check failed")
  end
end

if $PROGRAM_NAME == __FILE__
  case ARGV.fetch(0)
  when "prepare" then VocionPublish.prepare
  when "check" then VocionPublish.check
  else raise "Expected prepare or check"
  end
end
