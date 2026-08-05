#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "publish-index"
require "yaml"

def default_repos_dir
  candidates = [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ]
  candidates.find { |candidate| Dir.exist?(candidate) } || candidates.first
end

repos_dir = ARGV[0] || ENV.fetch("BENCHMARK_REPOS_DIR", default_repos_dir)
abort "benchmark repos directory not found: #{repos_dir}" unless Dir.exist?(repos_dir)

repo_names = BENCHMARKS
  .map { |benchmark| benchmark.fetch("source_repo").split("/").last }
  .concat(%w[benchmark-docker benchmark-obs-studio])
  .uniq
  .sort

docker_repo_names = BENCHMARKS
  .select { |benchmark| benchmark.fetch("category") == "docker" }
  .map { |benchmark| benchmark.fetch("source_repo").split("/").last }
  .concat(%w[benchmark-docker])
  .uniq
  .sort

FORBIDDEN_HELPERS = {
  /\Ainstall-(?:boringcache|benchmark)-cli\.sh\z/ => "copied CLI installer",
  /\Aassert-boringcache-/ => "BoringCache internal assertion helper",
  /\Asum-boringcache-check-sizes\.sh\z/ => "cache-storage calculator",
  /\Awrite-benchmark-artifacts\.sh\z/ => "BoringCache artifact normalizer",
  /\Awrite-boringcache-docker-lane-artifacts\.sh\z/ => "BoringCache artifact normalizer",
  /\Acollect-boringcache-diagnostics\.sh\z/ => "BoringCache diagnostic collector",
  /\Arun-boringcache-(?:buildkit-benchmark|docker-lane)\.sh\z/ => "BoringCache lifecycle wrapper"
}.freeze

FORBIDDEN_INTERNAL_PATTERNS = {
  /cache_session_summary/ => "must retain product evidence without parsing cache-session internals",
  /\.buildkit\.(?:vertex_spans|mountcache|tool_caches)/ => "must not assert BuildKit receipt internals",
  /\bcache_errors\b/ => "must not duplicate product cache-error assertions",
  /\bboringcache\s+(?:check|inspect|cache-registry)\b/ => "must use one benchmark product lifecycle instead of secondary cache inspection",
  %r{/_boringcache/(?:status|metrics|shutdown)} => "must not manage the product proxy lifecycle",
  /BORINGCACHE_(?:PROXY_(?:LOG|PID|READY)|READY_FILE)/ => "must not manage the product proxy lifecycle",
  /publish_transferred_bytes|decoded_reuse|encoded_reuse/ => "must not calculate archive receipt or CDC reuse fields",
  /boringcache-proxy-[0-9]+\.log/ => "must not scrape product proxy logs"
}.freeze

