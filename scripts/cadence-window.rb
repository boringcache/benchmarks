# frozen_string_literal: true

require "time"

module CadenceWindow
  class Error < StandardError; end

  def self.open?(deadline = ENV.fetch("BENCHMARK_CADENCE_UNTIL", ""), now: Time.now.utc)
    return true if deadline.empty?
    unless deadline.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:Z|[+-]\d{2}:\d{2})\z/)
      raise Error, "BENCHMARK_CADENCE_UNTIL must be an ISO 8601 timestamp with a timezone"
    end
    Date.iso8601(deadline[0, 10])
    now < Time.iso8601(deadline)
  rescue ArgumentError
    raise Error, "BENCHMARK_CADENCE_UNTIL must be a valid timestamp"
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    open = CadenceWindow.open?
    File.open(ENV.fetch("GITHUB_OUTPUT"), "a") { |file| file.puts("open=#{open}") } if ENV["GITHUB_OUTPUT"]
    puts(open ? "Benchmark dispatch window is open" : "Benchmark dispatch window has ended; no new batches requested")
  rescue CadenceWindow::Error => error
    abort error.message
  end
end
