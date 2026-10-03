#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"

root = File.expand_path("..", __dir__)
scenario = ARGV.fetch(0, "base")
abort "Unknown scenario: #{scenario}" unless %w[base warm1].include?(scenario)
abort "Source preparation requires a prepared case" unless File.file?(File.join(root, "benchmark-context.json"))
index, error, status = Open3.capture3("git", "ls-files", "--stage", "upstream", chdir: root)
abort "Source preparation requires the declared upstream gitlink: #{error.strip}" unless status.success? && index.match?(/\A160000 [0-9a-f]{40} 0\tupstream\n\z/)
expected = index.split.fetch(1)
actual, error, status = Open3.capture3("git", "-C", File.join(root, "upstream"), "rev-parse", "HEAD")
abort "Upstream HEAD differs from the declared source pin: #{error.strip}" unless status.success? && actual.strip == expected
%w[reset clean].each do |operation|
  arguments = operation == "reset" ? ["reset", "--hard"] : ["clean", "-fdx"]
  abort "Cannot #{operation} the disposable upstream checkout" unless system("git", "-C", File.join(root, "upstream"), *arguments)
end
system("git", "-C", File.join(root, "upstream"), "status", "--short") || abort("Cannot inspect the upstream checkout")
