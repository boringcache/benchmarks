require "digest"
require "fileutils"
require "json"
require "open3"

class RegistrySource
  IMAGE = "posthog-benchmark:local"

  def self.export(directory, commit:, run_id:)
    output, status = Open3.capture2("docker", "image", "inspect", IMAGE)
    raise "PostHog image inspection failed" unless status.success?
    image = JSON.parse(output).fetch(0)
    raise "registry comparison requires linux/amd64" unless image.values_at("Os", "Architecture") == %w[linux amd64]

    FileUtils.mkdir_p(directory)
    archive = File.join(directory, "image.tar.gz")
    statuses = Open3.pipeline(["docker", "image", "save", IMAGE], ["gzip", "-1"], out: archive)
    raise "PostHog image export failed" unless statuses.all?(&:success?)
    config = { "source" => IMAGE, "source_commit" => commit, "source_run_id" => run_id,
      "image_id" => image.fetch("Id"), "platform" => "linux/amd64",
      "image_bytes" => image.fetch("Size"), "source_archive_bytes" => File.size(archive),
      "archive_sha256" => Digest::SHA256.file(archive).hexdigest }
    validate(config, run_id:)
    File.write(File.join(directory, "source.json"), JSON.pretty_generate(config) + "\n")
  end

  def self.validate(config, run_id:)
    raise "unexpected source run" unless run_id.match?(/\A\d+\z/) && config.fetch("source_run_id") == run_id
    raise "unexpected source image" unless config.fetch("source") == IMAGE && config.fetch("platform") == "linux/amd64"
    raise "invalid source commit" unless config.fetch("source_commit").match?(/\A[a-f0-9]{40}\z/)
    raise "invalid image id" unless config.fetch("image_id").match?(/\Asha256:[a-f0-9]{64}\z/)
    raise "invalid archive checksum" unless config.fetch("archive_sha256").match?(/\A[a-f0-9]{64}\z/)
    config
  end

  def self.config(directory, run_id:)
    validate(JSON.parse(File.read(File.join(directory, "source.json"))), run_id:)
      .slice("source", "source_commit", "source_run_id", "image_id", "platform", "image_bytes", "source_archive_bytes", "archive_sha256")
  end

  def self.load(directory, config:)
    archive = File.join(directory, "image.tar.gz")
    raise "PostHog image archive checksum differs" unless Digest::SHA256.file(archive).hexdigest == config.fetch("archive_sha256")
    raise "PostHog image load failed" unless system("docker", "image", "load", "--input", archive)
  end
end

if $PROGRAM_NAME == __FILE__
  commit, status = Open3.capture2("git", "-C", File.join(ENV.fetch("BENCH_DIR"), "upstream"), "rev-parse", "HEAD")
  raise "PostHog source commit lookup failed" unless status.success?
  RegistrySource.export(ARGV.fetch(0), commit: commit.strip, run_id: ENV.fetch("GITHUB_RUN_ID"))
end
