require "etc"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "pathname"
require "shellwords"
require "time"
require "toml-rb"

module Bench
  ROOT = File.expand_path("..", __dir__)
  PHASES = %w[cold warm].freeze
  ROLLING = "rolling"

  Error = Class.new(StandardError)

  def self.git(*args, chdir:)
    output, status = Open3.capture2e("git", *args, chdir:)
    raise Error, "git #{args.first} failed in #{chdir}: #{output.strip}" unless status.success?

    output
  end

  def self.gh(*args)
    output, error, status = Open3.capture3("gh", *args)
    raise Error, "gh #{args.first(2).join(" ")} failed: #{error.strip}" unless status.success?

    output
  end

  def self.expand(value, source)
    value.to_s.gsub(/\$\{?([A-Z0-9_]+)\}?/) { source.fetch(Regexp.last_match(1), "") }
  end

  def self.interpolate(values, source)
    values.transform_values { expand(it, source) }
  end
end

require_relative "bench/catalog"
require_relative "bench/tool"
require_relative "bench/lane"
require_relative "bench/case"
require_relative "bench/check"
require_relative "bench/workspace"
require_relative "bench/upstream"
require_relative "bench/rolling"
require_relative "bench/phase_run"
require_relative "bench/report"
require_relative "bench/container"
require_relative "bench/cli"
