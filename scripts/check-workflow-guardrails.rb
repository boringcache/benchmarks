#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "publish-index"
require "yaml"

def default_repos_dir
  candidates = [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ]
  candidates.find { |path| Dir.exist?(path) } || candidates.first
end

repos_dir = ARGV[0] || ENV.fetch("BENCHMARK_REPOS_DIR", default_repos_dir)
abort "benchmark repos directory not found: #{repos_dir}" unless Dir.exist?(repos_dir)

BANNED_WORKFLOW_PATTERNS = [
  [
    /type=registry/,
    "Docker benchmark workflows must not publish a registry-cache product lane"
  ],
  [
    /\becr-cache\b/,
    "Docker benchmark workflows must not publish an ECR cache lane"
  ],
  [
    /^\s*(?:buildkit_backend|buildkit_cache_backend|cache_export_type|oci_hydration):|BORINGCACHE_(?:BUILDKIT_CACHE_BACKEND|CACHE_EXPORT_TYPE|OCI_HYDRATION)/,
    "Docker benchmark workflows have one managed BoringCache backend and must not expose backend selectors"
  ],
  [
    /^\s*(?:cache-backend|registry-tag|registry-ref-tag|buildkit-backend|buildkit-cache-backend|cache-export-type|oci-hydration):/,
    "Docker benchmark workflows should use the managed backend defaults instead of legacy Action inputs"
  ],
  [
    /docker-command:\s*setup/,
    "Docker benchmarks must use the CLI-owned managed build instead of setup-only cache wiring"
  ],
  [
    /\bBC OCI\b|BoringCache OCI/,
    "Docker benchmark workflows must present one BoringCache product lane"
  ]
].freeze

DOCKER_REQUIRED_PATTERNS = {
  /BORINGCACHE_MANAGED_BUILDKIT_IMAGE/ => "managed BuildKit image wiring",
  /run-boringcache-(?:buildkit-benchmark|docker-lane)/ => "managed BoringCache benchmark runner"
}.freeze

DOCKER_PRODUCT_ASSERTION = "assert-boringcache-docker-product-run.sh"
CANONICAL_DOCKER_PRODUCT_ASSERTION = File.expand_path(
  "canonical/#{DOCKER_PRODUCT_ASSERTION}",
  __dir__
)

ECR_RUNTIME_PATTERN = /(?:\becr-cache\b|\becr_(?:region|role_arn|registry|repository|allowed_account_ids)\b|(?:DOCKER_BENCHMARK|BENCHMARK)_ECR_|aws-actions\/(?:configure-aws-credentials|amazon-ecr-login)|\baws\s+ecr\b)/i

REVIEWED_ONE_ACTION_SHA = "8294be671cd5a2b73638df1b8e1e240df888297e"
DEFAULT_PROXY_PORT = "22243"
PUBLIC_CACHE_MODES = %w[archive docker buildkit bazel go gradle maven nx sccache turbo].freeze
RETIRED_CACHE_TOKENS = %w[BORINGCACHE_API_TOKEN BORINGCACHE_TOKEN].freeze
RETIRED_ACTION_INPUTS = %w[
  workspace cache-tag entries path key restore-keys enableCrossOsArchive
  no-platform exclude-patterns allow-external-symlinks preset
  runtime-cache-tag tool-version-scope require-oci-import-ready exclude
  cache-runtime uv-version composer-version proxy-no-git proxy-no-platform
  cache-mode turbo-api-url turbo-token turbo-team turbo-port nx-access-token
  nx-port sccache sccache-mode rust-version toolchain targets components
  profile cache-cargo cache-cargo-bin cache-target
].freeze
PUBLIC_CONTENT_MARKERS = [
  "boringcache/monorepo", "private monorepo", "monorepo source",
  "source monorepo", "synced from the monorepo",
  "generated from the monorepo", "internal source", "/Users/", ".planning/"
].freeze
HIDDEN_CACHE_SURFACE = ["cache-registry", "go-cacheprog", "run --proxy"].freeze

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

def duplicate_yaml_keys(source)
  duplicates = []
  tree = Psych.parse_stream(source)
  visit = lambda do |node|
    if node.is_a?(Psych::Nodes::Mapping)
      seen = {}
      node.children.each_slice(2) do |key, value|
        if key.is_a?(Psych::Nodes::Scalar)
          normalized_key = key.value.downcase
          duplicates << [key.value, key.start_line + 1] if seen.key?(normalized_key)
          seen[normalized_key] = true
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

