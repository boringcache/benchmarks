# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "tmpdir"

module BenchmarkCandidate
  VERSION = "vcli-canary-b26bccd2becb"
  SOURCE = "b26bccd2becbe87f0a800e3e690f19696dc9198f"
  RELEASE = "evidence-native-adapters-2026-10-05"
  SHA256 = "3dc95756acecffda76c0e107d69c9e0ea1969fddd0e9b301598cfa8af3023e09"

  def self.install(version, destination: nil)
    raise "Unknown retained candidate: #{version}" unless version == VERSION
    raise "Retained benchmark candidate requires Linux x86_64" unless RUBY_PLATFORM.match?(/x86_64-linux/)
    destination ||= File.join(ENV.fetch("RUNNER_TEMP"), "benchmark-candidate", "boringcache")
    FileUtils.mkdir_p(File.dirname(destination))
    Dir.mktmpdir("benchmark-candidate-") do |directory|
      asset = "boringcache-linux-amd64"
      raise "Candidate download failed" unless system("gh", "release", "download", RELEASE,
        "--repo", "boringcache/benchmarks", "--pattern", asset, "--dir", directory)
      path = File.join(directory, asset)
      raise "Candidate checksum differs" unless Digest::SHA256.file(path).hexdigest == SHA256
      FileUtils.cp(path, destination)
      File.chmod(0o755, destination)
    end
    File.open(ENV.fetch("GITHUB_PATH"), "a") { |file| file.puts(File.dirname(destination)) }
    FileUtils.mkdir_p("benchmark-results")
    File.write("benchmark-results/candidate.json", JSON.pretty_generate({"source_sha" => SOURCE,
      "canary_tag" => VERSION, "sha256" => SHA256,
      "artifact_id" => "art_14d8222421d1a123ab25b729"}) + "\n")
    {"repository" => "boringcache/benchmarks", "release" => RELEASE, "asset" => "boringcache-linux-amd64", "sha256" => SHA256}
  end
end

BenchmarkCandidate.install(ARGV.fetch(0)) if $PROGRAM_NAME == __FILE__
