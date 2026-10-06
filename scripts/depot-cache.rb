# frozen_string_literal: true

require "json"
require "fileutils"
require "uri"
require "shellwords"
require "open3"

# Third-party cache configuration. BoringCache configuration stays in the CLI.
module DepotCache
  class Error < StandardError; end
  ENDPOINT = "https://cache.depot.dev"
  RUNNERS = %w[depot-ubuntu-24.04-4 depot-ubuntu-24.04-8].freeze
  NATIVE = %w[go gradle maven turbo nx bazel moon pants sccache].freeze
  ENVIRONMENT = %w[GOCACHEPROG TURBO_API TURBO_TOKEN TURBO_TEAM NX_SELF_HOSTED_REMOTE_CACHE_SERVER
    NX_SELF_HOSTED_REMOTE_CACHE_ACCESS_TOKEN MOON_REMOTE_HOST MOON_REMOTE_AUTH_TOKEN SCCACHE_WEBDAV_ENDPOINT SCCACHE_WEBDAV_TOKEN
    SCCACHE_WEBDAV_USERNAME SCCACHE_WEBDAV_PASSWORD].freeze

  def self.environment(mode, env: ENV)
    raise Error, "Unsupported Depot native cache mode: #{mode}" unless NATIVE.include?(mode)
    token = env.fetch("DEPOT_CACHE_TOKEN", "")
    token = env.fetch("DEPOT_TOKEN", "") if token.empty?
    raise Error, "Depot native cache requires DEPOT_TOKEN" if token.empty?
    raise Error, "Cache credentials must be single-line" if token.include?("\n") || token.include?("\r")
    settings = case mode
    when "go" then {"GOCACHEPROG" => "depot gocache --verbose"}
    when "turbo"
      team = env.fetch("DEPOT_ORGANIZATION_ID", "")
      team = env.fetch("TURBO_TEAM", "") if team.empty?
      raise Error, "Depot Turborepo cache requires an organization ID" if team.empty?
      {"TURBO_API" => ENDPOINT, "TURBO_TOKEN" => token, "TURBO_TEAM" => team}
    when "nx"
      {"NX_SELF_HOSTED_REMOTE_CACHE_SERVER" => ENDPOINT, "NX_SELF_HOSTED_REMOTE_CACHE_ACCESS_TOKEN" => token}
    when "sccache"
      {"SCCACHE_GHA_ENABLED" => "false", "SCCACHE_WEBDAV_ENDPOINT" => ENDPOINT, "SCCACHE_WEBDAV_TOKEN" => token, "RUSTC_WRAPPER" => "sccache"}
    else {}
    end
    settings.merge("DEPOT_TOKEN" => token)
  end

  def self.configure(mode, phase:, env: ENV, root: Dir.pwd)
    settings = environment(mode, env: env)
    raise Error, "Use publish, warm, cold or commit" unless %w[publish warm cold commit].include?(phase)
    publish = phase != "warm"
    case mode
    when "gradle"
      path = File.join(env.fetch("GRADLE_USER_HOME"), "init.d/benchmark-cache-policy.gradle")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, <<~GRADLE)
        import org.gradle.caching.http.HttpBuildCache
        gradle.settingsEvaluated { settings ->
            settings.buildCache {
                local { enabled = false }
                remote(HttpBuildCache) {
                    url = '#{ENDPOINT}'
                    enabled = true
                    push = #{publish}
                    credentials { username = ''; password = System.getenv('DEPOT_TOKEN') }
                }
            }
        }
      GRADLE
      File.open(File.join(env.fetch("GRADLE_USER_HOME"), "gradle.properties"), "a") { |file| file.puts("org.gradle.caching=true\norg.gradle.daemon=false") }
    when "maven"
      config = File.join(root, "upstream/.mvn/maven-build-cache-config.xml")
      FileUtils.mkdir_p(File.dirname(config))
      extension = File.join(root, "upstream/.mvn/extensions.xml")
      if File.file?(extension)
        raise Error, "Maven requires the upstream build-cache extension" unless File.read(extension).include?("<artifactId>maven-build-cache-extension</artifactId>")
      else
        File.write(extension, '<extensions><extension><groupId>org.apache.maven.extensions</groupId><artifactId>maven-build-cache-extension</artifactId><version>1.3.0</version></extension></extensions>')
      end
      contents = File.file?(config) ? File.read(config) : '<cache xmlns="http://maven.apache.org/BUILD-CACHE-CONFIG/1.0.0"><configuration><enabled>true</enabled><hashAlgorithm>SHA-256</hashAlgorithm><remote enabled="true"><url>https://cache.depot.dev</url></remote></configuration></cache>'
      raise Error, "Maven configuration must declare one remote cache" unless contents.scan(/<remote\b/).length == 1
      contents = contents.sub(/<remote\b[^>]*>.*?<\/remote>/m, %(<remote enabled="true" saveToRemote="#{publish}" id="depot-cache"><url>#{ENDPOINT}</url></remote>))
      File.write(config, contents)
      settings_path = File.join(root, ".depot-cache/maven-settings.xml")
      FileUtils.mkdir_p(File.dirname(settings_path))
      File.write(settings_path, <<~XML)
        <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"><servers><server><id>depot-cache</id><configuration><httpHeaders><property><name>Authorization</name><value>Bearer ${env.DEPOT_TOKEN}</value></property></httpHeaders></configuration></server></servers></settings>
      XML
      settings["MAVEN_ARGS"] = "--settings #{settings_path}"
      settings["MAVEN_OPTS"] = "-Dmaven.build.cache.enabled=true -Dmaven.build.cache.remote.enabled=true -Dmaven.build.cache.remote.save.enabled=#{publish}"
    when "go"
      raise Error, "Depot runner did not provide the Go cache helper" unless system("depot", "gocache", "--help", out: File::NULL, err: File::NULL)
    end
    settings
  end

  def self.write_tool_secret(mode, env: ENV, path: ".depot-cache/tool-cache-env")
    settings = environment(mode, env: env)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, settings.map { |key, value| "export #{key}=#{Shellwords.escape(value)}" }.join("\n") + "\n", perm: 0o600)
    path
  end

  def self.write_environment(settings, env: ENV)
    settings.each do |key, value|
      raise Error, "Cache environment values must be single-line" if value.include?("\n") || value.include?("\r")
    end
    File.open(env.fetch("GITHUB_ENV"), "a") { |file| settings.each { |key, value| file.puts("#{key}=#{value}") } }
  end

  def self.prepare(provider:, mode:, phase:, env: ENV)
    return unless RUNNERS.include?(env.fetch("BENCHMARK_RUNNER_CLASS", "")) || provider.start_with?("depot-")
    raise Error, "Depot cache lanes require a reviewed Depot runner" unless RUNNERS.include?(env.fetch("BENCHMARK_RUNNER_CLASS", ""))
    if provider == "depot-cache"
      settings = configure(mode, phase: phase, env: env)
    else
      # Remove runner defaults before another provider configures its own cache.
      settings = ENVIRONMENT.to_h { |key| [key, ""] }
      raise Error, "Depot runners use Depot Cache for the Actions API; select depot-actions-cache explicitly" if provider == "actions-cache"
      if provider == "depot-actions-cache"
        urls = %w[ACTIONS_CACHE_URL ACTIONS_RESULTS_URL].filter_map { |name| URI.parse(env.fetch(name, "")).host }
        raise Error, "Runner did not expose a Depot Actions cache endpoint; observed hosts: #{urls.join(', ')}" unless urls.any? { |host| host == "depot.dev" || host.end_with?(".depot.dev") }
      end
    end
    FileUtils.mkdir_p(".depot-cache")
    File.write(".depot-cache/configuration.json", JSON.pretty_generate({"provider" => provider,
      "mode" => mode, "protocol" => provider == "depot-cache" ? "native" : "github-actions-cache-api",
      "endpoint_host" => provider == "depot-cache" ? "cache.depot.dev" : urls.find { |host| host == "depot.dev" || host.end_with?(".depot.dev") }, "isolation" => provider == "depot-cache" ? "unmeasured" : "declared-cache-key",
      "authentication" => provider == "depot-cache" ? (env.fetch("DEPOT_CACHE_TOKEN", "").empty? ? "configured-token" : "job-token") : "actions-runtime",
      "runner_class" => env.fetch("BENCHMARK_RUNNER_CLASS")}) + "\n") if provider.start_with?("depot-")
    puts "::add-mask::#{settings.fetch('DEPOT_TOKEN')}" if env["GITHUB_ACTIONS"] == "true" && settings["DEPOT_TOKEN"]
    write_environment(settings, env: env)
    settings
  rescue URI::InvalidURIError
    raise Error, "Runner cache endpoint is invalid"
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    DepotCache.write_tool_secret("turbo") if ENV["DEPOT_CONTAINER_TOOL_CACHE"] == "turbo"
    DepotCache.prepare(provider: ENV.fetch("CACHE_PROVIDER"), mode: ENV.fetch("CACHE_MODE"), phase: ENV.fetch("CACHE_PHASE"))
  rescue DepotCache::Error => error
    abort error.message
  end
end
