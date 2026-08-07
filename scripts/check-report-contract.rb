#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

def default_repos_dir
  candidates = [
    File.expand_path("../../benchmarks-repos", __dir__),
    File.expand_path("../../benchmark-repos", __dir__)
  ]
  candidates.find { |candidate| Dir.exist?(candidate) } || candidates.first
end

DEFAULT_PLATFORM = "linux/amd64"
LANE_PHASE_LABELS = {
  "fresh" => %w[cold warm],
  "rolling" => %w[commit]
}.freeze

Producer = Struct.new(:job, :benchmark_id, :strategy, :variant, :lane, :phase, keyword_init: true) do
  def stem
    slug = variant.to_s.empty? ? "" : "-#{variant_slug}"
    "#{benchmark_id}-#{strategy}#{slug}-#{lane}"
  end

  def variant_slug
    variant.to_s.chars.map { |character| character.match?(/[[:alnum:]]/) ? character : "-" }.join.gsub(/\A-+|-+\z/, "").downcase
  end

  def phase_label
    return "commit" if lane == "rolling"

    phase == "warm" ? "warm" : "cold"
  end

  def phase_artifact
    "phase-#{stem.sub(/-#{Regexp.escape(lane)}\z/, "")}-#{lane}-#{phase_label}"
  end
end

Upload = Struct.new(:job, :step, :name, :path, :if_no_files_found, keyword_init: true) do
  def stem
    File.basename(path.to_s, ".json")
  end
end

class Workflow
  attr_reader :document, :relative

  def initialize(document, relative, input_overrides = {})
    @document = document
    @relative = relative
    @inputs = collect_inputs.merge(input_overrides)
    @env = {}
    @env = (document["env"].is_a?(Hash) ? document["env"] : {}).transform_values { |value| resolve(value, {}) }
  end

  def jobs
    document["jobs"].is_a?(Hash) ? document["jobs"] : {}
  end

  def declares_input?(name)
    @inputs.key?(name)
  end

  def resolve(value, matrix, shell_env = {})
    return value unless value.is_a?(String)

    resolved = value.gsub(/\$\{\{(.+?)\}\}/) do
      evaluated = evaluate(Regexp.last_match(1).strip, matrix)
      return nil if evaluated.nil?

      evaluated
    end
    scope = @env.merge(shell_env)
    resolved.gsub(/\$\{?([A-Z][A-Z0-9_]*)\}?/) { scope.fetch(Regexp.last_match(1), Regexp.last_match(0)).to_s }
  end

  def shell_env_for(job, step, matrix)
    [document["env"], job["env"], step["env"]].reduce({}) do |carried, declared|
      declared.is_a?(Hash) ? carried.merge(declared.transform_values { |value| resolve(value, matrix) }) : carried
    end
  end

  private

  def collect_inputs
    triggers = document["on"] || document[true]
    return {} unless triggers.is_a?(Hash)

    triggers.values.each_with_object({}) do |trigger, inputs|
      declared = trigger.is_a?(Hash) && trigger["inputs"].is_a?(Hash) ? trigger["inputs"] : {}
      declared.each { |name, spec| inputs[name] = spec.is_a?(Hash) ? spec.fetch("default", "").to_s : "" }
    end
  end

  def evaluate(expression, matrix)
    return Regexp.last_match(1) if expression.match(/\A'([^']*)'\z/)

    if (call = expression.match(/\Aformat\(\s*'([^']*)'\s*,\s*(.+)\)\z/m))
      arguments = split_arguments(call[2]).map { |argument| evaluate(argument.strip, matrix) }
      return nil if arguments.any?(&:nil?)

      return call[1].gsub(/\{(\d+)\}/) { arguments[Regexp.last_match(1).to_i].to_s }
    end

    lookup(expression, matrix)
  end

  def split_arguments(text)
    arguments = []
    depth = 0
    current = +""
    text.each_char do |character|
      case character
      when "(" then depth += 1
      when ")" then depth -= 1
      end
      if character == "," && depth.zero?
        arguments << current
        current = +""
      else
        current << character
      end
    end
    arguments << current
  end

  def lookup(path, matrix)
    segments = path.split(".")
    root = segments.shift
    base = case root
           when "inputs", "github.event.inputs" then @inputs
           when "env" then @env
           when "matrix" then matrix
           else return nil
           end
    value = segments.reduce(base) { |current, key| current.is_a?(Hash) ? current[key] : nil }
    value.nil? ? nil : value.to_s
  end
end

def matrix_combinations(matrix)
  return [{}] unless matrix.is_a?(Hash)

  axes = matrix.reject { |key, _| %w[include exclude].include?(key) }
  includes = matrix["include"].is_a?(Array) ? matrix["include"].select { |entry| entry.is_a?(Hash) } : []
  return includes.map(&:dup) if axes.empty? && includes.any?

  combinations = axes.reduce([{}]) do |carried, (key, values)|
    carried.flat_map { |combination| Array(values).map { |value| combination.merge(key => value) } }
  end

  includes.each do |entry|
    matched = combinations.select do |combination|
      entry.all? { |key, value| !axes.key?(key) || combination[key] == value }
    end
    if matched.empty?
      combinations << entry.dup
    else
      matched.each { |combination| combination.merge!(entry.reject { |key, _| axes.key?(key) }) }
    end
  end

  combinations
end

def action_emits_variant?(repo_dir, uses)
  action_dir = uses.delete_prefix("./")
  path = ["action.yml", "action.yaml"].map { |basename| File.join(repo_dir, action_dir, basename) }.find { |candidate| File.file?(candidate) }
  return false unless path

  File.read(path).include?("--variant")
end

def phase_flags(run)
  segment = run[/benchmark-report\.py\s+phase\b.*/m].to_s
  segment.scan(/--(benchmark|strategy|lane|phase|variant)[= ]+"?([^"\s\\]*)"?/).to_h
