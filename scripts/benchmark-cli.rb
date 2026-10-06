# frozen_string_literal: true

require "json"

module BenchmarkCLI
  def self.selection(root: File.expand_path("..", __dir__))
    value = JSON.parse(File.read(File.join(root, "config/cli.json")))
    channel, version = value.values_at("channel", "version")
    pattern = channel == "canary" ? /\Avcli-canary-[0-9a-f]{9,40}\z/ : /\Av\d+\.\d+\.\d+\z/
    raise "Select an exact published stable or canary CLI" unless value["schema_version"] == 1 && %w[stable canary].include?(channel) && version.is_a?(String) && version.match?(pattern)
    value
  end
end

puts BenchmarkCLI.selection.fetch(ARGV.fetch(0, "version")) if $PROGRAM_NAME == __FILE__
