module Bench
  class Container
    BUILDKIT = "boringcache-buildkit-local"

    def initialize(catalog, env_file:)
      @catalog = catalog
      @env_file = env_file
    end

    def image
      "boringcache-bench:#{@catalog.versions["boringcache"]}"
    end

    def build
      system("docker", "build", "--build-arg", "BORINGCACHE_VERSION=#{@catalog.versions["boringcache"]}",
             "--file", File.join(@catalog.root, "container", "Dockerfile"), "--tag", image, @catalog.root)
    end

    def bench(*args, docker: false)
      reset_buildkit if docker
      system("docker", "run", "--rm", *env_file_args, *docker_args(docker), "--env", "BENCH_RUNNER=local",
             "--volume", "#{@catalog.root}:/bench", "--workdir", "/bench", image, "bin/bench", *args)
    ensure
      reset_buildkit if docker
    end

    private
      def env_file_args
        File.exist?(@env_file) ? ["--env-file", @env_file] : []
      end

      def docker_args(docker)
        docker ? ["--network", "host", "--volume", "/var/run/docker.sock:/var/run/docker.sock"] : []
      end

      def reset_buildkit
        remove("ps", "--all", "--quiet", "--filter", "name=#{BUILDKIT}") { system("docker", "rm", "--force", *it, out: File::NULL) }
        remove("volume", "ls", "--quiet", "--filter", "name=buildx_buildkit_#{BUILDKIT}") { system("docker", "volume", "rm", "--force", *it, out: File::NULL) }
      end

      def remove(*list)
        ids = IO.popen(["docker", *list], &:read).split
        yield ids unless ids.empty?
      end
  end
end
