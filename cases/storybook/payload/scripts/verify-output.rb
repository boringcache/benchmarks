# frozen_string_literal: true

abort "Storybook HTML output is missing or empty" unless File.size?("storybook-sandboxes/react-vite-default-ts/storybook-static/index.html")
