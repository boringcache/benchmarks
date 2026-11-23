require_relative "../../shared/image-publication"

module VocionPublish
  def self.prepare(env = ENV)
    DockerImagePublication.prepare("vocion", env)
  end

  def self.check
    image = DockerImagePublication.image_tag
    reference = DockerImagePublication.image_reference(image)
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
