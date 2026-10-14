require "json"
require "fileutils"
require "open3"
require "time"
require_relative "registry-source"

class RegistryBenchmark
  PROVIDERS = %w[boringcache ghcr ecr depot].freeze

  def initialize(provider, operation, config:, env: ENV, source_dir: nil)
    raise ArgumentError, "unknown registry provider" unless PROVIDERS.include?(provider)
    raise ArgumentError, "operation must be push or pull" unless %w[push pull].include?(operation)

    @provider, @operation, @config, @env = provider, operation, config, env
    @source_dir = source_dir
    @run_id = env.fetch("GITHUB_RUN_ID")
    raise ArgumentError, "run id must contain digits only" unless @run_id.match?(/\A\d+\z/)
    if source_dir
      RegistrySource.validate(config, run_id: env.fetch("SOURCE_RUN_ID"))
    else
      raise ArgumentError, "source image must be pinned by digest" unless config.fetch("source").match?(/@sha256:[a-f0-9]{64}\z/)
    end
  end

  def destination
    host = case @provider
    when "boringcache" then "registry.boringcache.com/#{@config.fetch('workspace')}"
    when "ghcr" then "ghcr.io/#{@env.fetch('GITHUB_REPOSITORY')}"
    when "depot" then @config.fetch("depot_registry")
    when "ecr" then @env.fetch("ECR_REPOSITORY")
    end
    @provider == "ecr" ? "#{host}:run-#{@run_id}" : "#{host}/registry-posthog-#{@run_id}:image"
  end

  def command
    if @operation == "push" && @provider == "boringcache"
      ["boringcache", "docker", "push", @config.fetch("source"), "--workspace", @config.fetch("workspace"), "--as", "registry-posthog-#{@run_id}:image"]
    else
      ["docker", @operation, *(%w[--platform] + [@config.fetch("platform")] if @operation == "pull"), destination]
    end
  end

  def run
    prepare
    record = { "provider" => @provider, "operation" => @operation, "source" => @config.fetch("source"),
      "source_commit" => @config.fetch("source_commit"), "destination" => destination,
      "platform" => @config.fetch("platform"),
      "machine" => "github 4c", "runner_image" => @env["ImageVersion"], "started_at" => Time.now.utc.iso8601,
      "run_url" => "https://github.com/#{@env.fetch('GITHUB_REPOSITORY')}/actions/runs/#{@run_id}",
      "docker_version" => capture("docker", "version", "--format", "{{.Server.Version}}"),
      "command" => command, "attempt" => @env.fetch("GITHUB_RUN_ATTEMPT", "1").to_i }
    record.merge!(@config.slice("compressed_layer_bytes", "image_bytes", "source_archive_bytes", "source_run_id"))
    record["boringcache_version"] = capture("boringcache", "--version") if @provider == "boringcache" && @operation == "push"
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    system(*command)
    record["exit_status"] = $?.exitstatus || 1
    record["seconds"] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    record["output_ok"] = record["exit_status"].zero? && verified?
    FileUtils.mkdir_p("registry-results")
    File.write("registry-results/#{@provider}-#{@operation}.json", JSON.pretty_generate(record) + "\n")
    record["exit_status"].zero? && record["output_ok"] ? 0 : 1
  end

  private
    def prepare
      raise "registry transfer runs cannot be retried; dispatch a new run" unless @env.fetch("GITHUB_RUN_ATTEMPT", "1") == "1"
      if @operation == "push"
        if @source_dir
          RegistrySource.load(@source_dir, config: @config)
        else
          raise "source image pull failed" unless system("docker", "pull", "--platform", @config.fetch("platform"), @config.fetch("source"))
        end
        raise "source image id differs from the pinned image" unless image_id(@config.fetch("source")) == @config.fetch("image_id")
        raise "image tag failed" unless @provider == "boringcache" || system("docker", "tag", @config.fetch("source"), destination)
      else
        raise "pull requires a runner with no local images" unless capture("docker", "image", "ls", "--quiet").empty?
      end
    end

    def verified?
      if @operation == "pull"
        image_id(destination) == @config.fetch("image_id")
      else
        body, status = Open3.capture2("docker", "buildx", "imagetools", "inspect", destination, "--raw")
        status.success? && JSON.parse(body).dig("config", "digest") == @config.fetch("image_id")
      end
    rescue JSON::ParserError
      false
    end

    def image_id(ref)
      capture("docker", "image", "inspect", "--format", "{{.Id}}", ref)
    end

    def capture(*args)
      output, status = Open3.capture2(*args)
      raise "#{args.first} command failed" unless status.success?
      output.strip
    end
end

if $PROGRAM_NAME == __FILE__
  config = JSON.parse(File.read(File.expand_path("../registry/posthog.json", __dir__)))
  source_dir = ENV["REGISTRY_SOURCE_DIR"]
  if source_dir && !source_dir.empty?
    config.delete("compressed_layer_bytes")
    config.merge!(RegistrySource.config(source_dir, run_id: ENV.fetch("SOURCE_RUN_ID")))
  else
    source_dir = nil
  end
  exit RegistryBenchmark.new(*ARGV, config:, source_dir:).run
end
