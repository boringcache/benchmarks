# frozen_string_literal: true

require "json"
require "digest"
require "fileutils"
require "yaml"
require_relative "reapi-registry"
require_relative "benchmark-phase"

module ReapiClient
  class Error < StandardError; end
  ENDPOINT = "grpc://127.0.0.1:5060"

  def self.recipe
    JSON.parse(File.read("reapi-recipe.json"))
  end

  def self.configure(phase)
    warm = phase == "warm"
    case recipe.fetch("tool")
    when "moon"
      path = ".moon/workspace.yml"
      config = YAML.safe_load(File.read(path))
      config["experiments"] = config.fetch("experiments", {}).merge("casOutputsCache" => true)
      config["remote"] = {"host" => ENDPOINT, "api" => "grpc", "cache" => {"instanceName" => "", "compression" => "none", "verifyIntegrity" => true}}
      File.write(path, YAML.dump(config))
      ENV["MOON_CACHE"] = warm ? "read" : "read-write"
    when "pants"
      ENV.update("PANTS_REMOTE_STORE_ADDRESS" => ENDPOINT, "PANTS_REMOTE_CACHE_READ" => "true",
        "PANTS_REMOTE_CACHE_WRITE" => warm ? "false" : "true", "PANTS_REMOTE_EXECUTION" => "false",
        "PANTS_REMOTE_INSTANCE_NAME" => "", "PANTS_STATS_LOG" => "true", "PANTS_PANTSD" => "false")
    when "buck2"
      File.write(".buckconfig.local", <<~CONFIG)
        [buck2_re_client]
          engine_address = #{ENDPOINT}
          action_cache_address = #{ENDPOINT}
          cas_address = #{ENDPOINT}
          tls = false
        [build]
          execution_platforms = root//benchmark-platform:local
        [benchmark]
          cache_uploads = #{warm ? "false" : "true"}
      CONFIG
    when "sbt"
      ENV["BENCHMARK_REAPI_ENDPOINT"] = ENDPOINT
    else
      raise Error, "Unknown native client"
    end
  end

  def self.build
    phase, provider = ENV.fetch("PHASE"), ENV.fetch("PROVIDER")
    configure(phase)
    scope = BenchmarkPhase.scope(ENV)
    ReapiRegistry.run(command: recipe.fetch("command"), provider: provider, phase: phase,
      workspace: "boringcache/benchmarks", tag: scope)
  end

  def self.verify
    files = recipe.fetch("outputs").flat_map { |pattern| Dir.glob(pattern) }.select { |path| File.file?(path) }.sort.uniq
    raise Error, "No declared outputs were produced" if files.empty?
    raise Error, "An output is empty" if files.any? { |path| File.size(path).zero? }
    recipe.fetch("checks", []).each do |command|
      raise Error, "Output check failed: #{command.first}" unless system(*command)
    end
    if ENV.fetch("PHASE") == "warm"
      raise Error, "No native remote-cache hit was recorded" unless remote_cache_hit?
    end
    output = files.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
    File.write("reapi-evidence/outputs.json", JSON.pretty_generate(output) + "\n")
    if ENV.fetch("PHASE") == "warm"
      seed = JSON.parse(File.read("cold-checks/outputs.json"))
      raise Error, "Outputs differ from the cold build" unless seed == output
    end
  end

  def self.remote_cache_hit?
    Regexp.new(recipe.fetch("warm_hit_pattern"), Regexp::IGNORECASE).match?(File.read("reapi-evidence/build.log"))
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    case ARGV.shift
    when "build" then ReapiClient.build
    when "verify" then ReapiClient.verify
    else raise ReapiClient::Error, "Use build or verify"
    end
  rescue ReapiClient::Error, ReapiRegistry::Error => error
    abort error.message
  end
end
