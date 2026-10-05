# frozen_string_literal: true

require "json"
require "digest"
require "fileutils"
require "tmpdir"
require "open3"
require_relative "reapi-client"

module ReapiSetup
  def self.run(*command)
    raise "Command failed: #{command.first}" unless system(*command)
  end

  def self.download(repository, release, asset, binary, sha256: nil, destination: nil)
    Dir.mktmpdir("reapi-download-") do |directory|
      run("gh", "release", "download", release, "--repo", repository, "--pattern", asset, "--dir", directory)
      path = File.join(directory, asset)
      unless sha256
        run("gh", "release", "download", release, "--repo", repository, "--pattern", "SHA256SUMS", "--dir", directory)
        rows = File.readlines(File.join(directory, "SHA256SUMS")).map(&:split)
        sha256 = rows.find { |row| row[1] == asset }&.first
      end
      raise "Release checksum is missing or different: #{asset}" unless sha256&.match?(/\A[0-9a-f]{64}\z/) && Digest::SHA256.file(path).hexdigest == sha256
      destination ||= File.join(ENV.fetch("RUNNER_TEMP"), "reapi-bin", binary)
      FileUtils.mkdir_p(File.dirname(destination))
      if asset.end_with?(".zst")
        run("zstd", "-d", path, "-o", destination)
      else
        FileUtils.cp(path, destination)
      end
      File.chmod(0o755, destination)
      {"repository" => repository, "release" => release, "asset" => asset, "sha256" => sha256}
    end
  end

  def self.install
    FileUtils.mkdir_p("reapi-evidence")
    installed = []
    if ENV.fetch("PROVIDER") == "boringcache"
      release = ENV.fetch("CLI_RELEASE")
      raise "Select an exact CLI release" unless release.match?(/\Av(?:cli-canary-[0-9a-f]{9,40}|\d+\.\d+\.\d+)\z/)
      installed << download("boringcache/cli", release, "boringcache-linux-amd64", "boringcache")
    else
      installed << download("buchgr/bazel-remote", "v2.6.2", "bazel-remote-2.6.2-linux-amd64", "bazel-remote",
        sha256: "62e236bf8396e69396928e0d0c32062fbd5575f20fe55dc10a82eb791297e1a0")
    end
    case ReapiClient.recipe.fetch("tool")
    when "buck2"
      installed << download("facebook/buck2", "2025-06-01", "buck2-x86_64-unknown-linux-musl.zst", "buck2",
        sha256: "7127a64ce1341b2df4d85fd656dd5200c06777512edc605005e362d5f485de76")
    when "pants"
      installed << download("pantsbuild/scie-pants", "v0.13.2", "scie-pants-linux-x86_64", "pants",
        sha256: "74a1e53bc50d6ef6ce1bc67bd9f7b48e549505e0a2453ad4d5ccbc72b0bea874")
    end
    File.write("reapi-evidence/downloads.json", JSON.pretty_generate(installed) + "\n")
    File.open(ENV.fetch("GITHUB_PATH"), "a") { |file| file.puts(File.join(ENV.fetch("RUNNER_TEMP"), "reapi-bin")) }
  end

  def self.prepare
    ReapiClient.recipe.fetch("prepare").each { |command| run(*command) }
  end

  def self.rolling_seed
    context = JSON.parse(File.read("benchmark-context.json"))
    path = "reapi-store/benchmark-source.json"
    previous = File.file?(path) ? JSON.parse(File.read(path)) : nil
    if previous && previous.fetch("case_id") != ENV.fetch("BENCHMARK_ID")
      raise "Rolling comparator seed belongs to another case"
    end
    seed = {"cache_key" => ENV.fetch("RESTORED_CACHE_KEY", ""), "previous" => previous,
      "current" => {"case_id" => ENV.fetch("BENCHMARK_ID"), "source" => context.fetch("source"),
        "run_id" => ENV.fetch("GITHUB_RUN_ID"), "run_attempt" => ENV.fetch("GITHUB_RUN_ATTEMPT")}}
    File.write("reapi-evidence/rolling-seed.json", JSON.pretty_generate(seed) + "\n")
  end

  def self.publish_seed
    seed = JSON.parse(File.read("reapi-evidence/rolling-seed.json"))
    FileUtils.mkdir_p("reapi-store")
    File.write("reapi-store/benchmark-source.json", JSON.pretty_generate(seed.fetch("current")) + "\n")
  end

  def self.report
    require_relative "benchmark-report"
    context = JSON.parse(File.read("benchmark-context.json"))
    timings = JSON.parse(File.read("reapi-evidence/timing.json"))
    args = ["phase", "--verified-output", "--benchmark", ENV.fetch("BENCHMARK_ID"), "--strategy", ENV.fetch("PROVIDER"),
      "--lane", ENV.fetch("CACHE_LANE", "fresh"), "--phase", ENV.fetch("PHASE"), "--mode", "reapi",
      "--workspace", "boringcache/benchmarks", "--cache-tag", BenchmarkPhase.scope(ENV),
      "--source-repository", context.dig("source", "repository"), "--source-sha", context.dig("source", "revision"),
      "--build-seconds", timings.fetch("build_seconds").to_s, "--restore-or-setup-seconds", timings.fetch("restore_or_setup_seconds").to_s,
      "--save-seconds", timings.fetch("save_seconds").to_s]
    args += ["--cache-hit", "true"] if ReapiClient.remote_cache_hit?
    if ENV.fetch("PROVIDER") == "boringcache"
      version, status = Open3.capture2("boringcache", "--version")
      raise "Cannot read CLI version" unless status.success?
      args += ["--cli-version", version.strip.delete_prefix("boringcache ")]
    end
    _, options = BenchmarkReport.options(args)
    BenchmarkReport.phase(options)
  end
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "install" then ReapiSetup.install
  when "prepare" then ReapiSetup.prepare
  when "report" then ReapiSetup.report
  when "rolling-seed" then ReapiSetup.rolling_seed
  when "publish-seed" then ReapiSetup.publish_seed
  else abort "Use install, prepare or report"
  end
end