end

def producers_for(workflow:, repo_dir:, job_id:, job:)
  matrix_combinations(job.dig("strategy", "matrix")).flat_map do |matrix|
    Array(job["steps"]).filter_map do |step|
      next unless step.is_a?(Hash)

      uses = step["uses"].to_s
      if uses.start_with?("./.github/actions/")
        with = step["with"].is_a?(Hash) ? step["with"] : {}
        platform = workflow.resolve(with["platform"].to_s, matrix).to_s
        fields = {
          "benchmark" => workflow.resolve(with["benchmark_id"].to_s, matrix),
          "strategy" => workflow.resolve(with["strategy"].to_s, matrix),
          "lane" => workflow.resolve(with["cache_lane"].to_s, matrix),
          "phase" => workflow.resolve(with["phase"].to_s, matrix),
          "variant" => action_emits_variant?(repo_dir, uses) && platform != DEFAULT_PLATFORM ? platform : ""
        }
      elsif step["run"].to_s.match?(/benchmark-report\.py\s+phase\b/)
        shell_env = workflow.shell_env_for(job, step, matrix)
        fields = phase_flags(step["run"].to_s).transform_values { |value| workflow.resolve(value, matrix, shell_env) }
      else
        next
      end

      next if %w[benchmark strategy lane].any? { |key| fields[key].to_s.empty? }

      Producer.new(
        job: job_id,
        benchmark_id: fields["benchmark"],
        strategy: fields["strategy"],
        variant: fields["variant"].to_s,
        lane: fields["lane"],
        phase: fields["phase"]
      )
    end
  end
end

def uploads_for(workflow:, job_id:, job:)
  Array(job["steps"]).filter_map do |step|
    next unless step.is_a?(Hash) && step["uses"].to_s.start_with?("actions/upload-artifact")

    with = step["with"].is_a?(Hash) ? step["with"] : {}
    path = workflow.resolve(with["path"].to_s, {})
    next unless path.to_s.start_with?("benchmark-results/") && path.to_s.end_with?(".json")

    Upload.new(
      job: job_id,
      step: step.fetch("name", "unnamed step"),
      name: workflow.resolve(with["name"].to_s, {}),
      path: path,
      if_no_files_found: with["if-no-files-found"].to_s
    )
  end
end

def download_patterns(workflow:, job:)
  Array(job["steps"]).filter_map do |step|
    next unless step.is_a?(Hash) && step["uses"].to_s.start_with?("actions/download-artifact")

    with = step["with"].is_a?(Hash) ? step["with"] : {}
    workflow.resolve((with["pattern"] || with["name"]).to_s, {})
  end.compact
end

def summarizing?(job)
  Array(job["steps"]).any? { |step| step.is_a?(Hash) && step["run"].to_s.include?("benchmark-report.py summarize") }
end

SUMMARIZE_FLAGS = %w[title input-dir output-dir].freeze

def summarize_flags(job)
  Array(job["steps"]).flat_map do |step|
    next [] unless step.is_a?(Hash)

    step["run"].to_s[/benchmark-report\.py\s+summarize\b.*/m].to_s.scan(/--([a-z-]+)/).flatten
  end.uniq
end

CANARY_SUFFIX = "-canary"

repos_dir = ARGV[0] || ENV.fetch("BENCHMARK_REPOS_DIR", default_repos_dir)
abort "benchmark repos directory not found: #{repos_dir}" unless Dir.exist?(repos_dir)

