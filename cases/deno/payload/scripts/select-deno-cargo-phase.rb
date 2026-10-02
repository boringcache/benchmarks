#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"

module DenoCargoPhase
  def self.command(settings, phase)
    common = ["cargo", "build", settings.fetch("DENO_BUILD_STD_ARG"), "--release", "--locked"]
    case phase
    when "primary"
      common + ["-p", "deno", "-p", "denort", "-p", "test_server", "--bin", "deno", "--bin", "denort", "--bin", "test_server", "--features=#{settings.fetch('DENO_PANIC_TRACE_FEATURE')}"]
    when "desktop"
      common + ["-p", "denort_desktop"]
    else
      raise "Unknown Deno Cargo phase: #{phase}"
    end
  end

  def self.main(argv)
    phase, path = argv
    settings = BenchmarkPlan.settings(File.join(BenchmarkPlan::ROOT, "scripts", "deno-release-recipe.env"))
    exec(*command(settings, path), chdir: File.join(BenchmarkPlan::ROOT, "upstream")) if phase == "run"
    path ||= File.join(BenchmarkPlan::ROOT, ".boringcache.toml")
    text = File.read(path)
    if phase == "job"
      pattern = /^command\s*=\s*\[.*?^\]\n?/m
      raise "Expected one Cargo command" unless text.scan(pattern).length == 1
      text = text.sub(pattern, "")
    else
      text = BenchmarkPlan.replace_command(text, command(settings, phase))
    end
    TomlRB.parse(text)
    File.write(path, text)
    puts "Selected Deno Cargo phase: #{phase}"
  end
end
DenoCargoPhase.main(ARGV) if $PROGRAM_NAME == __FILE__
