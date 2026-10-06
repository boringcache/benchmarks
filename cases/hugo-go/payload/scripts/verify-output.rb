# frozen_string_literal: true

require "open3"

gopath, status = Open3.capture2("go", "env", "GOPATH")
abort "Cannot determine the Go output directory" unless status.success?
artifact = File.join(gopath.strip, "bin", "dragonfly_amd64", "hugo")
abort "Hugo executable is missing: #{artifact}" unless File.executable?(artifact)
changes, status = Open3.capture2("git", "-C", "upstream", "status", "--porcelain=v1", "--untracked-files=all")
abort "Hugo source changed during the build" unless status.success? && changes.empty?