canonical_reporter = File.expand_path("canonical/benchmark-report.py", __dir__)
errors = []
checked = 0

Dir[File.join(repos_dir, "benchmark-*")].select { |path| File.directory?(path) }.sort.each do |repo_dir|
  repo = File.basename(repo_dir)

  reporter = File.join(repo_dir, "scripts", "benchmark-report.py")
  if File.file?(reporter) && File.file?(canonical_reporter) && File.read(reporter) != File.read(canonical_reporter)
    errors << "#{repo}/scripts/benchmark-report.py: has drifted from scripts/canonical/benchmark-report.py"
  end

  Dir[File.join(repo_dir, ".github", "workflows", "*.{yml,yaml}")].sort.each do |path|
    relative = "#{repo}/.github/workflows/#{File.basename(path)}"
    document = begin
      YAML.safe_load(File.read(path), aliases: true)
    rescue Psych::Exception
      next
    end
    next unless document.is_a?(Hash) && document["jobs"].is_a?(Hash)

    workflow = Workflow.new(document, relative)
    report_jobs = workflow.jobs.select { |_, job| job.is_a?(Hash) && summarizing?(job) }
    next if report_jobs.empty?

    checked += 1
    report_jobs.each do |job_id, job|
      unexpected = summarize_flags(job) - SUMMARIZE_FLAGS
      next if unexpected.empty?

      errors << "#{relative} (#{job_id}): summarize reads every benchmark in its input directory; drop --#{unexpected.join(", --")}"
    end

    producers = workflow.jobs.flat_map do |job_id, job|
      job.is_a?(Hash) ? producers_for(workflow: workflow, repo_dir: repo_dir, job_id: job_id, job: job) : []
    end
    if producers.empty?
      errors << "#{relative}: a summarizing workflow must produce phase evidence in the same run"
      next
    end

    uploads = report_jobs.flat_map { |job_id, job| uploads_for(workflow: workflow, job_id: job_id, job: job) }
    producer_stems = producers.map(&:stem).uniq.sort
    upload_stems = uploads.map(&:stem).uniq.sort

    (upload_stems - producer_stems).each do |stem|
      errors << "#{relative}: retains #{stem}.json, which no benchmark job in this workflow produces (produced: #{producer_stems.join(", ")})"
    end
    (producer_stems - upload_stems).each do |stem|
      jobs = producers.select { |producer| producer.stem == stem }.map(&:job).uniq.sort
      errors << "#{relative}: #{jobs.join(", ")} produce #{stem}.json, which the report never retains"
    end

    uploads.each do |upload|
      expected_name = "benchmark-#{upload.stem}"
      unless upload.name == expected_name
        errors << "#{relative} (#{upload.step}): artifact name #{upload.name.inspect} must match its result file as #{expected_name.inspect}"
      end
      next if upload.if_no_files_found == "error"

      errors << "#{relative} (#{upload.step}): benchmark results must be retained with if-no-files-found: error"
    end

    patterns = report_jobs.values.flat_map { |job| download_patterns(workflow: workflow, job: job) }
    producers.each do |producer|
      next if report_jobs.key?(producer.job)
      next if patterns.any? { |pattern| File.fnmatch?(pattern, producer.phase_artifact) }

      errors << "#{relative}: the report never downloads #{producer.phase_artifact} (patterns: #{patterns.join(", ")})"
    end

    report_jobs.each do |job_id, job|
      lanes = producers.map(&:lane).uniq
      next unless lanes.length == 1

      expected_phases = LANE_PHASE_LABELS.fetch(lanes.first, [])
      missing = expected_phases - producers.map(&:phase_label).uniq
      next if missing.empty?

      errors << "#{relative} (#{job_id}): the #{lanes.first} lane needs #{missing.join(", ")} evidence to summarize"
    end

    next unless workflow.declares_input?("benchmark_id_suffix")

    canary = Workflow.new(document, relative, "benchmark_id_suffix" => CANARY_SUFFIX)
    canary_producers = canary.jobs.flat_map do |job_id, job|
      job.is_a?(Hash) ? producers_for(workflow: canary, repo_dir: repo_dir, job_id: job_id, job: job) : []
    end
    canary_uploads = report_jobs.keys.flat_map { |job_id| uploads_for(workflow: canary, job_id: job_id, job: canary.jobs[job_id]) }
    (canary_producers.map(&:stem).uniq.sort - canary_uploads.map(&:stem).uniq.sort).each do |stem|
      errors << "#{relative}: a benchmark_id_suffix dispatch produces #{stem}.json, which the report never retains; carry the suffix into the retained result"
    end
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "benchmark report contract aligned: #{checked} workflows"
