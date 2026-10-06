# frozen_string_literal: true

if ENV["STORYBOOK_WORKLOAD"] == "nx"
  path = "upstream/code/frameworks/react-vite/dist/index.js"
  abort "Storybook React Vite compiled output is missing or empty" unless File.size?(path)
else
  path = "storybook-sandboxes/react-vite-default-ts/storybook-static/index.html"
  abort "Storybook HTML output is missing or empty" unless File.size?(path)
end
