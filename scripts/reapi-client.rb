# frozen_string_literal: true

require "json"
require "digest"
require "fileutils"
require "yaml"
require "toml-rb"
require "open3"
require_relative "reapi-registry"
require_relative "benchmark-phase"

module ReapiClient
  class Error < StandardError; end
  ENDPOINT = "grpc://127.0.0.1:5060"

  def self.recipe
    JSON.parse(File.read("reapi-recipe.json"))
  end

  def self.configure(phase, endpoint: ENDPOINT, provider: "bazel-remote")
    warm = phase == "warm"
    case recipe.fetch("tool")
    when "moon"
      path = ".moon/workspace.yml"
      config = YAML.safe_load(File.read(path))
      config["experiments"] = config.fetch("experiments", {}).merge("casOutputsCache" => true)
      config["remote"] = {"host" => endpoint, "api" => "grpc", "cache" => {"instanceName" => "", "compression" => "none", "verifyIntegrity" => true}}
      config["remote"]["auth"] = {"token" => "DEPOT_TOKEN"} if provider == "depot-cache"
      File.write(path, YAML.dump(config))
      ENV["MOON_CACHE"] = warm ? "read" : "read-write"
    when "pants"
      ENV.update("PANTS_REMOTE_STORE_ADDRESS" => endpoint, "PANTS_REMOTE_CACHE_READ" => "true",
        "PANTS_REMOTE_CACHE_WRITE" => warm ? "false" : "true", "PANTS_REMOTE_EXECUTION" => "false",
        "PANTS_REMOTE_INSTANCE_NAME" => "", "PANTS_STATS_LOG" => "true", "PANTS_PANTSD" => "false")
      ENV["PANTS_REMOTE_STORE_HEADERS"] = JSON.generate({"Authorization" => ENV.fetch("DEPOT_TOKEN")}) if provider == "depot-cache"
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
    return managed_build(phase) if provider == "boringcache"
    if provider == "depot-cache"
      raise Error, "Depot REAPI screening supports Moon and Pants" unless %w[moon pants].include?(recipe.fetch("tool"))
      require_relative "depot-cache"
      DepotCache.environment(recipe.fetch("tool"))
      configure(phase, endpoint: "grpcs://cache.depot.dev", provider: provider)
      return remote_build(phase, provider: provider, command: recipe.fetch("command"))
    end
    configure(phase)
    scope = BenchmarkPhase.scope(ENV)
    ReapiRegistry.run(command: recipe.fetch("command"), provider: provider, phase: phase,
      workspace: "boringcache/benchmarks", tag: scope)
  end

  def self.managed_command(phase, scope)
    tool = recipe.fetch("tool")
    raise Error, "Unknown native client" unless %w[moon pants buck2 sbt].include?(tool)
    raise Error, "Unknown phase" unless %w[cold warm commit].include?(phase)
    config = {"workspace" => "boringcache/benchmarks", "adapters" => {
      tool => {"tag" => scope, "no-git" => true, "no-platform" => true,
        "command" => recipe.fetch("command")}}}
    File.write(".boringcache.toml", TomlRB.dump(config))
    if tool == "buck2"
      File.write(".buckconfig.local", "[build]\n  execution_platforms = root//benchmark-platform:local\n[benchmark]\n  cache_uploads = #{phase == 'warm' ? 'false' : 'true'}\n")
    elsif tool == "sbt"
      path = "benchmark-cache.sbt"
      File.write(path, File.readlines(path).reject { |line| line.start_with?("Global / remoteCache :=") }.join)
    end
    args = ["boringcache", tool, "--fail-on-cache-error"]
    args << "--read-only" if phase == "warm"
    args
  end

  def self.managed_build(phase)
    remote_build(phase, provider: "boringcache", command: managed_command(phase, BenchmarkPhase.scope(ENV)))
  end

  def self.remote_build(phase, provider:, command:)
    FileUtils.mkdir_p("reapi-evidence")
    measurements = {"provider" => provider, "phase" => phase, "command" => command,
      "scope" => "Declared client operation including cache setup, build and publication",
      "restore_or_setup_seconds" => nil, "save_seconds" => nil, "success" => false}
    started = ReapiRegistry.elapsed
    File.open("reapi-evidence/build.log", "w") do |log|
      Open3.popen2e(*command) do |input, output, process|
        input.close
        output.each_line { |line| log.write(line); $stdout.write(line) }
        measurements["success"] = process.value.success?
      end
    end
    measurements["build_seconds"] = ReapiRegistry.elapsed - started
    raise Error, "Native build failed; see reapi-evidence/build.log" unless measurements["success"]
  ensure
    File.write("reapi-evidence/timing.json", JSON.pretty_generate(measurements) + "\n") if measurements
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
