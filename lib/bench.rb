require "fileutils"
require "json"
require "open3"
require "optparse"
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

  def self.interpolate(values, source)
    values.transform_values { it.to_s.gsub(/\$\{?([A-Z0-9_]+)\}?/) { source.fetch(Regexp.last_match(1), "") } }
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
