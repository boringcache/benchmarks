#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "publish-index"

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
REQUIRED_SEED_CONSUMER_PATTERN = /(?:^|\n)\s*needs:\s*(?:\[[^\]]*\bseed-cache\b[^\]]*\]|seed-cache\b)/
BORINGCACHE_ACTION_PATTERN = /^\s*(?:-\s*)?uses:\s*boringcache\/one@/m
STRICT_FRESH_SEED_PATTERN = /^\s*fail-on-cache-error:\s*(?:['"]?true['"]?|\$\{\{\s*inputs\.cache_lane\s*==\s*['"]fresh['"]\s*\}\})\s*$/m

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

  workflow_text_by_path.each do |path, text|
    relative_path = path.delete_prefix("#{repo_path}/")

    BANNED_WORKFLOW_PATTERNS.each do |pattern, message|
      next unless text.match?(pattern)

      errors << "#{repo_name}/#{relative_path}: #{message}"
    end

    if text.match?(REQUIRED_SEED_CONSUMER_PATTERN) &&
       text.match?(BORINGCACHE_ACTION_PATTERN) &&
       !text.match?(STRICT_FRESH_SEED_PATTERN)
      errors << "#{repo_name}/#{relative_path}: a fresh BoringCache seed consumed by a warm job must set fail-on-cache-error for the fresh lane"
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
