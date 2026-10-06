# frozen_string_literal: true

abort "n8n dependency installation failed" unless system("corepack", "pnpm", "install", "--frozen-lockfile", chdir: "upstream")
