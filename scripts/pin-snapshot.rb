#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "pathname"

root = Pathname(__dir__).join("..").expand_path
source = root.join("data", "latest")
target = root.join("data", "snapshot")

unless source.exist?
  warn "Missing source directory: #{source}"
  exit 1
end

FileUtils.mkdir_p(target)
FileUtils.rm_rf(Dir.glob(target.join("*").to_s))
FileUtils.cp_r(Dir.glob(source.join("*").to_s), target)

puts "Pinned benchmark snapshot from #{source} to #{target}"
