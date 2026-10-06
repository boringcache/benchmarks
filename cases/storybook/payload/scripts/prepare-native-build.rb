# frozen_string_literal: true

abort "Storybook dependency installation failed" unless system("corepack", "yarn", "install", "--immutable", chdir: "upstream")
unless system("corepack", "yarn", "task", "--task", "sandbox", "--start-from=auto", "--template", "react-vite/default-ts", "--no-link", "--debug", chdir: "upstream")
  abort "Storybook sandbox creation failed"
end
