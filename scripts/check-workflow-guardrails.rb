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
    %r{/_boringcache/status|cache:buildcache},
    "benchmark workflows should consume boringcache/one Docker import outputs instead of probing proxy internals"
  ],
  [
    /docker-layers/,
    "Docker benchmarks should use one measured registry tag instead of a second docker-layers tag"
  ],
  [
    /buildkit_backend:\s*native\b/,
    "Docker benchmark workflows should use the registry wrapper backend with buildkit_cache_backend=boringcache; the Rust-native Docker backend is retired"
  ],
  [
    /\bBC Native\b/,
    "Docker benchmark workflows should not publish active BC Native lanes; keep old native numbers only in historical docs"
  ],
  [
    /run-boringcache-native-buildkit-benchmark/,
    "Docker benchmark workflows should not call the retired Rust-native BuildKit benchmark runner"
  ],
  [
    /native_publish_intensity|BORINGCACHE_BUILDKIT_PUBLISH_INTENSITY|Upload native BuildKit evidence/,
    "Docker benchmark workflows should not configure retired native publisher controls"
  ]
].freeze

DOCKER_REQUIRED_STRINGS = {
  "docker-cache-import-ready" => "Docker import readiness output",
  "docker-cache-requested-from-refs" => "requested import refs output",
  "docker-cache-from-refs" => "used import refs output",
  "registry_proxy_tags=\"${cache_scope}\"" => "single registry proxy tag assignment"
}.freeze

DOCKER_PRODUCT_ASSERTION = "assert-boringcache-docker-product-run.sh"
CANONICAL_DOCKER_PRODUCT_ASSERTION = File.expand_path(
  "canonical/#{DOCKER_PRODUCT_ASSERTION}",
  __dir__
)

def workflow_step_blocks(text)
  lines = text.lines
  blocks = []

  lines.each_with_index do |line, index|
    match = line.match(/\A(\s*)- name:/)
    next unless match

    indent = match[1]
    finish = ((index + 1)...lines.length).find do |candidate|
      lines[candidate].match?(/\A#{Regexp.escape(indent)}- name:/)
    end || lines.length
    blocks << lines[index...finish].join
  end

  blocks
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
  end

  next unless benchmarks.any? { |benchmark| benchmark.fetch("category") == "docker" }

  docker_reusable_path = File.join(repo_path, ".github", "workflows", "reusable-docker-buildkit-benchmark.yml")
  unless File.exist?(docker_reusable_path)
    errors << "#{repo_name}: missing reusable-docker-buildkit-benchmark.yml for Docker benchmark"
    next
  end

  docker_text = File.read(docker_reusable_path)
  DOCKER_REQUIRED_STRINGS.each do |needle, description|
    next if docker_text.include?(needle)

    errors << "#{repo_name}/.github/workflows/reusable-docker-buildkit-benchmark.yml: missing #{description}"
  end

  workflow_text_by_path.each do |path, text|
    relative_path = path.delete_prefix("#{repo_path}/")
    workflow_step_blocks(text).each do |block|
      next unless block.include?("uses: boringcache/one@")
      next unless block.include?("docker-command: setup")
      next unless block.include?("buildkit_cache_backend")
      unless block.include?("buildkit_cache_backend != 'boringcache'")
        errors << "#{repo_name}/#{relative_path}: managed Docker must bypass boringcache/one setup-only and run through the CLI-owned build"
      end
      unless block.match?(/^\s*cache-backend:\s*registry\s*$/)
        errors << "#{repo_name}/#{relative_path}: setup-only Docker must declare cache-backend=registry explicitly"
      end
    end
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

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "benchmark workflow guardrails passed: #{registry_by_repo.length} repos"
