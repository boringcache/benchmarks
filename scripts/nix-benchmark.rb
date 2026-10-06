# frozen_string_literal: true

require "json"
require "open3"
require "fileutils"
require "uri"
require "digest"
require "net/http"
require "timeout"
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
    config = JSON.parse(capture("nix", "config", "show", "--json"))
    url = provider_substituter(config, provider, cache_name)
    state = cache_state(baseline, log: File.read("nix-evidence/build.log"), substituter: url)
    raise Error, "No selected-provider substitution for the package output" if phase == "warm" && state.fetch("hit") != true
    write("nix-evidence/cache-state.json", state)
    write("nix-evidence/output.json", {"output" => output, "closure" => closure([output]), "version" => version})
  end

  def self.cache_state(baseline, log:, substituter:)
    outputs = baseline.fetch("outputs")
    restored = !outputs.empty? && outputs.all? do |output|
      log.include?("copying path '#{output}' from '#{substituter.split('?').first}")
    end
    built = log.include?("building '#{baseline.fetch('derivation')}'")
    {"hit" => restored ? true : (built ? false : nil),
      "operation" => restored ? "substituted" : (built ? "built" : "unobserved"),
      "outputs" => outputs, "substituter" => substituter}
  end

  def self.cachix_storage(cache_name, paths:, fetch: method(:narinfo))
    raise Error, "Invalid Cachix cache name" unless cache_name.match?(/\A[a-z0-9][a-z0-9-]*\z/)
    observations = paths.sort.map do |path|
      match = File.basename(path).match(/\A([a-z0-9]{32})-/)
      raise Error, "Invalid Nix store path" unless path.start_with?("/nix/store/") && match
      fields = fetch.call("https://#{cache_name}.cachix.org/#{match[1]}.narinfo")
      size = fields["FileSize"]
      {"store_path" => path, "url" => fields["URL"], "file_size" => size&.match?(/\A\d+\z/) ? Integer(size) : nil,
        "nar_size" => fields["NarSize"], "nar_hash" => fields["NarHash"]}
    end
    complete = !observations.empty? && observations.all? { |value| value["file_size"] && value["url"] }
    sizes = observations.uniq { |value| value["url"] }.filter_map { |value| value["file_size"] }
    {"bytes" => complete ? sizes.sum : nil, "source" => "cachix-narinfo-file-size",
      "breakdown" => {"scope" => "Selected package runtime closure; provider compressed NAR files, not account billing",
        "complete" => complete, "measured_bytes" => sizes.sum, "observations" => observations}}
  end

  def self.narinfo(url)
    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) { |http| http.get(uri.request_uri) }
    return {} unless response.is_a?(Net::HTTPSuccess)
    response.body.lines.to_h { |line| key, value = line.strip.split(": ", 2); [key, value] }
  rescue IOError, SystemCallError, Timeout::Error
    {}
  end

  def self.publish_and_measure(phase:, cache_name:)
    output = JSON.parse(File.read("nix-evidence/output.json"))
    unless phase == "warm"
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      run("cachix", "push", cache_name, output.fetch("output"))
      timing = JSON.parse(File.read("nix-evidence/timing.json"))
      timing["save_seconds"] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
      write("nix-evidence/timing.json", timing)
    end
    value = Timeout.timeout(120) { cachix_storage(cache_name, paths: output.fetch("closure").keys) }
    write("nix-evidence/storage.json", value)
  rescue Timeout::Error
    write("nix-evidence/storage.json", {"bytes" => nil, "source" => "cachix-narinfo-file-size",
      "breakdown" => {"complete" => false, "reason" => "Narinfo measurement exceeded 120 seconds"}})
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
    when "publish-and-measure" then NixBenchmark.publish_and_measure(phase: ENV.fetch("NIX_PHASE"), cache_name: ENV.fetch("CACHIX_CACHE"))
    when "compare" then NixBenchmark.compare(seed: ARGV.fetch(0))
    else raise NixBenchmark::Error, "Use prepare, export-dependencies, import-dependencies, build, verify, publish-and-measure or compare"
    end
  rescue NixBenchmark::Error, KeyError, ArgumentError => error
    abort error.message
  end
end
