module Bench
  class Container
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
      system("docker", "run", "--rm", *env_file_args, *docker_args(docker), "--env", "BENCH_RUNNER=local",
             "--volume", "#{@catalog.root}:/bench", "--workdir", "/bench", image, "bin/bench", *args)
    end

    private
      def env_file_args
        File.exist?(@env_file) ? ["--env-file", @env_file] : []
      end

      def docker_args(docker)
        docker ? ["--volume", "/var/run/docker.sock:/var/run/docker.sock"] : []
      end
  end
end
