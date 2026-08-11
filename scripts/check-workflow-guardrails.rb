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
CLI_CANARY_INPUT = /^\s+cli_version:\s*(?:$|\{)/
CLI_CANARY_FORWARD = /(?:cli-version|cli_version):\s*\$\{\{\s*inputs\.cli_version\b/
BUILDKIT_CANARY_INPUT = /^\s+buildkit_image:\s*(?:$|\{)/
BUILDKIT_CANARY_FORWARD = /(?:managed-buildkit-image|buildkit_image):\s*\$\{\{[^\n]*inputs\.buildkit_image\b/

DEPENDENCY_CACHE_PATHS = {
  /(?:^|\/)node_modules(?:\/|$)/i => "node_modules",
  /pnpm[-_]?store/i => "pnpm store",
  /YARN_CACHE|\.yarn(?:-cache|\/berry\/cache)/i => "Yarn package cache",
  /GO_MODULE_CACHE|GOMODCACHE|\/pkg\/mod(?:\/|$)/i => "Go module cache",
  /MAVEN_LOCAL_REPO|\.m2\/repository(?:\/|$)/i => "Maven dependency repository"
}.freeze

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
  ].reject { |candidate| candidate.include?("/__pycache__/") }.sort

  integration_files.each do |file_path|
    relative = file_path.delete_prefix("#{repo_dir}/")
    basename = File.basename(file_path)
    text = File.read(file_path).scrub("")

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

    if relative.match?(%r{\A\.github/(?:actions/|workflows/(?!sync\.yml\z))}) && text.match?(/\bgit\s+ls-remote\b/)
      errors << "#{repo_name}/#{relative}: benchmark execution must use the committed source pin; resolve moving branches in sync.yml"
    end

    if text.match?(/ubuntu-[^\s"']*(?:8|16)-cores/i)
      errors << "#{repo_name}/#{relative}: large runners must be an empty runtime override, not a benchmark default"
    end

    text.lines.grep(/runs-on:.*inputs\.runner_label/).each do |line|
      next if line.include?("github.event_name == 'workflow_dispatch'") && line.include?("github.ref_name == 'main'")

      errors << "#{repo_name}/#{relative}: runner_label overrides must be restricted to manual main-branch dispatches"
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

      jobs = document.is_a?(Hash) && document["jobs"].is_a?(Hash) ? document["jobs"] : {}
      if relative.start_with?(".github/workflows/") && basename.include?("fresh")
        display_names = jobs.values.map { |job| job.is_a?(Hash) ? job["name"].to_s.downcase : nil }.compact
        errors << "#{repo_name}/#{relative}: fresh benchmarks must run on pull requests" unless text.include?("pull_request:")
        errors << "#{repo_name}/#{relative}: fresh benchmarks must expose direct cold jobs" unless display_names.any? { |name| name.include?("cold") }
        errors << "#{repo_name}/#{relative}: fresh benchmarks must expose direct warm jobs" unless display_names.any? { |name| name.include?("warm") }
        jobs.each do |job_name, job|
          next unless job.is_a?(Hash) && job["name"].to_s.downcase.include?("warm")
          next if job.key?("needs")

          errors << "#{repo_name}/#{relative} (#{job_name}): fresh warm jobs must depend on the cold publish"
        end
      end

      if relative.start_with?(".github/workflows/") && basename.end_with?("-benchmark.yml") && !basename.include?("fresh") && text.include?("push:")
        display_names = jobs.values.map { |job| job.is_a?(Hash) ? job["name"].to_s.downcase : nil }.compact
        unless display_names.any? { |name| name.include?("commit") } && display_names.none? { |name| name.include?("cold") || name.include?("warm") }
          errors << "#{repo_name}/#{relative}: source-push rolling benchmarks must contain commit jobs only"
        end
      end

      jobs.each do |job_name, job|
        next unless job.is_a?(Hash)

        local_workflow = job["uses"].to_s
        if local_workflow.start_with?("./.github/workflows/")
          errors << "#{repo_name}/#{relative} (#{job_name}): benchmark metrics must be direct top-level jobs; move shared work into a step-level action"
        end

        display_name = job["name"].to_s
        if display_name.include?("/")
          errors << "#{repo_name}/#{relative} (#{job_name}): benchmark job names must be flat; use spaces instead of slash hierarchy"
        end

        matrix = job.dig("strategy", "matrix")
        display_name.scan(/matrix\.([A-Za-z0-9_.-]+)/).flatten.each do |reference|
          path = reference.split(".")
          values = []
          if matrix.is_a?(Hash)
            axis = matrix[path.first]
            values.concat(axis.is_a?(Array) ? axis : [axis].compact)
            values.concat(matrix["include"]) if matrix["include"].is_a?(Array)
          end
          nested_values = values.map do |value|
            path.reduce(value) { |current, key| current.is_a?(Hash) ? current[key] : nil }
          end.compact
          if nested_values.any? { |value| value.to_s.include?("/") }
            errors << "#{repo_name}/#{relative} (#{job_name}): benchmark matrix job names must be flat; use spaces instead of slash hierarchy"
          end
        end

        next unless job["steps"].is_a?(Array)

        steps = job["steps"].select { |step| step.is_a?(Hash) }
        product_steps = steps.select { |step| step["uses"].to_s.start_with?("boringcache/one@") }
        product_modes = product_steps.each_with_object([]) do |step, modes|
          inputs = step["with"].is_a?(Hash) ? step["with"] : {}
          mode = inputs["mode"].to_s.strip
          modes << mode unless mode.empty?
        end.uniq

        if product_modes.length > 1
          errors << "#{repo_name}/#{relative} (#{job_name}): one benchmark lane must use one BoringCache mode, found #{product_modes.join(", ")}"
        end

        product_steps.each do |step|
          inputs = step["with"].is_a?(Hash) ? step["with"] : {}
          mode = inputs["mode"].to_s.strip
          profiles = inputs["cache-profiles"].to_s.strip
          next if profiles.empty? || mode == "archive"

          errors << "#{repo_name}/#{relative} (#{step.fetch("name", "unnamed step")}): adapter mode #{mode} must not hide an archive profile; use a separately named benchmark case"
        end

        next if product_modes.empty? || product_modes.include?("archive")

        steps.each do |step|
          uses = step["uses"].to_s
          inputs = step["with"].is_a?(Hash) ? step["with"] : {}
          if uses.match?(%r{\Aactions/cache(?:/(?:restore|save))?@})
            cache_paths = inputs["path"].to_s
            DEPENDENCY_CACHE_PATHS.each do |pattern, description|
              next unless cache_paths.match?(pattern)

              errors << "#{repo_name}/#{relative} (#{step.fetch("name", "unnamed step")}): #{description} must not be hidden inside an adapter comparison"
            end
            if cache_paths.lines.any? { |line| line.strip.match?(/\A(?:\$\{\{\s*env\.GRADLE_USER_HOME\s*\}\}|[^\s]*\.gradle-user-home)\z/) }
              errors << "#{repo_name}/#{relative} (#{step.fetch("name", "unnamed step")}): cache only Gradle build-cache directories, not the dependency-bearing Gradle user home"
            end
          end

          next unless uses.match?(%r{\A(?:actions/setup-(?:go|java|node|python)|ruby/setup-ruby)@})

          setup_cache = inputs["cache"] || inputs["package-manager-cache"] || inputs["bundler-cache"]
          next if setup_cache.nil? || setup_cache == false || setup_cache.to_s.strip.match?(/\A(?:|false)\z/i)

          errors << "#{repo_name}/#{relative} (#{step.fetch("name", "unnamed step")}): runtime setup must not add a hidden dependency cache to an adapter benchmark"
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
