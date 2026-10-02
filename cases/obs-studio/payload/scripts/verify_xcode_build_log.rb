#!/usr/bin/env ruby
# frozen_string_literal: true

source = File.read(ARGV.fetch(0), encoding: "UTF-8", invalid: :replace, undef: :replace).gsub(/\e\[[0-?]*[ -\/]*[@-~]/, "")
raise "Rolling Xcode build did not exercise native compilation" unless source.match?(/compilec | clang |\]\s+compiling\s+\S+\.(?:c|cc|cpp|cxx|m|mm|swift)(?:\s|$)/i)
