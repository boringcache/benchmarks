# frozen_string_literal: true

require "digest"
require "fileutils"
require "tmpdir"

module CompilerCacheSetup
  TOOLS = {
    "kache" => ["kunobi-ninja/kache", "v0.28.1", "68635a9f92ce5015a2c48c98b968d1b3707b6dbee0ca725e51d1671c9346f38f"],
    "mbx" => ["jdx/mr-boxington", "v1.22.0", "c375135e2a3916f58da1b47537b6a954159eeacd55523d9a618b42259bd89014"]
  }.freeze

  def self.install(engine)
    return if engine == "sccache"
    repository, version, digest = TOOLS.fetch(engine)
    raise "Compiler qualification requires Linux x86_64" unless RUBY_PLATFORM.match?(/x86_64-linux/)
    destination = File.join(ENV.fetch("RUNNER_TEMP"), "benchmark-compiler")
    FileUtils.mkdir_p(destination)
    Dir.mktmpdir("compiler-download-") do |directory|
      asset = "#{engine}-x86_64-unknown-linux-musl.tar.gz"
      raise "Compiler download failed" unless system("gh", "release", "download", version, "--repo", repository,
        "--pattern", asset, "--dir", directory)
      archive = File.join(directory, asset)
      raise "Compiler checksum differs" unless Digest::SHA256.file(archive).hexdigest == digest
      raise "Compiler extraction failed" unless system("tar", "-xzf", archive, "-C", destination, engine)
    end
    File.open(ENV.fetch("GITHUB_PATH"), "a") { |file| file.puts(destination) }
    raise "Compiler version check failed" unless system(File.join(destination, engine), "--version")
  end
end

CompilerCacheSetup.install(ARGV.fetch(0)) if $PROGRAM_NAME == __FILE__
