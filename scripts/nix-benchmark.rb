# frozen_string_literal: true

require "json"
require "open3"
require "fileutils"
require "uri"
require "digest"
require_relative "benchmark-plan"

module NixBenchmark
  class Error < StandardError; end
  COMMON = %w[--no-update-lock-file --option accept-flake-config false].freeze

  def self.capture(*command)
    output, status = Open3.capture2(*command)
    raise Error, "#{command.first} failed (#{status.exitstatus})" unless status.success?
    output.strip
  end

  def self.run(*command)
    raise Error, "#{command.first} failed" unless system(*command)
  end

  def self.write(path, value)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(value) + "\n")
  end

  def self.closure(paths)
    return {} if paths.empty?
    all = capture("nix-store", "--query", "--requisites", *paths).lines.map(&:strip).uniq.sort
    all.each_slice(500).flat_map do |batch|
      hashes = capture("nix-store", "--query", "--hash", *batch).lines.map(&:strip)
      raise Error, "Incomplete NAR hash inventory" unless hashes.length == batch.length
      batch.zip(hashes)
    end.to_h
  end

  def self.prepare(seed: nil)
    recipe = BenchmarkPlan.load.fetch("adapters").fetch("nix")
    command = recipe.fetch("command")
    reference = command.fetch(2)
    raise Error, "Expected a pinned GitHub flake" unless reference.match?(%r{\Agithub:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/[0-9a-f]{40}#default\z})
    raise Error, "Expected Linux x86_64" unless capture("nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem") == "x86_64-linux"
    drv = capture("nix", "eval", "--raw", reference.sub(/#default\z/, "#packages.x86_64-linux.default.drvPath"), *COMMON)
    dependencies = capture("nix-store", "--query", "--references", drv).lines.map(&:strip)
    raise Error, "Derivation references itself" if dependencies.include?(drv)
    raise Error, "No declared build dependencies" if dependencies.empty?
    realized = capture("nix-store", "--realise", *dependencies).lines.map(&:strip)
    outputs = capture("nix-store", "--query", "--outputs", drv).lines.map(&:strip)
    raise Error, "Package output already exists before measurement" if outputs.any? { |path| File.exist?(path) }
    baseline = {"derivation" => drv, "outputs" => outputs, "dependencies" => closure(realized), "nix_version" => capture("nix", "--version")}
    if seed
      expected = JSON.parse(File.read(File.join(seed, "baseline.json")))
      raise Error, "Dependency seed differs from the declared workload" unless baseline == expected
    end
    write("nix-evidence/baseline.json", baseline)
  end

  def self.export_dependencies(directory: "nix-dependencies")
    baseline = JSON.parse(File.read("nix-evidence/baseline.json"))
    paths = baseline.fetch("dependencies").keys
    raise Error, "Dependency export includes the measured package" unless (paths & baseline.fetch("outputs")).empty?
    raise Error, "No dependency store paths to export" if paths.empty?
    FileUtils.mkdir_p(directory)
    archive = File.join(directory, "store.nar.zst")
    statuses = Open3.pipeline(["nix-store", "--export", *paths], ["zstd", "-T0", "-3", "-o", archive])
    raise Error, "Dependency export failed" unless statuses.all?(&:success?)
    write(File.join(directory, "baseline.json"), baseline)
    write(File.join(directory, "archive.json"), {"sha256" => Digest::SHA256.file(archive).hexdigest})
  end

  def self.import_dependencies(directory:)
    archive = File.join(directory, "store.nar.zst")
    expected = JSON.parse(File.read(File.join(directory, "archive.json"))).fetch("sha256")
    raise Error, "Dependency archive checksum differs" unless Digest::SHA256.file(archive).hexdigest == expected
    statuses = Open3.pipeline(["zstd", "-dc", archive], ["nix-store", "--import"])
    raise Error, "Dependency import failed" unless statuses.all?(&:success?)
    prepare(seed: directory)
  end

  def self.provider_substituter(config, provider, cache_name)
    urls = %w[substituters extra-substituters].flat_map do |name|
      value = config.dig(name, "value")
      value.is_a?(Array) ? value : value.to_s.split
    end.uniq
    matches = urls.select do |url|
      uri = URI.parse(url)
      if provider == "boringcache"
        uri.scheme == "http" && uri.host == "127.0.0.1" && uri.path == "/nix"
      elsif provider == "cachix"
        uri.scheme == "https" && uri.host == "#{cache_name}.cachix.org"
      end
    end
    raise Error, "Expected exactly one #{provider} Nix substituter" unless matches.length == 1
    matches.first
  end

  def self.build_command(phase:, provider:, cache_name: "")
    raise Error, "Use cold, warm or commit" unless %w[cold warm commit].include?(phase)
    command = BenchmarkPlan.command("nix").dup
    if phase == "cold"
      command += %w[--option substitute false]
    else
      config = JSON.parse(capture("nix", "config", "show", "--json"))
      url = provider_substituter(config, provider, cache_name)
      command += ["--option", "substituters", url, "--option", "extra-substituters", ""]
      command += ["--max-jobs", "0", "--builders", ""] if phase == "warm"
    end
    command
  end

  def self.build(phase:, provider:, cache_name: "")
    baseline = JSON.parse(File.read("nix-evidence/baseline.json"))
    raise Error, "Package output already exists before measurement" if baseline.fetch("outputs").any? { |path| File.exist?(path) }
    command = build_command(phase: phase, provider: provider, cache_name: cache_name)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    success = false
    File.open("nix-evidence/build.log", "w") do |log|
      Open3.popen2e(*command) do |input, output, process|
        input.close
        output.each_line { |line| log.write(line); $stdout.write(line) }
        success = process.value.success?
      end
    end
    write("nix-evidence/timing.json", {"command" => command, "build_seconds" => Process.clock_gettime(Process::CLOCK_MONOTONIC) - started, "success" => success})
    raise Error, "Nix build failed; logs and timing were retained" unless success
  end

  def self.verify(phase:, provider:, cache_name: "")
    recipe = JSON.parse(File.read("nix-recipe.json"))
    executable = recipe.fetch("executable")
    raise Error, "Invalid executable name" unless executable.match?(/\A[a-z][a-z0-9-]*\z/)
    output = File.realpath("result")
    baseline = JSON.parse(File.read("nix-evidence/baseline.json"))
    raise Error, "Unexpected package output" unless baseline.fetch("outputs").include?(output)
    version = capture(File.join(output, "bin", executable), "--version")
    raise Error, "Empty package version" if version.empty?
    if phase == "warm"
      log = File.read("nix-evidence/build.log")
      config = JSON.parse(capture("nix", "config", "show", "--json"))
      url = provider_substituter(config, provider, cache_name)
      expected = "copying path '#{output}' from '#{url.split('?').first}"
      raise Error, "No selected-provider substitution for the package output" unless log.include?(expected)
    end
    write("nix-evidence/output.json", {"output" => output, "closure" => closure([output]), "version" => version})
  end

  def self.compare(seed:, current: "nix-evidence")
    %w[baseline output].each do |name|
      expected = JSON.parse(File.read(File.join(seed, "#{name}.json")))
      actual = JSON.parse(File.read(File.join(current, "#{name}.json")))
      raise Error, "Nix #{name} differs from the cold observation" unless expected == actual
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    case ARGV.shift
    when "prepare" then NixBenchmark.prepare
    when "export-dependencies" then NixBenchmark.export_dependencies
    when "import-dependencies" then NixBenchmark.import_dependencies(directory: ARGV.fetch(0))
    when "build" then NixBenchmark.build(phase: ENV.fetch("NIX_PHASE"), provider: ENV.fetch("NIX_PROVIDER"), cache_name: ENV.fetch("CACHIX_CACHE", ""))
    when "verify" then NixBenchmark.verify(phase: ENV.fetch("NIX_PHASE"), provider: ENV.fetch("NIX_PROVIDER"), cache_name: ENV.fetch("CACHIX_CACHE", ""))
    when "compare" then NixBenchmark.compare(seed: ARGV.fetch(0))
    else raise NixBenchmark::Error, "Use prepare, build, verify or compare"
    end
  rescue NixBenchmark::Error, KeyError, ArgumentError => error
    abort error.message
  end
end
