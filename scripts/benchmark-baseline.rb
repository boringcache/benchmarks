# frozen_string_literal: true

require "json"
require "time"

module BenchmarkBaseline
  def self.selection(root: File.expand_path("..", __dir__))
    path = File.join(root, "config/baseline.json")
    return nil unless File.file?(path)
    value = JSON.parse(File.read(path))
    raise "Invalid benchmark baseline" unless value["schema_version"] == 1 && value.fetch("id").match?(/\A[a-z0-9-]+\z/)
    Time.iso8601(value.fetch("started_at"))
    value
  end

  def self.current?(timestamp, baseline)
    !baseline || Time.iso8601(timestamp) >= Time.iso8601(baseline.fetch("started_at"))
  end
end

puts BenchmarkBaseline.selection.fetch(ARGV.fetch(0, "started_at")) if $PROGRAM_NAME == __FILE__