FORBIDDEN_CLI_VERSION_PINS = {
  /(?:cli-version|cli_version|BORINGCACHE_CLI_VERSION)[^\n]{0,120}(?:v\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?)/i =>
    "must leave the CLI version to the Action default or a runtime cli_version input",
  /cli_version:\s*\n(?:[^\n]*\n){0,5}?\s*default:\s*["']?v\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?/i =>
    "must not give cli_version a pinned release default",
  /--cli-version(?:=|\s+)["']?v\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?/i =>
    "must not pass a hardcoded CLI release"
}.freeze

PUBLIC_BOUNDARY_MARKERS = [
  "boringcache/monorepo",
  "private monorepo",
  "synced from the monorepo",
  "generated from the monorepo",
  "internal source",
  "/Users/",
  ".planning/"
].freeze

PRODUCT_INVOCATION = /(?:\bboringcache\s+(?:bazel|cargo|ccache|docker|go|gradle|maven|nx|sccache|turbo|xcode)\b|boringcache\/one@)/
CLI_CANARY_INPUT = /^\s+cli_version:\s*$/
CLI_CANARY_FORWARD = /(?:cli-version|cli_version):\s*\$\{\{\s*inputs\.cli_version\b/
BUILDKIT_CANARY_INPUT = /^\s+buildkit_image:\s*$/
BUILDKIT_CANARY_FORWARD = /(?:managed-buildkit-image|buildkit_image):\s*\$\{\{[^\n]*inputs\.buildkit_image\b/

def duplicate_yaml_keys(source)
  duplicates = []
  tree = Psych.parse_stream(source)
  visit = lambda do |node|
    if node.is_a?(Psych::Nodes::Mapping)
      seen = {}
      node.children.each_slice(2) do |key, value|
        if key.is_a?(Psych::Nodes::Scalar)
          normalized = key.value.downcase
          duplicates << [key.value, key.start_line + 1] if seen.key?(normalized)
          seen[normalized] = true
        end
        visit.call(value)
      end
    else
      Array(node.children).each { |child| visit.call(child) }
    end
  end
  visit.call(tree)
  duplicates
rescue Psych::SyntaxError
  []
end

def workflow_steps(document)
  steps = []
  jobs = document.is_a?(Hash) ? document["jobs"] : nil
  jobs&.each_value do |job|
    steps.concat(job["steps"]) if job.is_a?(Hash) && job["steps"].is_a?(Array)
  end

  runs = document.is_a?(Hash) ? document["runs"] : nil
  steps.concat(runs["steps"]) if runs.is_a?(Hash) && runs["steps"].is_a?(Array)
  steps.select { |step| step.is_a?(Hash) }
end

errors = []
checked = 0

repo_names.each do |repo_name|
  repo_dir = File.join(repos_dir, repo_name)
  next unless Dir.exist?(repo_dir)

  checked += 1
  plan_path = File.join(repo_dir, ".boringcache.toml")
  plan = File.file?(plan_path) ? File.read(plan_path) : ""
  errors << "#{repo_name}/.boringcache.toml: missing CLI-owned repository plan" unless File.file?(plan_path)
  errors << "#{repo_name}/.boringcache.toml: missing workspace identity" unless plan.match?(/^workspace\s*=\s*"[^"]+"\s*$/)

  integration_files = [
    *Dir[File.join(repo_dir, ".github", "workflows", "*.{yml,yaml}")],
    *Dir[File.join(repo_dir, ".github", "actions", "**", "*.{yml,yaml}")],
    *Dir[File.join(repo_dir, "scripts", "**", "*")].select { |candidate| File.file?(candidate) },
    *Dir[File.join(repo_dir, "cases", "*.json")]
  ].sort

  integration_files.each do |file_path|
    relative = file_path.delete_prefix("#{repo_dir}/")
    basename = File.basename(file_path)
    text = File.read(file_path)

    FORBIDDEN_HELPERS.each do |pattern, description|
      errors << "#{repo_name}/#{relative}: remove #{description}; this contract belongs to product E2E" if basename.match?(pattern)
    end
    FORBIDDEN_INTERNAL_PATTERNS.each do |pattern, description|
      next unless text.match?(pattern)

      errors << "#{repo_name}/#{relative}: #{description}"
    end
    FORBIDDEN_CLI_VERSION_PINS.each do |pattern, description|
      next unless text.match?(pattern)

      errors << "#{repo_name}/#{relative}: #{description}"
    end
    PUBLIC_BOUNDARY_MARKERS.each do |marker|
      next unless text.downcase.include?(marker.downcase)

      errors << "#{repo_name}/#{relative}: private publishing detail #{marker.inspect}"
    end

    next unless file_path.match?(%r{/\.github/(?:workflows|actions)/})

    duplicate_yaml_keys(text).each do |key, line|
      errors << "#{repo_name}/#{relative}:#{line}: duplicate YAML key #{key.inspect}"
    end

    begin
      document = YAML.safe_load(text, aliases: true)
      runs = document.is_a?(Hash) ? document["runs"] : nil
      if runs.is_a?(Hash) && runs["using"] == "composite"
        workflow_steps(document).each do |step|
          next unless step.key?("run") && step["shell"].to_s.empty?

          errors << "#{repo_name}/#{relative} (#{step.fetch("name", "unnamed step")}): composite run steps must declare shell"
        end
      end
    rescue Psych::Exception => error
      errors << "#{repo_name}/#{relative}: invalid YAML (#{error.message.lines.first.strip})"
    end
  end

  workflow_text = integration_files
    .select { |file_path| file_path.match?(%r{/\.github/(?:workflows|actions)/}) }
    .map { |file_path| File.read(file_path) }
    .join("\n")
  unless workflow_text.match?(PRODUCT_INVOCATION)
    errors << "#{repo_name}: benchmark workflows must invoke one public BoringCache product lifecycle directly"
  end

  unless workflow_text.include?("workflow_dispatch:") && workflow_text.match?(CLI_CANARY_INPUT)
    errors << "#{repo_name}: a dispatchable benchmark workflow must expose the standard cli_version canary input"
  end
  unless workflow_text.match?(CLI_CANARY_FORWARD)
    errors << "#{repo_name}: benchmark workflows must forward inputs.cli_version to the BoringCache product lifecycle"
  end

  if docker_repo_names.include?(repo_name)
    unless workflow_text.match?(BUILDKIT_CANARY_INPUT)
      errors << "#{repo_name}: Docker benchmarks must expose the standard buildkit_image canary input"
    end
    unless workflow_text.match?(BUILDKIT_CANARY_FORWARD)
      errors << "#{repo_name}: Docker benchmarks must forward inputs.buildkit_image to managed-buildkit-image"
    end
  end

  next unless workflow_text.include?("BORINGCACHE_OBSERVABILITY_JSONL_PATH")
  next if workflow_text.include?("actions/upload-artifact@")

  errors << "#{repo_name}: product-emitted observability must be retained as an unmodified artifact"
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "benchmark leaf boundary passed: #{checked} repositories"
