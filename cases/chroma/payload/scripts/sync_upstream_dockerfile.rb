#!/usr/bin/env ruby
# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "open3"
root = File.expand_path("..", __dir__)
target = File.join(root, "docker", "chroma.Dockerfile")
Dir.mktmpdir("chroma-recipe-") do |directory|
  FileUtils.mkdir_p(File.join(directory, "docker"))
  copy = File.join(directory, "docker", "chroma.Dockerfile")
  FileUtils.cp(File.join(root, "upstream", "rust", "Dockerfile"), copy)
  patch = File.join(root, "docker", "chroma.patch")
  _output, error, status = Open3.capture3("git", "apply", "--check", patch, chdir: directory)
  raise "Chroma's upstream Dockerfile no longer accepts the reviewed patch: #{error.strip}" unless status.success?
  _output, error, status = Open3.capture3("git", "apply", patch, chdir: directory)
  raise "Chroma Dockerfile patch failed: #{error.strip}" unless status.success?
  expected = File.read(copy)
  File.write(target, expected) if ARGV == ["--update"]
  raise "Benchmark Dockerfile differs from the upstream file plus its reviewed patch" unless File.read(target) == expected
end
puts "Verified Chroma Dockerfile against the reviewed upstream patch"
