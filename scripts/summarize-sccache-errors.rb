#!/usr/bin/env ruby
# frozen_string_literal: true

path = ARGV.fetch(0)
unless File.file?(path)
  puts "sccache did not write a diagnostic log"
  exit
end
messages = Hash.new(0)
File.foreach(path, encoding: "UTF-8") do |line|
  next unless line.match?(/\b(?:error|warn|fail)\b/i)
  line = line.strip.gsub(%r{https?://\S+}, "[url]").gsub(%r{/home/runner/\S+}, "[path]")
    .gsub(/\b[A-Za-z0-9_-]{32,}\b/, "[id]").gsub(/\b(authorization|bearer|token|secret|password)\s*[:=]?\s*\S+/i, '\\1 [redacted]')[0, 300]
  messages[line] += 1
end
puts "sccache diagnostic log: #{File.size(path)} bytes"
puts "matching messages: #{messages.values.sum}"
messages.sort_by { |message, count| [-count, message] }.first(30).each { |message, count| puts "#{count} occurrences: #{message}" }
