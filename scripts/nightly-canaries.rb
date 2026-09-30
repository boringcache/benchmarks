#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require_relative "publish-index"

module NightlyCanaries
  class Error < StandardError; end

  class Runner
    def api(path, body: nil)
      args = ["gh", "api", path]
      args += ["--method", "POST", "--input", "-"] if body
      output, error, status = Open3.capture3(*args, stdin_data: body ? JSON.generate(body) : "")
      raise Error, "GitHub request failed: #{error.strip}" unless status.success?
      output.empty? ? {} : JSON.parse(output)
    end

    def latest_canary
      releases = api("repos/boringcache/cli/releases?per_page=100")
      release = releases.reject { |item| item["draft"] }.select do |item|
        item["prerelease"] && item.fetch("tag_name").match?(/\Avcli-canary-[0-9a-f]{9,40}\z/)
      end.max_by { |item| item.fetch("published_at") }
      raise Error, "No published CLI canary found" unless release
      published_canary(release)
    end

    def published_canary(release)
      unless release["prerelease"] && !release["draft"] && release.fetch("tag_name").match?(/\Avcli-canary-[0-9a-f]{9,40}\z/)
        raise Error, "Use a published CLI canary"
      end
      names = release.fetch("assets").map { |asset| asset.fetch("name") }
      required = %w[SHA256SUMS boringcache-linux-amd64 boringcache-linux-arm64 boringcache-macos-universal boringcache-windows-amd64.exe]
      raise Error, "The CLI canary is missing release assets" unless (required - names).empty?
      release.fetch("tag_name")
    end

    def dispatch(output:, summary:, version: nil, dry_run: false, benchmarks: BENCHMARKS)
      if version.nil? || version.empty?
        version = latest_canary
      else
        raise Error, "Use an exact CLI canary tag" unless version.match?(/\Avcli-canary-[0-9a-f]{9,40}\z/)
        published_canary(api("repos/boringcache/cli/releases/tags/#{version}"))
      end
      targets = benchmarks.map { |item| item.values_at("source_repo", "fresh_workflow") }.uniq
      record = {"cli_version" => version, "created_at" => Time.now.utc.iso8601,
                "state" => "dispatching", "runs" => []}
      targets.each do |repository, workflow|
        raise Error, "Benchmark lacks a fresh workflow" if repository.nil? || workflow.nil?
        record["runs"] << {"repository" => repository, "workflow" => workflow, "state" => "planned"}
      end
      write(output, record)
      # Validate every target before starting any expensive builds.
      record["runs"].each do |run|
        workflow = api("repos/#{run.fetch('repository')}/actions/workflows/#{run.fetch('workflow')}")
        raise Error, "#{run.fetch('repository')} workflow is not active" unless workflow["state"] == "active"
      end
      record["runs"].each do |run|
        next if dry_run
        result = api("repos/#{run.fetch('repository')}/actions/workflows/#{run.fetch('workflow')}/dispatches",
          body: {"ref" => "main", "inputs" => {"cli_version" => version}, "return_run_details" => true})
        id = result["workflow_run_id"]
        raise Error, "Dispatch returned no run ID; inspect the workflow before retrying" unless id.is_a?(Integer)
        run.merge!("id" => id, "url" => "https://github.com/#{run.fetch('repository')}/actions/runs/#{id}", "state" => "requested")
        write(output, record)
      end
      record["state"] = dry_run ? "planned" : "requested"
      write(output, record)
      write_summary(summary, record)
      record
    rescue StandardError => error
      if record
        record["state"] = "dispatch-failed"
        record["error"] = error.message
        write(output, record)
        write_summary(summary, record)
      end
      raise
    end

    def check(record, summary:)
      raise Error, "The dispatch receipt has no runs" if record.fetch("runs").empty?
      record.fetch("runs").each do |run|
        next unless run["id"]
        current = api("repos/#{run.fetch('repository')}/actions/runs/#{run.fetch('id')}")
        run["source_sha"] = current.fetch("head_sha")
        run["state"] = current["status"] == "completed" ? current.fetch("conclusion") : current.fetch("status")
      end
      write_summary(summary, record)
      record["state"] == "requested" && record.fetch("runs").all? { |run| %w[requested queued pending waiting in_progress success].include?(run["state"]) }
    end

    def write(path, record)
      File.write(path, JSON.pretty_generate(record) + "\n")
    end

    def write_summary(path, record)
      return unless path
      lines = ["## CLI canary benchmarks", "", "CLI: `#{record.fetch('cli_version')}`", "",
               "Dispatch: **#{record.fetch('state')}**. Benchmark outcomes are listed separately.", ""]
      record.fetch("runs").each do |run|
        name = "#{run.fetch('repository')} / #{run.fetch('workflow')}"
        name = "[#{name}](#{run.fetch('url')})" if run["url"]
        lines << "- #{name}: **#{run.fetch('state')}**"
      end
      lines += ["", record["error"]] if record["error"]
      File.write(path, lines.join("\n") + "\n")
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {output: "nightly-canaries.json"}
  OptionParser.new do |parser|
    parser.on("--version TAG") { |value| options[:version] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--summary PATH") { |value| options[:summary] = value }
    parser.on("--dry-run") { options[:dry_run] = true }
    parser.on("--check PATH") { |value| options[:check] = value }
  end.parse!
  begin
    runner = NightlyCanaries::Runner.new
    if options[:check]
      exit(runner.check(JSON.parse(File.read(options[:check])), summary: options[:summary]) ? 0 : 1)
    else
      raise NightlyCanaries::Error, "Inspect the retained dispatch receipt before retrying; reruns can start duplicate benchmarks" if ENV.fetch("GITHUB_RUN_ATTEMPT", "1").to_i > 1 && !options[:dry_run]
      runner.dispatch(**options)
    end
  rescue NightlyCanaries::Error, KeyError, JSON::ParserError => error
    abort error.message
  end
end
