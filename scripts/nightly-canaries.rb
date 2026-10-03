#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "set"
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

    def targets(benchmarks)
      benchmarks.reject { |item| item["archived"] }.map do |item|
        inputs = item.fetch("fresh_inputs", {})
        unless inputs.is_a?(Hash) && inputs.all? { |key, value| key.is_a?(String) && value.is_a?(String) } && !inputs.key?("cli_version")
          raise Error, "Fresh workflow selectors must be string inputs; cli_version belongs to the dispatch"
        end
        inputs = inputs.dup
        if item.fetch("fresh_workflow").start_with?("native-")
          id = item.fetch("case_id")
          raise Error, "Fresh workflow selector belongs to another case" if inputs.key?("case_id") && inputs["case_id"] != id
          inputs["case_id"] = id
        end
        [item.fetch("source_repo"), item.fetch("fresh_workflow"), inputs]
      end.uniq
    end

    def dispatch(repository:, output:, summary: nil, version: nil, dry_run: false, benchmarks: BENCHMARKS)
      selected = targets(benchmarks).select { |repo, _| repo == repository }
      raise Error, "No active fresh workflows registered for #{repository}" if selected.empty?
      if version.nil? || version.empty?
        version = latest_canary
      else
        raise Error, "Use an exact CLI canary tag" unless version.match?(/\Avcli-canary-[0-9a-f]{9,40}\z/)
        published_canary(api("repos/boringcache/cli/releases/tags/#{version}"))
      end
      record = {"cli_version" => version, "created_at" => Time.now.utc.iso8601,
                "state" => "dispatching", "runs" => []}
      selected.each do |repository, workflow, inputs|
        raise Error, "Benchmark lacks a fresh workflow" if repository.nil? || workflow.nil?
        record["runs"] << {"repository" => repository, "workflow" => workflow, "inputs" => inputs, "state" => "planned"}
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
          body: {"ref" => "main", "inputs" => run.fetch("inputs").merge("cli_version" => version), "return_run_details" => true})
        id = result["workflow_run_id"]
        raise Error, "Dispatch returned no run ID; inspect the workflow before retrying" unless id.is_a?(Integer) && id.positive?
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
        raise Error, "Dispatch receipt has an invalid run ID" unless run["id"].is_a?(Integer) && run["id"].positive?
        current = api("repos/#{run.fetch('repository')}/actions/runs/#{run.fetch('id')}")
        run["source_sha"] = current.fetch("head_sha")
        run["state"] = current["status"] == "completed" ? current.fetch("conclusion") : current.fetch("status")
      end
      write_summary(summary, record)
      record["state"] == "requested" && record.fetch("runs").all? { |run| %w[requested queued pending waiting in_progress success].include?(run["state"]) }
    end

    def receipt(repository, run_id)
      Dir.mktmpdir("canary-receipt-") do |directory|
        _, error, status = Open3.capture3("gh", "run", "download", run_id.to_s,
          "--repo", repository, "--name", "nightly-canaries", "--dir", directory)
        raise Error, "Cannot read dispatch receipt: #{error.strip}" unless status.success?
        JSON.parse(File.read(File.join(directory, "nightly-canaries.json")))
      end
    end

    def collect(summary:, benchmarks: BENCHMARKS, now: Time.now.utc)
      lines = ["## CLI canary benchmark results", "", "Dispatch and workload states are reported separately.", ""]
      passed = true
      targets(benchmarks).group_by(&:first).each do |repository, expected|
        lines << "### #{repository}"
        begin
          parents = api("repos/#{repository}/actions/workflows/canary.yml/runs?branch=main&per_page=100").fetch("workflow_runs")
          parent = parents.max_by { |run| run.fetch("created_at") }
          unless parent
            passed = false
            lines << "No canary dispatch has been observed yet."
            next
          end
          parent_id = parent.fetch("id")
          state = parent["status"] == "completed" ? parent.fetch("conclusion") : parent.fetch("status")
          lines << "Dispatch: [run #{parent_id}](https://github.com/#{repository}/actions/runs/#{parent_id}) — #{state}."
          if now - Time.iso8601(parent.fetch("created_at")) > 36 * 60 * 60
            passed = false
            lines << "The latest dispatch is more than 36 hours old."
          end
          next unless parent["status"] == "completed"

          passed = false unless parent["conclusion"] == "success"
          record = receipt(repository, parent_id)
          recorded = record.fetch("runs").map { |run| [run.fetch("repository"), run.fetch("workflow"), run.fetch("inputs", {})] }
          unless recorded.to_set == expected.to_set && recorded.length == expected.length && record.fetch("cli_version").match?(/\Avcli-canary-[0-9a-f]{9,40}\z/)
            raise Error, "Dispatch receipt does not match this repository's registered workflows"
          end
          healthy = check(record, summary: nil)
          passed = false unless healthy
          lines << "CLI: `#{record.fetch('cli_version')}`. Dispatch: **#{record.fetch('state')}**."
          record.fetch("runs").each do |run|
            name = workload_name(run)
            name = "[#{name}](https://github.com/#{repository}/actions/runs/#{run.fetch('id')})" if run["id"]
            lines << "- #{name}: **#{run.fetch('state')}**"
          end
          lines << record["error"] if record["error"]
        rescue Error, KeyError, JSON::ParserError, Errno::ENOENT => error
          passed = false
          lines << "Unable to report this dispatch: #{error.message}"
        ensure
          lines << ""
        end
      end
      report = lines.join("\n") + "\n"
      File.write(summary, report)
      puts report
      passed
    end

    def write(path, record)
      File.write(path, JSON.pretty_generate(record) + "\n")
    end

    def write_summary(path, record)
      return unless path
      lines = ["## CLI canary benchmarks", "", "CLI: `#{record.fetch('cli_version')}`", "",
               "Dispatch: **#{record.fetch('state')}**. Benchmark outcomes are listed separately.", ""]
      record.fetch("runs").each do |run|
        name = "#{run.fetch('repository')} / #{workload_name(run)}"
        name = "[#{name}](#{run.fetch('url')})" if run["url"]
        lines << "- #{name}: **#{run.fetch('state')}**"
      end
      lines += ["", record["error"]] if record["error"]
      File.write(path, lines.join("\n") + "\n")
    end

    def workload_name(run)
      inputs = run.fetch("inputs", {})
      [run.fetch("workflow"), *inputs.values_at("case_id", "variant", "cache_layer", "cache_profile")].compact.join(" ")
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {output: "nightly-canaries.json"}
  OptionParser.new do |parser|
    parser.on("--version TAG") { |value| options[:version] = value }
    parser.on("--repository REPO") { |value| options[:repository] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--summary PATH") { |value| options[:summary] = value }
    parser.on("--dry-run") { options[:dry_run] = true }
    parser.on("--check PATH") { |value| options[:check] = value }
    parser.on("--collect") { options[:collect] = true }
  end.parse!
  begin
    runner = NightlyCanaries::Runner.new
    if options[:collect]
      exit(runner.collect(summary: options.fetch(:summary)) ? 0 : 1)
    elsif options[:check]
      exit(runner.check(JSON.parse(File.read(options[:check])), summary: options[:summary]) ? 0 : 1)
    else
      raise NightlyCanaries::Error, "Select the benchmark repository with --repository" unless options[:repository]
      if ENV["GITHUB_ACTIONS"] == "true" && options[:repository] != ENV["GITHUB_REPOSITORY"]
        raise NightlyCanaries::Error, "A workflow can dispatch canaries only in its own repository"
      end
      raise NightlyCanaries::Error, "Inspect the retained dispatch receipt before retrying; reruns can start duplicate benchmarks" if ENV.fetch("GITHUB_RUN_ATTEMPT", "1").to_i > 1 && !options[:dry_run]
      runner.dispatch(**options)
    end
  rescue NightlyCanaries::Error, KeyError, JSON::ParserError => error
    abort error.message
  end
end
