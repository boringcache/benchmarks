#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "open3"
require "fileutils"

module MeasureBuild
  class Error < StandardError; end

  def self.run(command, output:, start_marker: "::group::Building obs-studio...")
    raise Error, "Provide the build command after --" if command.empty?
    raise Error, "Timing output already exists" if File.exist?(output)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    build_started = nil
    build_finished = nil
    depth = 0
    groups = 0
    status = nil
    $stdout.sync = true
    Open3.popen2e(*command) do |stdin, stream, child|
      stdin.close
      stream.each_line do |line|
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        text = line.gsub(/\e\[[0-9;]*[A-Za-z]/, "").strip
        if text == start_marker
          groups += 1
          build_started = now
          depth = 1
        elsif build_started && !build_finished
          depth += 1 if text.start_with?("::group::")
          depth -= 1 if text == "::endgroup::"
          build_finished = now if depth.zero?
        end
        $stdout.write(line)
      end
      status = child.value
    end
    finished = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    complete = groups == 1 && build_started && build_finished
    record = {"schema_version" => 1, "method" => "upstream-log-group-monotonic",
      "start_marker" => start_marker, "end_marker" => "::endgroup::", "command" => command,
      "exit_code" => status.exitstatus, "verified_boundary" => !!complete,
      "build_seconds" => complete ? build_finished - build_started : nil,
      "entrypoint_seconds" => finished - started,
      "before_build_seconds" => build_started && build_started - started}
    FileUtils.mkdir_p(File.dirname(output))
    File.write(output, JSON.pretty_generate(record) + "\n")
    return status.exitstatus || 1 unless status.success?
    raise Error, "Expected exactly one complete upstream build log group; timing is unavailable" unless complete
    0
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  OptionParser.new do |parser|
    parser.on("--output PATH") { |value| options[:output] = value }
    parser.on("--start-marker TEXT") { |value| options[:start_marker] = value }
  end.order!
  begin
    exit MeasureBuild.run(ARGV, **options)
  rescue MeasureBuild::Error, KeyError, ArgumentError => error
    abort error.message
  end
end
