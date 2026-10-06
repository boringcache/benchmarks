# frozen_string_literal: true

require "json"
require "fileutils"

if ENV["STORYBOOK_WORKLOAD"] == "nx"
  path = "upstream/code/frameworks/react-vite/dist/index.js"
  abort "Storybook React Vite compiled output is missing or empty" unless File.size?(path)
  results = JSON.parse(File.read("upstream/.nx/cache/run.json"))
  tasks = results.fetch("tasks")
  abort "Nx did not retain successful compile task results" unless !tasks.empty? && tasks.all? { |task| task["target"] == "compile" && task["status"] == 0 }
  states = tasks.map { |task| task.fetch("cacheStatus") }
  if ENV["BENCHMARK_NX_PHASE"] == "warm"
    expected = %w[boringcache depot-cache].include?(ENV.fetch("BENCHMARK_NX_PROVIDER")) ? "remote-cache-hit" : "local-cache-hit"
    abort "Nx warm tasks did not all use the selected provider cache; observed: #{JSON.generate(states.tally)}" unless states.all? { |state| state == expected }
  elsif ENV["BENCHMARK_NX_LANE"] == "fresh"
    abort "Nx cold tasks unexpectedly reused cached output" unless states.all? { |state| state == "cache-miss" }
  end
  FileUtils.mkdir_p("benchmark-results")
  File.write("benchmark-results/nx-task-results.json", JSON.pretty_generate(results) + "\n")
  File.write("nx-cache-state.json", JSON.generate({"hit" => states.any? { |state| %w[remote-cache-hit local-cache-hit].include?(state) }}) + "\n")
else
  path = "storybook-sandboxes/react-vite-default-ts/storybook-static/index.html"
  abort "Storybook HTML output is missing or empty" unless File.size?(path)
end
