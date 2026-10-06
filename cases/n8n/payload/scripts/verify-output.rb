# frozen_string_literal: true

abort "n8n CLI output is missing or empty" unless File.size?("upstream/packages/cli/dist/index.js")
