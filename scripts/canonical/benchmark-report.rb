#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "fileutils"
require "open3"
require "net/http"
require "uri"
require "timeout"

module BenchmarkReport
  SCHEMA_VERSION = 1
  PRODUCT_REF_FIELDS = %w[schema_version cli_version action_ref action_sha web_revision api_url].freeze
  PROVIDERS = {"actions-cache" => "Actions Cache", "boringcache" => "BoringCache",
    "boringcache-mountcache" => "BoringCache mount cache", "boringcache-native" => "BoringCache native",
    "boringcache-toolcache" => "BoringCache tool cache", "boringcache-turbo" => "BoringCache Turbo",
    "buildbuddy" => "BuildBuddy", "buildbuddy-cache" => "BuildBuddy", "ecr-cache" => "Amazon ECR (retired)",
    "nativelink" => "NativeLink (R2)", "cachix" => "Cachix", "bazel-remote" => "bazel-remote",
    "registry-cache" => "Registry cache", "depot-cache" => "Depot Cache"}.freeze
  PHASES = {"cold" => "Cold build", "warm" => "Warm build", "commit" => "Changed-source build"}.freeze
  OBSERVATIONS = {"seed" => "Seed build", "replay" => "Identical-source replay", "changed-source" => "Changed-source build"}.freeze
  METRICS = {"build_and_reuse_seconds" => "build and cache reuse (s)", "build_seconds" => "build (s)",
    "storage_bytes" => "storage (bytes)", "total_seconds" => "cache and build (s)"}.freeze
  LANES = {"fresh" => %w[cold warm], "rolling" => %w[commit]}.freeze
  RUN_FIELDS = {"cold" => %w[cold_seconds cold_build_seconds cold_restore_or_setup_seconds],
    "warm" => %w[warm1_seconds warm1_build_seconds warm1_restore_or_setup_seconds],
    "commit" => ["rolling_first_build_seconds", nil, nil]}.freeze
  ADAPTERS = {"docker" => "oci", "buildkit" => "oci", "go" => "gocache", "cargo" => "sccache",
    "node" => "runtime", "reapi" => "runtime", "turbo" => "turborepo", "command" => "archive"}.freeze
  class Error < StandardError; end

  def self.options(argv)
    command = argv.shift
    raise Error, "Use phase or summarize" unless %w[phase summarize].include?(command)
    args = {"variant" => "", "restore_or_setup_seconds" => 0, "workflow_seconds" => nil,
      "output_dir" => "benchmark-results", "baseline_strategy" => "actions-cache",
      "series" => ENV["BENCHMARK_SERIES_ID"], "sample" => ENV["BENCHMARK_SAMPLE"],
      "verification_passed" => false, "evidence_links" => []}
    parser = OptionParser.new
    %w[benchmark strategy lane phase mode variant cache_hit cache_import_ready cache_import_refs cache_tag
      workspace storage_key source_repository source_sha evidence output_dir title input_dir baseline_strategy sccache_proof series cli_version storage_evidence].each do |name|
      parser.on("--#{name.tr('_', '-')} VALUE") { |value| args[name] = value }
    end
    parser.on("--sample NUMBER", Integer) { |value| args["sample"] = value }
    parser.on("--verified-output") { args["verification_passed"] = true }
    parser.on("--evidence-link URL") { |value| args["evidence_links"] << value }
    parser.on("--comparison-seconds SECONDS", Float) do |value|
      raise Error, "Comparison time must be finite and nonnegative" unless value.finite? && value >= 0
      args["comparison_seconds"] = value
    end
    %w[build_seconds restore_or_setup_seconds workflow_seconds dependency_setup_seconds compile_seconds verification_seconds save_seconds].each do |name|
      parser.on("--#{name.tr('_', '-')} SECONDS", Float) do |value|
        raise Error, "#{name} must be finite and nonnegative" unless value.finite? && value >= 0
        args[name] = value == value.to_i ? value.to_i : value
      end
    end
    parser.parse!(argv)
    raise Error, "Unexpected arguments: #{argv.join(' ')}" unless argv.empty?
    required = command == "phase" ? %w[benchmark strategy lane phase mode build_seconds source_repository source_sha] : %w[title input_dir]
    missing = required.select { |key| args[key].nil? || args[key].to_s.empty? }
    raise Error, "Missing options: #{missing.map { |key| '--' + key.tr('_', '-') }.join(', ')}" unless missing.empty?
    if command == "phase"
      raise Error, "Invalid lane or phase" unless LANES.fetch(args["lane"], []).include?(args["phase"])
      raise Error, "Source SHA must contain 40 hexadecimal characters" unless args["source_sha"].match?(/\A[0-9a-f]{40}\z/)
      %w[benchmark strategy].each { |key| raise Error, "Invalid #{key}" unless args[key].match?(/\A[a-zA-Z0-9._-]+\z/) }
    end
    [command, args]
  end

  def self.read_json(path)
    JSON.parse(File.read(path))
  end

  def self.write_json(path, payload)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(payload) + "\n")
  end

  def self.boolean(value)
    return true if %w[true 1 yes].include?(value.to_s.strip.downcase)
    return false if %w[false 0 no].include?(value.to_s.strip.downcase)
    nil
  end

  def self.strings(value)
    Array(value).select { |item| item.is_a?(String) && !item.strip.empty? }.map(&:strip)
  end

  def self.integer(value)
    return value if value.is_a?(Integer) && value >= 0
    return value.to_i if value.is_a?(Float) && value.finite? && value >= 0 && value == value.to_i
    return value.to_i if value.is_a?(String) && value.match?(/\A\d+\z/)
    nil
  end

  def self.github_identity
    %w[repository run_id run_attempt job workflow ref_name].to_h { |key| [key, ENV["GITHUB_#{key.upcase}"]] }.merge(
      %w[os arch name environment].to_h { |key| ["runner_#{key}", ENV["RUNNER_#{key.upcase}"]] },
      "runner_image" => ENV["ImageOS"], "runner_image_version" => ENV["ImageVersion"],
      "runner_class" => ENV["BENCHMARK_RUNNER_CLASS"])
  end

  def self.identity(args, restore)
    workspace = args.fetch("workspace", "").strip
    tag = args.fetch("cache_tag", "").strip
    tags = strings(restore["resolved_tags"]).uniq
    tags = strings(tag.split(",")) if tags.empty? && !tag.empty?
    tags = strings([restore["cache_tag"]]) if tags.empty?
    {"workspace" => workspace.empty? ? restore["workspace"] : workspace,
      "cache_tag" => tag.empty? ? restore["cache_tag"] : tag, "tags" => tags}
  end

  def self.boringcache_storage(identity)
    workspace, tags = identity.values_at("workspace", "tags")
    return unless workspace.is_a?(String) && !workspace.empty? && !tags.empty?
    output = Timeout.timeout(30) do
      stdout, _stderr, status = Open3.capture3("boringcache", "check", workspace, tags.join(","), "--no-git", "--no-platform", "--json")
      return unless status.success?
      stdout
    end
    payload = JSON.parse(output)
    entries = {}
    measured_tags = []
    observations = []
    Array(payload["results"]).each do |item|
      next unless item.is_a?(Hash)
      tag = %w[requested_tag requestedTag tag].filter_map { |field| item[field] }.find { |value| tags.include?(value) }
      next unless tag
      observations << item.slice("requested_tag", "requestedTag", "tag", "status", "cache_type", "cache_entry_id", "cacheEntryId",
        "manifest_root_digest", "manifestRootDigest", "kv_total_size", "kvTotalSize", "compressed_size", "compressedSize", "size_bytes", "sizeBytes", "size")
      next unless item["status"] == "hit"
      key = %w[cache_entry_id cacheEntryId manifest_root_digest manifestRootDigest requested_tag requestedTag tag].filter_map { |field| item[field] }.find { |value| value.is_a?(String) && !value.empty? }
      size_fields = item["cache_type"] == "cache_entry" ? %w[compressed_size compressedSize size_bytes sizeBytes size] : %w[kv_total_size kvTotalSize compressed_size compressedSize size_bytes sizeBytes size]
      size = size_fields.filter_map { |field| integer(item[field]) }.first
      next unless tag && key && size
      measured_tags << tag
      entries[key] = [entries.fetch(key, 0), size].max
    end
    total = entries.values.sum
    unmeasured_tags = tags - measured_tags
    complete = unmeasured_tags.empty?
    {"bytes" => complete ? total : nil, "source" => complete ? "boringcache-check" : nil,
      "breakdown" => identity.slice("workspace", "tags").merge("complete" => complete,
        "measured_bytes" => total, "unmeasured_tags" => unmeasured_tags,
        "total_bytes" => complete ? total : nil, "observations" => observations)}
  rescue Errno::ENOENT, Timeout::Error, JSON::ParserError
    nil
  end

  def self.actions_storage(key)
    repository, token = ENV.values_at("GITHUB_REPOSITORY", "GITHUB_TOKEN")
    return unless repository && token && key && !key.empty?
    api = ENV.fetch("GITHUB_API_URL", "https://api.github.com").delete_suffix("/")
    url = URI("#{api}/repos/#{repository}/actions/caches?#{URI.encode_www_form(per_page: 100, key: key)}")
    observations = []
    seen = {}
    while url
      raise Error, "Cache pagination repeated a page" if seen[url.to_s]
      seen[url.to_s] = true
      request = Net::HTTP::Get.new(url, "Accept" => "application/vnd.github+json", "Authorization" => "Bearer #{token}", "X-GitHub-Api-Version" => "2022-11-28")
      response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https", open_timeout: 30, read_timeout: 30) { |http| http.request(request) }
      return unless response.is_a?(Net::HTTPSuccess)
      entries = JSON.parse(response.body)["actions_caches"]
      return unless entries.is_a?(Array)
      entries.each do |entry|
        next unless entry.is_a?(Hash) && entry["key"] == key
        observations << entry.slice("id", "key", "ref", "version", "created_at", "last_accessed_at", "size_in_bytes")
      end
      next_link = response["Link"].to_s.split(",").find { |link| link.include?('rel="next"') }
      url = next_link && URI(next_link[/<([^>]+)>/, 1])
      origin = URI(api)
      raise Error, "Cache pagination changed API origin" if url && [url.scheme, url.host, url.port] != [origin.scheme, origin.host, origin.port]
    end
    sizes = observations.map { |entry| integer(entry["size_in_bytes"]) }
    complete = !observations.empty? && sizes.none?(&:nil?)
    total = sizes.compact.sum
    {"bytes" => complete ? total : nil, "source" => complete ? "github-actions-cache-api" : nil,
      "breakdown" => {"key" => key, "complete" => complete, "measured_bytes" => total,
        "total_bytes" => complete ? total : nil, "observations" => observations}}
  rescue IOError, SystemCallError, Timeout::Error, JSON::ParserError, URI::InvalidURIError, Error
    nil
  end

  def self.phase(args)
    evidence = args["evidence"] && File.file?(args["evidence"]) ? read_json(args["evidence"]) : {}
    restore = evidence.dig("phases", "restore") || {}
    cache_identity = identity(args, restore)
    storage = case args["strategy"]
    when "boringcache" then boringcache_storage(cache_identity)
    when "actions-cache" then actions_storage(args["storage_key"])
    when "nativelink" then read_json("benchmark-results/nativelink/storage.json")
    end
    if args["storage_evidence"]
      raise Error, "External storage measurements cannot replace BoringCache product evidence" if args["strategy"] == "boringcache"
      measured = read_json(args.fetch("storage_evidence"))
      sources = {"cachix" => "cachix-narinfo-file-size", "bazel-remote" => "bazel-remote-local-store-files"}
      raise Error, "Unexpected provider storage source" unless measured["source"] == sources[args["strategy"]]
      raise Error, "Invalid provider storage bytes" unless measured["bytes"].nil? || (measured["bytes"].is_a?(Integer) && measured["bytes"] >= 0)
      storage = measured
    end
    plan = restore.dig("mode_evidence", "buildkit_cache")
    docker_plan = if plan.is_a?(Hash) && !plan.empty?
      {"import_tags" => strings(plan["cache_from_tags"]), "planned_import_refs" => strings(plan["cache_from_refs"]).length, "export_tag" => plan["cache_to_tag"]}
    end
    refs = evidence.fetch("product_refs", {}).select { |key, value| PRODUCT_REF_FIELDS.include?(key) && ![nil, ""].include?(value) }
    if args["cli_version"]
      raise Error, "Direct CLI version requires REAPI mode without Action evidence" unless args["mode"] == "reapi" && evidence.empty?
      raise Error, "Invalid CLI version" unless args["cli_version"].match?(/\A\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?\z/)
      refs = {"cli_version" => args["cli_version"]}
    end
    context = File.file?("benchmark-context.json") ? read_json("benchmark-context.json") : nil
    payload = {"schema_version" => SCHEMA_VERSION, "benchmark" => args["benchmark"], "strategy" => args["strategy"],
      "lane" => args["lane"], "phase" => args["phase"], "variant" => args["variant"].empty? ? nil : args["variant"],
      "mode" => args["mode"], "adapter" => ADAPTERS.fetch(args["mode"], args["mode"]), "case" => context,
      "timing" => args.slice("restore_or_setup_seconds", "build_seconds", "workflow_seconds").merge(
        "total_seconds" => args["restore_or_setup_seconds"] + args["build_seconds"],
        "dependency_setup_seconds" => args["dependency_setup_seconds"], "compile_seconds" => args["compile_seconds"],
        "verification_seconds" => args["verification_seconds"], "save_seconds" => args["save_seconds"]),
      "cache" => {"hit" => boolean(args["cache_hit"]), "sccache_proof" => boolean(args["sccache_proof"]),
        "import_ready" => boolean(args["cache_import_ready"]), "import_refs" => strings(args.fetch("cache_import_refs", "").lines).length,
        "docker_plan" => docker_plan, "tag" => cache_identity["cache_tag"], "workspace" => cache_identity["workspace"],
        "storage_bytes" => storage&.fetch("bytes"), "storage_source" => storage&.fetch("source"), "storage_breakdown" => storage&.fetch("breakdown")},
      "source" => {"repository" => args["source_repository"], "sha" => args["source_sha"]}, "product_refs" => refs,
      "action" => {"resolved_mode" => restore["mode"], "resolved_tags" => restore["resolved_tags"],
        "trust_state" => restore["trust_state"], "diagnostics_level" => restore["diagnostics_level"]},
      "github" => github_identity, "run_uid" => ENV["GITHUB_RUN_ID"] && "gh-#{ENV['GITHUB_RUN_ID']}-#{ENV.fetch('GITHUB_RUN_ATTEMPT', '1')}"}
    if context
      verified = args["verification_passed"] == true
      payload["verification"] = {"passed" => verified,
        "checks" => verified ? ["Output verification completed before recording this phase"] : [],
        "declared_checks" => context.fetch("verification", [])}
    end
    if args["lane"] == "rolling"
      observation = ENV.fetch("BENCHMARK_OBSERVATION", "changed-source")
      raise Error, "Invalid rolling observation" unless OBSERVATIONS.key?(observation)
      payload["observation"] = observation
    end
    series = args["series"] || ENV["BENCHMARK_SERIES_ID"]
    unless series.to_s.empty?
      raise Error, "Series recording requires a prepared case" unless context && context["comparison"]
      sample = Integer(args["sample"] || ENV.fetch("BENCHMARK_SAMPLE"))
      raise Error, "Series and sample must identify a declared observation" unless series.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/) && sample.positive?
      scope = context.fetch("comparison").fetch("timed_scope")
      payload["series"] = {"id" => series, "sample" => sample}
      payload["environment"] = {"os" => ENV["RUNNER_OS"], "arch" => ENV["RUNNER_ARCH"], "image" => ENV["ImageOS"],
        "image_version" => ENV["ImageVersion"], "machine" => ENV["BENCHMARK_RUNNER_CLASS"]}
      payload["evidence_links"] = Array(args["evidence_links"])
      if ENV["GITHUB_REPOSITORY"] && ENV["GITHUB_RUN_ID"]
        payload["evidence_links"] << "https://github.com/#{ENV['GITHUB_REPOSITORY']}/actions/runs/#{ENV['GITHUB_RUN_ID']}"
      end
      payload["timing"]["comparison_scope"] = scope
      payload["timing"]["build_and_reuse_seconds"] = args.fetch("comparison_seconds", payload["timing"].fetch("total_seconds"))
    end
    slug = args["variant"].empty? ? "" : "-#{args['variant'].gsub(/[^a-zA-Z0-9]/, '-').sub(/\A-+/, '').sub(/-+\z/, '').downcase}"
    path = File.join(args["output_dir"], "#{args['benchmark']}-#{args['strategy']}#{slug}-#{args['lane']}-#{args['phase']}.json")
    raise Error, "Phase record already exists: #{path}" if File.exist?(path)
    write_json(path, payload)
    puts path
    payload
  end

  def self.merge_lane(benchmark, strategy, lane, phases)
    by_phase = phases.to_h { |payload| [payload.fetch("phase"), payload] }
    raise Error, "Duplicate phase records for #{benchmark} #{strategy} #{lane}" unless by_phase.length == phases.length
    runs = {}
    RUN_FIELDS.each do |name, (total, build, setup)|
      next unless (timing = by_phase.dig(name, "timing"))
      runs[total] = timing.fetch("total_seconds")
      runs[build] = timing.fetch("build_seconds") if build
      runs[setup] = timing.fetch("restore_or_setup_seconds") if setup
      runs["#{name}_workflow_seconds"] = timing["workflow_seconds"] if timing["workflow_seconds"]
    end
    reference = by_phase["commit"] || by_phase["warm"] || by_phase["cold"]
    raise Error, "No usable phase evidence for #{benchmark} #{strategy} #{lane}" unless reference
    refs = phases.filter_map { |payload| payload["product_refs"] if payload["product_refs"].is_a?(Hash) && !payload["product_refs"].empty? }
    observations = phases.to_h do |payload|
      cache = payload.fetch("cache")
      [payload["phase"], {"cache_hit" => cache["hit"], "sccache_proof" => cache["sccache_proof"], "cache_import_ready" => cache["import_ready"], "cache_import_refs" => cache["import_refs"]}]
    end
    {"schema_version" => SCHEMA_VERSION, "benchmark" => benchmark, "strategy" => strategy, "lane" => lane,
      "mode" => reference["mode"], "adapter" => reference["adapter"], "case" => reference["case"], "runs" => runs,
      "speed" => {"warm_average_seconds" => by_phase.dig("warm", "timing", "total_seconds")}, "cache" => reference["cache"],
      "source" => reference["source"], "product_refs" => reference["product_refs"].to_h.empty? ? (refs.first || {}) : reference["product_refs"],
      "product_refs_consistent" => refs.empty? ? nil : refs.length == phases.length && refs.uniq.length == 1,
      "phase_observations" => observations, "workspace" => reference.dig("cache", "workspace"),
      "cache_tag" => reference.dig("cache", "tag"), "run_uid" => reference["run_uid"], "github" => reference["github"]}
  end

  def self.seconds(value)
    return "unmeasured" if value.nil?
    "#{value}s"
  end

  def self.cache_state(payload)
    cache = payload.fetch("cache", {})
    return "import not ready" if cache["import_ready"] == false
    if %w[docker buildkit].include?(payload["mode"])
      if cache["import_ready"].nil?
        count = cache.dig("docker_plan", "planned_import_refs")
        return count ? "reuse not measured (#{count} refs planned)" : "not reported"
      end
      refs = cache["import_refs"]
      return refs.to_i.positive? ? "imported #{refs} ref#{refs == 1 ? '' : 's'}" : "nothing to import"
    end
    {true => "hit", false => "miss"}.fetch(cache["hit"], "not reported")
  end

  def self.markdown(title, phases, baseline)
    lines = ["## #{title}", "",
      "| Workload | Lane | Provider | Phase | Cache setup | Build | Dependency setup* | Compile* | Cache + build | Workflow | Cache |",
      "| --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |"]
    phases.sort_by { |item| [item["benchmark"], item["lane"], item["phase"], item["strategy"], item["variant"].to_s] }.each do |item|
      label = PROVIDERS.fetch(item["strategy"], item["strategy"])
      label += " (#{item['variant']})" if item["variant"]
      timing = item.fetch("timing")
      values = %w[restore_or_setup_seconds build_seconds dependency_setup_seconds compile_seconds total_seconds workflow_seconds].map { |name| seconds(timing[name]) }
      phase = item["observation"] ? OBSERVATIONS.fetch(item["observation"]) : PHASES.fetch(item["phase"])
      lines << "| #{item['benchmark']} | #{item['lane']} | #{label} | #{phase} | #{values.join(' | ')} | #{cache_state(item)} |"
    end
    lines += ["", "*Dependency setup and compile can overlap the build measurement. Workflow time is measured separately.", ""]
    lines += ["Comparator: #{PROVIDERS.fetch(baseline, baseline)}.", ""] if phases.map { |item| item["strategy"] }.uniq.length > 1
    phases.map { |item| item["source"] }.uniq.each { |source| lines << "Source: `#{source['repository']}@#{source['sha']}`" }
    lines.join("\n") + "\n"
  end

  def self.summarize(args)
    phases = Dir[File.join(args.fetch("input_dir"), "**", "*.json")].sort.filter_map do |path|
      payload = read_json(path)
      payload if payload.is_a?(Hash) && payload["schema_version"] == SCHEMA_VERSION && payload["phase"]
    end
    raise Error, "No benchmark phase evidence found under #{args['input_dir']}" if phases.empty?
    phases.group_by { |item| [item["benchmark"], item["lane"]] }.each do |(benchmark, lane), group|
      sources = group.map { |item| item["source"] }.uniq
      raise Error, "Missing source SHA for #{benchmark} #{lane}" if sources.any? { |source| !source.is_a?(Hash) || !source["sha"] }
      raise Error, "Mixed source SHAs for #{benchmark} #{lane}" unless sources.length == 1
      contexts = group.map { |item| item["case"] }.uniq
      raise Error, "Mixed case definitions for #{benchmark} #{lane}" unless contexts.length == 1
    end
    phases.group_by { |item| [item["benchmark"], item["strategy"], item["variant"].to_s, item["lane"]] }.each do |(benchmark, strategy, variant, lane), group|
      merged = merge_lane(benchmark, strategy, lane, group)
      merged["variant"] = variant.empty? ? nil : variant
      slug = variant.empty? ? "" : "-#{variant.gsub(/[^a-zA-Z0-9]/, '-').downcase}"
      path = File.join(args["output_dir"], "#{benchmark}-#{strategy}#{slug}-#{lane}.json")
      write_json(path, merged)
      puts path
    end
    content = markdown(args["title"], phases, args["baseline_strategy"])
    File.write(File.join(args["output_dir"], "comparison.md"), content)
    File.open(ENV["GITHUB_STEP_SUMMARY"], "a") { |file| file.write(content) } if ENV["GITHUB_STEP_SUMMARY"]
  end

  def self.main(argv)
    command, args = options(argv)
    command == "phase" ? phase(args) : summarize(args)
  rescue Error, OptionParser::ParseError, JSON::ParserError => error
    warn error.message
    exit 1
  end
end

BenchmarkReport.main(ARGV) if $PROGRAM_NAME == __FILE__