def adapter_has_tag?(repo_plan, mode)
  section = repo_plan[/^\[adapters\.#{Regexp.escape(mode)}\]\s*$\n(?<body>.*?)(?=^\[|\z)/m, :body]
  section&.match?(/^tag\s*=\s*"[^"]+"\s*$/)
end

def check_ecr_retired(repo_name:, repo_path:)
  paths = [
    *Dir[File.join(repo_path, ".github", "workflows", "*.{yml,yaml}")],
    *Dir[File.join(repo_path, ".github", "actions", "**", "action.{yml,yaml}")]
  ].sort

  paths.filter_map do |path|
    line_number = File.foreach(path).with_index(1).find { |line, _number| line.match?(ECR_RUNTIME_PATTERN) }&.last
    next unless line_number

    relative_path = path.delete_prefix("#{repo_path}/")
    "#{repo_name}/#{relative_path}:#{line_number}: ECR runtime support is retired; preserve historical artifacts outside active workflow/action YAML"
  end
end

registry_by_repo = BENCHMARKS.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |benchmark, index|
  repo_name = benchmark.fetch("source_repo").split("/").last
  index[repo_name] << benchmark
end

errors = []

registry_by_repo.each do |repo_name, benchmarks|
  repo_path = File.join(repos_dir, repo_name)
  next unless Dir.exist?(repo_path)

  workflows = [
    *Dir[File.join(repo_path, ".github", "workflows", "*.{yml,yaml}")],
    *Dir[File.join(repo_path, ".github", "actions", "**", "*.{yml,yaml}")]
  ].sort
  workflow_text_by_path = workflows.to_h { |path| [path, File.read(path)] }
  plan_path = File.join(repo_path, ".boringcache.toml")
  repo_plan = File.exist?(plan_path) ? File.read(plan_path) : ""
  errors << "#{repo_name}/.boringcache.toml: missing CLI-owned repo plan" unless File.exist?(plan_path)
  errors << "#{repo_name}/.boringcache.toml: missing workspace identity" unless repo_plan.match?(/^workspace\s*=\s*"[^"]+"\s*$/)

  maintained_paths = [
    File.join(repo_path, "README.md"),
    plan_path,
    *workflows,
    *Dir[File.join(repo_path, "scripts", "**", "*")].select { |path| File.file?(path) }
  ].select { |path| File.file?(path) }.uniq
  maintained_paths.each do |path|
    relative_path = path.delete_prefix("#{repo_path}/")
    text = File.read(path)
    text.scan(/\$\{BORINGCACHE_PROXY_PORT:-([0-9]+)\}/).flatten.each do |port|
      next if port == DEFAULT_PROXY_PORT

      errors << "#{repo_name}/#{relative_path}: defaults BORINGCACHE_PROXY_PORT to #{port}; use #{DEFAULT_PROXY_PORT}"
    end
    text.scan(/^\s*(?:BORINGCACHE_)?PROXY_PORT:\s*["']?([0-9]+)["']?\s*$/i).flatten.each do |port|
      next if port == DEFAULT_PROXY_PORT

      errors << "#{repo_name}/#{relative_path}: defaults PROXY_PORT to #{port}; use #{DEFAULT_PROXY_PORT}"
    end
    RETIRED_CACHE_TOKENS.each do |token|
      errors << "#{repo_name}/#{relative_path}: retired token #{token}" if text.match?(/\b#{token}\b/)
    end
    PUBLIC_CONTENT_MARKERS.each do |marker|
      errors << "#{repo_name}/#{relative_path}: private publishing detail #{marker.inspect}" if text.downcase.include?(marker.downcase)
    end
    HIDDEN_CACHE_SURFACE.each do |marker|
      errors << "#{repo_name}/#{relative_path}: exposes hidden cache interface #{marker.inspect}" if text.downcase.include?(marker.downcase)
    end
  end

  workflow_text_by_path.each do |path, text|
    relative_path = path.delete_prefix("#{repo_path}/")

    duplicate_yaml_keys(text).each do |key, line|
      errors << "#{repo_name}/#{relative_path}:#{line}: duplicate YAML key #{key.inspect}"
    end

    BANNED_WORKFLOW_PATTERNS.each do |pattern, message|
      next unless text.match?(pattern)

      errors << "#{repo_name}/#{relative_path}: #{message}"
    end

    document = YAML.safe_load(text, aliases: true)
    runs = document.is_a?(Hash) ? document["runs"] : nil
    if runs.is_a?(Hash) && runs["using"] == "composite"
      Array(runs["steps"]).each do |step|
        next unless step.is_a?(Hash) && step.key?("run") && step["shell"].to_s.empty?

        step_name = step.fetch("name", "unnamed step")
        errors << "#{repo_name}/#{relative_path} (#{step_name}): composite run steps must declare shell"
      end
    end

    workflow_steps(document).each do |step|
      uses = step["uses"].to_s
      next unless uses.start_with?("boringcache/one@")

      step_name = step.fetch("name", "unnamed step")
      location = "#{repo_name}/#{relative_path} (#{step_name})"
      action_ref = uses.delete_prefix("boringcache/one@")
      inputs = step["with"].is_a?(Hash) ? step["with"].transform_keys(&:to_s) : {}
      mode = inputs["mode"].to_s

      errors << "#{location}: use reviewed Action SHA #{REVIEWED_ONE_ACTION_SHA}" unless action_ref == REVIEWED_ONE_ACTION_SHA
      errors << "#{location}: setup must be none" unless inputs["setup"] == "none"
      errors << "#{location}: mode #{mode.inspect} is not canonical" unless PUBLIC_CACHE_MODES.include?(mode)

      forbidden = inputs.keys & RETIRED_ACTION_INPUTS
      errors << "#{location}: retired Action inputs #{forbidden.sort.join(', ')}" unless forbidden.empty?

      if mode == "archive"
        errors << "#{location}: archive mode must select cache-profiles" unless inputs.key?("cache-profiles")
      elsif PUBLIC_CACHE_MODES.include?(mode) && !adapter_has_tag?(repo_plan, mode)
        errors << "#{location}: .boringcache.toml must own [adapters.#{mode}].tag"
      end
    rescue Psych::Exception => error
      errors << "#{repo_name}/#{relative_path}: invalid YAML (#{error.message.lines.first.strip})"
    end
  end

  next unless benchmarks.any? { |benchmark| benchmark.fetch("category") == "docker" }

  docker_text = workflow_text_by_path.values.join("\n")
  DOCKER_REQUIRED_PATTERNS.each do |pattern, description|
    next if docker_text.match?(pattern)

    errors << "#{repo_name}: Docker workflows are missing #{description}"
  end

  assertion_path = File.join(repo_path, "scripts", DOCKER_PRODUCT_ASSERTION)
  if !File.exist?(assertion_path)
    errors << "#{repo_name}/scripts/#{DOCKER_PRODUCT_ASSERTION}: missing managed Docker runtime contract"
  elsif File.binread(assertion_path) != File.binread(CANONICAL_DOCKER_PRODUCT_ASSERTION)
    errors << "#{repo_name}/scripts/#{DOCKER_PRODUCT_ASSERTION}: differs from the canonical managed Docker runtime contract"
  end

  benchmark_script_path = File.join(repo_path, "scripts", "run-boringcache-buildkit-benchmark.sh")
  if !File.exist?(benchmark_script_path)
    errors << "#{repo_name}/scripts/run-boringcache-buildkit-benchmark.sh: missing managed Docker benchmark entrypoint"
  elsif !File.read(benchmark_script_path).include?(DOCKER_PRODUCT_ASSERTION)
    errors << "#{repo_name}/scripts/run-boringcache-buildkit-benchmark.sh: does not enforce the managed Docker runtime contract"
  end
end

ecr_guardrail_repos = [*registry_by_repo.keys, "docker-cache-proofs"].uniq
ecr_guardrail_repos.each do |repo_name|
  repo_path = File.join(repos_dir, repo_name)
  next unless Dir.exist?(repo_path)

  errors.concat(check_ecr_retired(repo_name: repo_name, repo_path: repo_path))
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "benchmark workflow guardrails passed: #{registry_by_repo.length} repos"
