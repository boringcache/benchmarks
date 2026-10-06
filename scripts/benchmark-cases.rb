# frozen_string_literal: true

require "json"
require "json_schemer"
require "yaml"
require "digest"
require "fileutils"
require "open3"
require "pathname"
require "time"
require "tempfile"
require "tmpdir"
require "zlib"
require "toml-rb"
require "rbconfig"
require "cgi"
require_relative "docker-case-contract"
require_relative "benchmark-series"
require_relative "native-case"

module BenchmarkCases
  ROOT = File.expand_path("..", __dir__)
  WORKSPACE = "boringcache/benchmarks"
  REPOSITORY = "boringcache/benchmarks"
  HELPERS = %w[benchmark-plan benchmark-phase run-benchmark-plan activate-docker-plan verify-docker-output summarize-cargo-evidence summarize-sccache-errors docker-case-contract measure-build native-case prepare-source scope-case-cache benchmark-cli benchmark-storage benchmark-candidate compiler-cache-setup nix-benchmark reapi-registry reapi-client reapi-setup].freeze
  class Error < StandardError; end

  def self.command(*args, chdir: nil, stdin: "", env: {})
    options = {stdin_data: stdin}
    options[:chdir] = chdir if chdir
    output, error, status = Open3.capture3(env, *args, **options)
    raise Error, "#{args.first} failed: #{error.strip}" unless status.success?
    output
  end

  def self.write_json(path, value)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(value) + "\n")
  end

  def self.definition_sha256(item, root: ROOT)
    directory = File.join(root, "cases", item.fetch("id"))
    files = Dir.glob(File.join(directory, "**", "*"), File::FNM_DOTMATCH).select { |path| File.file?(path) }
    files += item.dig("execution", "workflows").map { |entry| File.join(root, entry.fetch("path")) }
    files += HELPERS.map { |name| File.join(root, "scripts", "#{name}.rb") }
    files += %w[scripts/canonical/benchmark-report.rb scripts/verify-upstream-recipe.rb scripts/benchmark-cases.rb scripts/benchmark-series.rb scripts/benchmark-identity.rb scripts/fresh-report.rb scripts/nightly-canaries.rb bin/bench Gemfile.lock .tool-versions].map { |path| File.join(root, path) }
    files << File.join(root, "config/cli.json")
    files += shared_action_files(root: root)
    files += Dir.glob(File.join(root, "adapters", "docker", "**", "*"), File::FNM_DOTMATCH).select { |path| File.file?(path) } if item["adapter"] == "docker"
    manifest = files.uniq.sort.to_h { |path| [path.delete_prefix(root + "/"), Digest::SHA256.file(path).hexdigest] }
    Digest::SHA256.hexdigest(JSON.generate({"case" => item, "files" => manifest}))
  end

  def self.documents(root = ROOT)
    Dir[File.join(root, "cases", "*", "case.json")].sort.map { |path| JSON.parse(File.read(path)) }
  end

  def self.load_case(id, root = ROOT)
    raise Error, "Invalid case ID: #{id}" unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    path = File.join(root, "cases", id, "case.json")
    raise Error, "Unknown case: #{id}" unless File.file?(path)
    JSON.parse(File.read(path))
  end

  def self.create(id, repository:, revision:, question:, root: ROOT, shape: nil, tool_version: nil)
    raise Error, "Invalid case ID" unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    raise Error, "Use OWNER/REPOSITORY" unless repository.match?(%r{\A[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\z})
    raise Error, "Use a full lowercase source SHA" unless revision.match?(/\A[0-9a-f]{40}\z/)
    raise Error, "Declare the evaluation question" if question.strip.empty?
    raise Error, "Supported execution shape: go" if shape && shape != "go"
    raise Error, "Use --shape go with an exact --tool-version X.Y.Z" if (shape || tool_version) && (!shape || !tool_version.to_s.match?(/\A\d+\.\d+\.\d+\z/))
    directory = File.join(root, "cases", id)
    raise Error, "Case already exists: #{id}" if File.exist?(directory)
    item = {"schema_version" => 1, "id" => id, "kind" => "evaluation", "adapter" => "workflow", "workspace" => WORKSPACE,
      "source" => {"repository" => repository, "revision" => revision, "pins" => [{"path" => "proposal.md", "kind" => "snapshot", "revision" => revision}]},
      "origin" => {"repository" => repository, "branch" => "pinned", "revision" => revision},
      "execution" => {"sync" => "fixed", "workflows" => [], "blockers" => ["Review the recipe, provider plans, measurement boundary, and output checks; add and verify the workflow before execution"]},
      "reporting" => {"entries" => [], "publication" => "evaluation-only"}, "verification" => ["Define and verify the expected upstream outputs"],
      "comparison" => {"question" => question, "providers" => ["boringcache"], "primary_metric" => "correctness",
        "timed_scope" => "Define the build and reuse operation before collecting timings", "storage" => "unmeasured",
        "cache_scope" => "Isolated case and series identity; declare warm continuity before execution", "sample_count" => 2}}
    if shape == "go"
      require_relative "benchmark-scaffold"
      BenchmarkScaffold.go(item, directory: directory, tool_version: tool_version)
    end
    write_json(File.join(directory, "case.json"), item)
    File.write(File.join(directory, "proposal.md"), "# #{id}\n\nQuestion: #{question}\n\nSource: https://github.com/#{repository}/tree/#{revision}\n\nFollow [the case process](../../docs/process.md). Execution is blocked until the recipe, comparison, workflow, and outputs are reviewed and verified.\n")
    item
  end

  def self.validate(cases = documents, root: ROOT)
    schema = JSONSchemer.schema(JSON.parse(File.read(File.join(root, "schemas", "case.schema.json"))))
    errors = []
    cases.each do |item|
      id = item["id"]
      schema.validate(item).each { |error| errors << "#{id}: #{error.fetch('error')}" }
      next unless schema.valid?(item)
      item.fetch("execution").fetch("workflows").each do |entry|
        if entry.fetch("lane") != "diagnostic"
          begin
            BenchmarkSeries.phases_for(entry.fetch("lane"), entry["phases"])
          rescue BenchmarkSeries::Error => error
            errors << "#{id}: #{error.message}"
          end
        end
        path = File.join(root, entry.fetch("path"))
        unless File.file?(path)
          errors << "#{id}: missing workflow #{entry.fetch('path')}"
          next
        end
        workflow = YAML.safe_load(File.read(path), aliases: true)
        events = workflow["on"] || workflow[true]
        declared = events.is_a?(Hash) && events["workflow_dispatch"]
        inputs = declared.is_a?(Hash) ? declared.fetch("inputs", {}) : {}
        Array(workflow["jobs"]&.values).each do |job|
          Array(job["steps"]).each do |step|
            if step["uses"].to_s.start_with?("actions/checkout@") && step.dig("with", "persist-credentials") != false
              errors << "#{id}: source checkouts must disable persisted credentials"
            end
          end
        end
        errors << "#{id}: workflow is not dispatchable" unless item["kind"] == "retained" || (events.is_a?(Hash) && events.key?("workflow_dispatch"))
        (entry.fetch("inputs").keys - inputs.keys).each { |name| errors << "#{id}: unknown input #{name}" }
        if entry["variant_input"]
          name = entry.fetch("variant_input")
          errors << "#{id}: variant_input must name a workflow input" unless inputs.key?(name)
          errors << "#{id}: variant_input requires declared variants" unless entry["variants"]
          if inputs.dig(name, "type") == "choice" && (Array(entry["variants"]) - inputs.dig(name, "options")).any?
            errors << "#{id}: variants differ from the workflow input choices"
          end
        end
        if File.basename(entry.fetch("path")).start_with?("native-") && item.dig("execution", "native", "variants")
          variants = item.dig("execution", "native", "variants").keys
          errors << "#{id}: native workflow variants differ from the reviewed recipes" unless entry["variant_input"] == "variant" && entry["variants"]&.sort == variants.sort
        end
        if inputs["cli_version"] && !inputs["cli_version"].fetch("default", "").to_s.empty?
          errors << "#{id}: cli_version must default to the Action's version"
        end
      end
      directory = File.join(root, "cases", id)
      if item["adapter"] == "docker"
        begin
          recipe = JSON.parse(File.read(File.join(directory, "recipe.json")))
          DockerCaseContract.validate(recipe, File.join(directory, "plans"))
          errors << "#{id}: recipe source differs from the case" unless recipe.dig("source", "repo") == item.dig("source", "repository")
          revisions = item.dig("source", "pins").select { |pin| pin["kind"] == "recipe" }.map { |pin| pin.fetch("revision") }.uniq.sort
          errors << "#{id}: recipe revisions differ from the case" unless revisions == recipe.fetch("refs").values.uniq.sort
        rescue StandardError => error
          errors << "#{id}: #{error.message}"
        end
      end
      payload = File.join(directory, "payload")
      begin
        NativeCase.validate(item, payload: payload, shared_root: root)
      rescue NativeCase::Error => error
        errors << "#{id}: #{error.message}"
      end
      helper_names = HELPERS.map { |name| "#{name}.rb" } + %w[benchmark-report.rb verify-upstream-recipe.rb]
      files = item.dig("execution", "workflows").map { |entry| File.join(root, entry.fetch("path")) }
      files += Dir[File.join(payload, ".github", "actions", "**", "*.{yml,yaml}")]
      files.select { |path| File.file?(path) }.each do |path|
        File.read(path).scan(%r{(?<![A-Za-z0-9_/.-])(?:\./)?scripts/([A-Za-z0-9_.-]+\.(?:rb|sh|py))}).flatten.uniq.each do |name|
          next if item["adapter"] == "docker" && File.file?(File.join(root, "adapters", "docker", "scripts", name))
          errors << "#{id}: #{path.delete_prefix(root + '/')} calls missing scripts/#{name}" unless helper_names.include?(name) || File.file?(File.join(payload, "scripts", name))
        end
        uses = File.read(path).scan(/^\s*(?:-\s*)?uses:\s*["']?([^\s"']+)/).flatten
        errors << "#{id}: use the shared BoringCache wrapper rather than copying its release pin" if uses.any? { |ref| ref.start_with?("boringcache/one@") }
        uses.reject { |ref| ref.start_with?("./") }.each do |ref|
          errors << "#{id}: Action reference must use a complete commit SHA: #{ref}" unless ref.match?(/@[0-9a-f]{40}\z/)
        end
      end
      item.fetch("source").fetch("pins").each do |pin|
        path = File.join(directory, pin.fetch("path"))
        if pin["kind"] == "gitlink"
          begin
            repository = pin.fetch("repository", item.dig("source", "repository"))
            url = command("git", "config", "-f", File.join(payload, ".gitmodules"), "--get", "submodule.#{pin.fetch('path')}.url").strip
            errors << "#{id}: gitlink repository differs from the case" unless url.delete_suffix(".git") == "https://github.com/#{repository}"
          rescue Error => error
            errors << "#{id}: #{error.message}"
          end
          next
        end
        next if pin["kind"] == "snapshot"
        if !File.file?(path)
          errors << "#{id}: missing source pin file #{pin.fetch('path')}"
        elsif pin["kind"] == "env"
          revisions = File.readlines(path).filter_map { |line| line.strip.split("=", 2).last if line.match?(/_SHA=/) }
          errors << "#{id}: source pin #{pin.fetch('revision')} is absent from #{pin.fetch('path')}" unless revisions.include?(pin.fetch("revision"))
        end
      end
      patch = item.dig("source", "patch")
      errors << "#{id}: missing source patch #{patch}" if patch && !File.file?(File.join(directory, patch))
      Dir[File.join(directory, "**", "*.toml"), File.join(directory, "**", ".boringcache.toml")].uniq.each do |path|
        next unless File.basename(path).include?("boringcache")
        begin
          declared_workspace = TomlRB.load_file(path).fetch("workspace")
          errors << "#{id}: #{path.delete_prefix(root + '/')} uses workspace #{declared_workspace}" unless declared_workspace == WORKSPACE
        rescue StandardError => error
          errors << "#{id}: invalid plan #{path.delete_prefix(root + '/')}: #{error.message}"
        end
      end
    end
    errors << "Duplicate case IDs" unless cases.map { |item| item["id"] }.uniq.length == cases.length
    raise Error, errors.join("\n") unless errors.empty?
    cases
  end

  def self.plan(item, lane: "fresh", workflow: nil, inputs: {}, variant: nil, root: ROOT)
    blockers = item.fetch("execution").fetch("blockers", [])
    raise Error, "#{item.fetch('id')}: #{blockers.join('; ')}" unless blockers.empty?
    entries = item.fetch("execution").fetch("workflows")
    entry = workflow ? entries.find { |value| File.basename(value.fetch("path")) == workflow } : entries.find { |value| value.fetch("lane") == lane }
    raise Error, "#{item.fetch('id')} has no #{workflow || lane} workflow" unless entry
    combined = entry.fetch("inputs").merge(inputs)
    if variant && entry["variant_input"]
      raise Error, "Variant is not supported by this workflow" unless entry.fetch("variants").include?(variant)
      name = entry.fetch("variant_input")
      raise Error, "#{name} differs from the declared variant" if combined.key?(name) && combined[name] != variant
      combined[name] = variant
    end
    if item.dig("execution", "native") && File.basename(entry.fetch("path")).start_with?("native-")
      raise Error, "case_id must match the selected case" unless combined["case_id"] == item.fetch("id")
      recipe = NativeCase.resolve(item.dig("execution", "native"), variant || combined["variant"])
      NativeCase.verify_report(recipe, payload: File.join(root, "cases", item.fetch("id"), "payload"), lane: entry.fetch("lane"), shared_root: root)
    end
    revisions = item.fetch("source").fetch("pins").map { |pin| pin.fetch("revision") }
    combined.each do |name, value|
      if name.end_with?("_sha") && (!value.match?(/\A[0-9a-f]{40}\z/) || !revisions.include?(value))
        raise Error, "#{name} must be an exact declared source pin; review and update the case before execution"
      end
      raise Error, "Invalid cache_scope" if name == "cache_scope" && !value.match?(/\A[a-z0-9][a-z0-9._-]+\z/)
      raise Error, "source_distance must be a positive integer" if name == "source_distance" && !value.match?(/\A[1-9]\d*\z/)
    end
    raise Error, "cache_lane must match the selected workflow lane" if combined["cache_lane"] && combined["cache_lane"] != entry.fetch("lane")
    if item["adapter"] == "docker" && combined["case_id"] != item.fetch("id").delete_prefix("docker-")
      raise Error, "case_id must match the selected case"
    end
    doc = YAML.safe_load(File.read(File.join(root, entry.fetch("path"))), aliases: true)
    declared = (doc["on"] || doc[true]).dig("workflow_dispatch", "inputs") || {}
    unknown = combined.keys - declared.keys
    raise Error, "Unknown workflow inputs: #{unknown.join(', ')}" unless unknown.empty?
    declared.each do |name, spec|
      value = combined.fetch(name, spec["default"])
      raise Error, "Missing required workflow input: #{name}" if spec["required"] && (value.nil? || value.to_s.empty?)
      next unless combined.key?(name)
      raise Error, "#{name} must be one of #{spec.fetch('options').join(', ')}" if spec["type"] == "choice" && !spec.fetch("options").include?(combined[name])
      raise Error, "#{name} must be true or false" if spec["type"] == "boolean" && !%w[true false].include?(combined[name])
    end
    {"case_id" => item.fetch("id"), "repository" => REPOSITORY, "workflow" => File.basename(entry.fetch("path")),
     "workspace" => WORKSPACE, "source" => item.fetch("source"), "lane" => entry.fetch("lane"), "inputs" => combined,
     "phases" => entry.fetch("lane") == "diagnostic" ? nil : BenchmarkSeries.phases_for(entry.fetch("lane"), entry["phases"]), "variants" => entry["variants"]}
  end

  def self.update_source(item, workload, root: ROOT)
    id = item.fetch("id")
    prefix = item.dig("execution", "source_prefix")
    if prefix
      path = File.join(workload, "benchmark-source.env")
      fields = File.readlines(path).filter_map do |line|
        key, value = line.strip.split("=", 2)
        [key, value] if key&.start_with?("#{prefix}_")
      end.to_h
      base, head = fields.values_at("#{prefix}_BASE_SHA", "#{prefix}_HEAD_SHA")
      raise Error, "Source repository differs from the case" unless fields["#{prefix}_SOURCE_REPOSITORY"] == item.dig("source", "repository")
      raise Error, "Source pair requires exact base and head SHAs" unless [base, head].all? { |sha| sha&.match?(/\A[0-9a-f]{40}\z/) }
      FileUtils.cp(path, File.join(root, "cases", id, "payload", "benchmark-source.env"))
      item["source"]["pins"] = item.fetch("source").fetch("pins").reject { |pin| pin["kind"] == "env" && pin["path"] == "payload/benchmark-source.env" } +
        [base, head].map { |sha| {"path" => "payload/benchmark-source.env", "revision" => sha, "kind" => "env"} }
      item.fetch("source").fetch("pins").select { |pin| pin["kind"] == "gitlink" }.each { |pin| pin["revision"] = head }
    else
      source = File.join(workload, "upstream")
      head = command("git", "rev-parse", "HEAD", chdir: source).strip
      item.fetch("source").fetch("pins").select { |pin| pin["kind"] == "gitlink" }.each { |pin| pin["revision"] = head }
    end
    write_json(File.join(root, "cases", id, "case.json"), item)
    item
  end

  def self.sync_source(item, root: ROOT)
    kind = item.fetch("execution").fetch("sync", "fixed")
    raise Error, "#{item.fetch('id')} has fixed source pins" if kind == "fixed"
    return sync_snapshot(item, root: root) if kind == "upstream-head" && item.dig("source", "revision")
    if kind == "upstream-head"
      pin = item.fetch("source").fetch("pins").find { |value| value["kind"] == "gitlink" }
      branch, _, status = Open3.capture3("git", "config", "-f", File.join(root, "cases", item.fetch("id"), "payload", ".gitmodules"), "--get", "submodule.#{pin.fetch('path')}.branch")
      branch = status.success? ? branch.strip : JSON.parse(command("gh", "api", "repos/#{item.dig('source', 'repository')}" )).fetch("default_branch")
      target_sha = JSON.parse(command("gh", "api", "repos/#{item.dig('source', 'repository')}/commits/#{CGI.escape(branch)}")).fetch("sha")
      return {"case_id" => item.fetch("id"), "updated" => false} if target_sha == pin.fetch("revision")
    end
    Dir.mktmpdir("benchmark-source-") do |directory|
      workload = prepare(item, directory: File.join(directory, "workload"), root: root)
      if kind == "upstream-head"
        source = File.join(workload, "upstream")
        # Inspect only the candidate tree. Ancestry is checked against the exact
        # declared pin through the compare endpoint below.
        unless File.exist?(File.join(source, ".git"))
          command("git", "init", source)
          command("git", "remote", "add", "origin", "https://github.com/#{item.dig('source', 'repository')}.git", chdir: source)
        end
        command("git", "fetch", "--depth", "1", "origin", "refs/heads/#{branch}", chdir: source)
        next_sha = command("git", "rev-parse", "FETCH_HEAD", chdir: source).strip
        current_sha = item.fetch("source").fetch("pins").find { |pin| pin["kind"] == "gitlink" }.fetch("revision")
        return {"case_id" => item.fetch("id"), "updated" => false} if next_sha == current_sha
        raise Error, "Upstream moved during source inspection; retry with new inputs" unless next_sha == target_sha
        command("git", "checkout", "--detach", next_sha, chdir: source)
        comparison = JSON.parse(command("gh", "api", "repos/#{item.dig('source', 'repository')}/compare/#{current_sha}...#{next_sha}"))
        raise Error, "Upstream source is not a fast-forward from the declared pin" unless comparison["status"] == "ahead" && comparison.dig("merge_base_commit", "sha") == current_sha
        verify_recipe(workload)
        update_source(item, workload, root: root)
        {"case_id" => item.fetch("id"), "updated" => true, "base_sha" => current_sha, "head_sha" => next_sha}
      else
        old_source = File.read(File.join(workload, "benchmark-source.env"))
        old_settings = BenchmarkPlan.settings(File.join(workload, "benchmark-source.env"))
        output_path = File.join(directory, "outputs")
        args = ["bash", "scripts/advance-source-pair.sh", "benchmark-source.env", item.fetch("execution").fetch("source_prefix")]
        args << "check_dependencies" if kind == "verified-pair"
        command(*args, chdir: workload, env: {"GITHUB_OUTPUT" => output_path})
        fields = File.exist?(output_path) ? File.readlines(output_path).to_h { |line| line.strip.split("=", 2) } : {}
        updated = File.read(File.join(workload, "benchmark-source.env")) != old_source
        if updated
          prefix = item.dig("execution", "source_prefix")
          values = BenchmarkPlan.settings(File.join(workload, "benchmark-source.env"))
          repository = values.fetch("#{prefix}_SOURCE_REPOSITORY")
          source = File.join(workload, "upstream")
          unless Dir.exist?(File.join(source, ".git")) || File.file?(File.join(source, ".git"))
            command("git", "clone", "--filter=blob:none", "--no-checkout", "https://github.com/#{repository}.git", source)
          end
          values.values_at("#{prefix}_BASE_SHA", "#{prefix}_HEAD_SHA").each do |sha|
            raise Error, "Source pair requires exact revisions" unless sha&.match?(/\A[0-9a-f]{40}\z/)
            command("git", "fetch", "--depth", "2", "origin", sha, chdir: source)
            command("git", "checkout", "--detach", sha, chdir: source)
            verify_recipe(workload)
          end
        end
        update_source(item, workload, root: root) if updated && kind != "verified-pair"
        fields.merge!("base_sha" => values.fetch("#{prefix}_BASE_SHA"), "head_sha" => values.fetch("#{prefix}_HEAD_SHA"),
          "previous_sha" => old_settings.fetch("#{prefix}_HEAD_SHA")) if updated
        fields.merge("case_id" => item.fetch("id"), "updated" => updated, "requires_verified_build" => kind == "verified-pair",
          "candidate_source_env" => updated && File.read(File.join(workload, "benchmark-source.env")))
      end
    end
  end

  def self.sync_snapshot(item, root: ROOT)
    repository = item.dig("source", "repository")
    current = item.dig("source", "revision")
    branch = item.dig("origin", "branch")
    head = JSON.parse(command("gh", "api", "repos/#{repository}/commits/#{CGI.escape(branch)}")).fetch("sha")
    return {"case_id" => item.fetch("id"), "updated" => false} if head == current
    raise Error, "Upstream returned an invalid revision" unless head.match?(/\A[0-9a-f]{40}\z/)
    comparison = JSON.parse(command("gh", "api", "repos/#{repository}/compare/#{current}...#{head}"))
    unless comparison["status"] == "ahead" && comparison.dig("merge_base_commit", "sha") == current
      raise Error, "Upstream source is not a fast-forward from the declared pin"
    end
    candidate = Marshal.load(Marshal.dump(item))
    candidate.fetch("source")["revision"] = head
    candidate.dig("source", "pins").each do |pin|
      raise Error, "Snapshot has independently pinned sources; review them before advancement" unless pin["revision"] == current
      pin["revision"] = head
    end
    Dir.mktmpdir("benchmark-source-") do |directory|
      workload = prepare(candidate, directory: File.join(directory, "workload"), root: root)
      command(RbConfig.ruby, File.join(workload, "scripts/verify-upstream-recipe.rb"), workload, chdir: workload)
    end
    # Only the exact source URI changes; recipe digests and build flags stay reviewed.
    payload = File.join(root, "cases", item.fetch("id"), "payload")
    reference = "github:#{repository}/#{current}#default"
    replacement = "github:#{repository}/#{head}#default"
    %w[.boringcache.toml recipe-contract.json].each do |name|
      path = File.join(payload, name)
      next unless File.file?(path)
      content = File.read(path)
      File.write(path, content.gsub(reference, replacement)) if content.include?(reference)
    end
    write_json(File.join(root, "cases", item.fetch("id"), "case.json"), candidate)
    {"case_id" => item.fetch("id"), "updated" => true, "base_sha" => current, "head_sha" => head}
  end

  def self.verify_recipe(workload)
    path = File.join(workload, "recipe-contract.json")
    raise Error, "Source advancement requires a reviewed recipe contract" unless File.file?(path)
    command(RbConfig.ruby, File.join(workload, "scripts", "verify-upstream-recipe.rb"), chdir: workload)
  end

  def self.dispatch(item, lane:, workflow: nil, inputs: {}, ref: "main", output:)
    selected = plan(item, lane: lane, workflow: workflow, inputs: inputs)
    receipt = selected.merge("schema_version" => 1, "requested_at" => Time.now.utc.iso8601, "ref" => ref, "state" => "planned")
    write_json(output, receipt)
    result = command("gh", "api", "repos/#{REPOSITORY}/actions/workflows/#{selected.fetch('workflow')}/dispatches",
      "--method", "POST", "--input", "-", stdin: JSON.generate({"ref" => ref, "inputs" => selected.fetch("inputs"), "return_run_details" => true}))
    response = JSON.parse(result)
    id = response["workflow_run_id"]
    raise Error, "Dispatch returned no run ID; inspect the planned receipt before retrying" unless id.is_a?(Integer) && id.positive?
    receipt.merge!("state" => "requested", "run_id" => id, "run_url" => "https://github.com/#{REPOSITORY}/actions/runs/#{id}")
    write_json(output, receipt)
    receipt
  end

  def self.prepare(item, directory:, root: ROOT, native_lane: nil, suffix: "", variant: nil)
    blockers = item.fetch("execution").fetch("blockers", [])
    raise Error, "#{item.fetch('id')}: #{blockers.join('; ')}" unless blockers.empty?
    if native_lane
      native = item.dig("execution", "native") or raise Error, "This case does not use the shared native comparison"
      recipe = NativeCase.resolve(native, variant)
      NativeCase.verify_report(recipe, payload: File.join(root, "cases", item.fetch("id"), "payload"), lane: native_lane, shared_root: root)
    end
    target = File.expand_path(directory)
    entries = Dir.exist?(target) ? Dir.children(target) : []
    raise Error, "Prepare requires an empty disposable directory or only the .harness checkout" unless (entries - [".harness"]).empty?
    source = item.fetch("source")
    FileUtils.mkdir_p(target)
    if source["revision"] && item["adapter"] == "workflow"
      command("git", "init", target)
      command("git", "remote", "add", "origin", "https://github.com/#{source.fetch('repository')}.git", chdir: target)
      command("git", "fetch", "--depth", "1", "origin", source.fetch("revision"), chdir: target)
      command("git", "checkout", "--detach", "FETCH_HEAD", chdir: target)
      actual = command("git", "rev-parse", "HEAD", chdir: target).strip
      raise Error, "Prepared source #{actual} differs from #{source.fetch('revision')}" unless actual == source.fetch("revision")
      if source["patch"]
        path = File.join(root, "cases", item.fetch("id"), source.fetch("patch"))
        Tempfile.create(["workload-source", ".patch"]) do |patch|
          if path.end_with?(".gz")
            Zlib::GzipReader.open(path) { |input| IO.copy_stream(input, patch) }
          else
            File.open(path, "rb") { |input| IO.copy_stream(input, patch) }
          end
          patch.flush
          command("git", "apply", "--check", patch.path, chdir: target)
          command("git", "apply", patch.path, chdir: target)
        end
      end
    else
      command("git", "init", target)
    end
    case_root = File.join(root, "cases", item.fetch("id"))
    payload = File.join(case_root, "payload")
    if item["adapter"] == "docker"
      recipe = JSON.parse(File.read(File.join(case_root, "recipe.json")))
      recipe_id = recipe.fetch("id")
      FileUtils.cp_r(Dir[File.join(root, "adapters", "docker", "{*,.[!.]*}")], target)
      FileUtils.mkdir_p(File.join(target, "cases"))
      FileUtils.cp(File.join(case_root, "recipe.json"), File.join(target, "cases", "#{recipe_id}.json"))
      FileUtils.mkdir_p(File.join(target, "plans"))
      FileUtils.cp_r(File.join(case_root, "plans"), File.join(target, "plans", recipe_id))
    elsif Dir.exist?(payload)
      FileUtils.cp_r(Dir[File.join(payload, "{*,.[!.]*}")], target)
    end
    FileUtils.mkdir_p(File.join(target, "scripts"))
    FileUtils.cp(File.join(root, "scripts", "canonical", "benchmark-report.rb"), File.join(target, "scripts", "benchmark-report.rb"))
    helpers = HELPERS.dup
    helpers << "verify-upstream-recipe" unless item["adapter"] == "docker"
    helpers.each do |name|
      FileUtils.cp(File.join(root, "scripts", "#{name}.rb"), File.join(target, "scripts", "#{name}.rb"))
    end
    copy_shared_actions(target, root: root)
    unless File.file?(File.join(target, "reapi-recipe.json"))
      %w[reapi-registry reapi-client reapi-setup].each { |name| FileUtils.rm_f(File.join(target, "scripts", "#{name}.rb")) }
    end
    FileUtils.mkdir_p(File.join(target, "config"))
    FileUtils.cp(File.join(root, "config/cli.json"), File.join(target, "config/cli.json"))
    # The workload's submodule commands need an index and a local source tree.
    # This commit stays on the disposable worker and has no publication remote.
    command("git", "add", "--all", "--", ".", ":(exclude).harness", chdir: target)
    source.fetch("pins").select { |pin| pin["kind"] == "gitlink" }.each do |pin|
      command("git", "update-index", "--add", "--cacheinfo", "160000,#{pin.fetch('revision')},#{pin.fetch('path')}", chdir: target)
    end
    command("git", "-c", "user.name=Benchmark runner", "-c", "user.email=benchmark@localhost", "-c", "commit.gpgsign=false",
      "commit", "--allow-empty", "-m", "Prepare #{item.fetch('id')} workload", chdir: target)
    context = {"schema_version" => 1, "case_id" => item.fetch("id"), "workspace" => WORKSPACE,
               "definition_sha256" => definition_sha256(item, root: root),
               "source" => source, "origin" => item.fetch("origin"), "verification" => item.fetch("verification"),
               "comparison" => item.fetch("comparison"), "execution" => item.fetch("execution")}
    write_json(File.join(target, "benchmark-context.json"), context)
    if native_lane
      NativeCase.write_action(item, directory: target, lane: native_lane, suffix: suffix, variant: variant)
    end
    target
  end

  def self.contract_views(root: ROOT)
    Dir.mktmpdir("benchmark-contracts-") do |directory|
      write_contract_views(directory, root: root)
      yield directory
    end
  end

  def self.copy_shared_actions(target, root: ROOT)
    shared_action_files(root: root).each do |source|
      destination = File.join(target, source.delete_prefix("#{root}/"))
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(source, destination)
    end
  end

  def self.shared_action_files(root: ROOT)
    require "find"
    directory = File.join(root, ".github", "actions")
    return [] unless Dir.exist?(directory)
    Find.find(directory).filter_map do |path|
      Find.prune if File.directory?(path) && File.basename(path) == "node_modules"
      path if File.file?(path)
    end
  end

  def self.resolve_provider_steps(document, provider)
    case document
    when Hash
      if document["uses"] == "./.github/actions/boringcache"
        invocation = provider.fetch("runs").fetch("steps").find { |step| step["id"] == "provider" }
        supplied = document.fetch("with", {})
        declared = provider.fetch("inputs")
        unknown = supplied.keys - declared.keys
        raise Error, "Unsupported BoringCache wrapper inputs: #{unknown.join(', ')}" unless unknown.empty?
        resolved = invocation.fetch("with").transform_values do |value|
          if value == "${{ steps.cli.outputs.version }}"
            require_relative "benchmark-cli"
            selected = supplied.fetch("cli-version", "")
            next selected.empty? ? BenchmarkCLI.selection.fetch("version") : selected
          end
          next value if [true, false].include?(value)
          if (match = value.match(/\A\$\{\{ inputs\.([a-z-]+) == 'true' \}\}\z/))
            flag = supplied.fetch(match[1], declared.fetch(match[1]).fetch("default", "")).to_s
            next flag if flag.match?(/\A\$\{\{.+\}\}\z/)
            raise Error, "Use true or false for #{match[1]}" unless %w[true false].include?(flag)
            next flag == "true"
          end
          match = value.match(/\A\$\{\{ inputs\.([a-z-]+) \}\}\z/)
          raise Error, "Provider wrapper must forward declared inputs directly" unless match
          name = match[1]
          supplied.fetch(name, declared.fetch(name).fetch("default", ""))
        end
        document["uses"] = invocation.fetch("uses")
        document["with"] = resolved
      end
      document.each_value { |value| resolve_provider_steps(value, provider) }
    when Array
      document.each { |value| resolve_provider_steps(value, provider) }
    end
    document
  end

  def self.write_contract_views(directory, root: ROOT)
    FileUtils.mkdir_p(directory)
    raise Error, "Contract destination must be empty" unless Dir.children(directory).empty?
    runnable = documents(root).reject { |item| item["kind"] == "retained" || !item.dig("execution", "blockers").to_a.empty? }
    runnable.flat_map do |item|
      variants = item.dig("execution", "native", "variants")&.keys || [nil]
      variants.map { |variant| [item, variant] }
    end.each do |item, native_variant|
        name = "benchmark-#{item.fetch('id')}#{native_variant ? "-#{native_variant}" : ""}"
        target = File.join(directory, name)
        FileUtils.mkdir_p(target)
        payload = File.join(root, "cases", item.fetch("id"), "payload")
        if item["adapter"] == "docker"
          FileUtils.cp_r(Dir[File.join(root, "adapters", "docker", "{*,.[!.]*}")], target)
          recipe = JSON.parse(File.read(File.join(root, "cases", item.fetch("id"), "recipe.json")))
          FileUtils.mkdir_p(File.join(target, "cases"))
          FileUtils.cp(File.join(root, "cases", item.fetch("id"), "recipe.json"), File.join(target, "cases", "#{recipe.fetch('id')}.json"))
          FileUtils.mkdir_p(File.join(target, "plans"))
          FileUtils.cp_r(File.join(root, "cases", item.fetch("id"), "plans"), File.join(target, "plans", recipe.fetch("id")))
        elsif Dir.exist?(payload)
          FileUtils.cp_r(Dir[File.join(payload, "{*,.[!.]*}")], target)
        end
        FileUtils.mkdir_p(File.join(target, ".github", "workflows"))
        item.fetch("execution").fetch("workflows").map { |entry| entry.fetch("path") }.uniq.each do |workflow|
          FileUtils.cp(File.join(root, workflow), File.join(target, ".github", "workflows", File.basename(workflow)))
        end
        FileUtils.mkdir_p(File.join(target, "scripts"))
        write_json(File.join(target, "benchmark-context.json"), {"execution" => item.fetch("execution"), "case_id" => item.fetch("id")})
        FileUtils.cp(File.join(root, "scripts", "canonical", "benchmark-report.rb"), File.join(target, "scripts", "benchmark-report.rb"))
        HELPERS.each do |name|
          FileUtils.cp(File.join(root, "scripts", "#{name}.rb"), File.join(target, "scripts", "#{name}.rb"))
        end
        FileUtils.mkdir_p(File.join(target, "config"))
        FileUtils.cp(File.join(root, "config/cli.json"), File.join(target, "config/cli.json"))
        copy_shared_actions(target, root: root)
        unless File.file?(File.join(target, "reapi-recipe.json"))
          %w[reapi-registry reapi-client reapi-setup].each { |name| FileUtils.rm_f(File.join(target, "scripts", "#{name}.rb")) }
        end
        NativeCase.write_action(item, directory: target, lane: "fresh", variant: native_variant) if item.dig("execution", "native")
        # A copied, unused adapter is not an invocation by this case.
        %w[docker-benchmark nix-benchmark reapi-benchmark].each do |name|
          relative = ".github/actions/#{name}"
          action = File.join(target, relative)
          sources = Dir[File.join(target, ".github", "**", "*.{yml,yaml}")].reject { |path| path.start_with?(action + "/") }
          unless sources.any? { |path| File.read(path).include?("./#{relative}") }
            FileUtils.remove_entry(action)
          end
        end
        # Legacy product guards consume the resolved public Action invocation.
        # Expand the shared wrapper in these disposable views, preserving its
        # defaults and each caller's phase, adapter, and strict failure settings.
        provider_path = File.join(target, ".github", "actions", "boringcache", "action.yml")
        provider = YAML.safe_load(File.read(provider_path), aliases: true)
        raise Error, "The provider wrapper must contain one product call" unless provider.dig("runs", "steps").count { |step| step["uses"].to_s.start_with?("boringcache/one@") } == 1
        Dir[File.join(target, ".github", "**", "*.{yml,yaml}")].each do |path|
          next if path == provider_path
          document = YAML.safe_load(File.read(path), aliases: true)
          if File.basename(path).match?(/\A(?:reapi|nix)-(?:fresh|rolling)-benchmark\.yml\z/)
            inputs = (document["on"] || document[true]).dig("workflow_dispatch", "inputs")
            (document["on"] || document[true]).each_value do |trigger|
              trigger.fetch("inputs").fetch("case_id")["default"] = item.fetch("id") if trigger.is_a?(Hash) && trigger.dig("inputs", "case_id")
            end
            providers = inputs.fetch("provider").fetch("options") - ["all"]
            raise Error, "Provider selector differs from the declared comparison" unless providers.sort == item.dig("comparison", "providers").sort
            document.fetch("jobs").each_value do |job|
              matrix = job.dig("strategy", "matrix")
              matrix["provider"] = providers if matrix && matrix["provider"].is_a?(String)
            end
          end
          if item.dig("execution", "native") && File.basename(path).start_with?("native-")
            recipe = NativeCase.resolve(item.dig("execution", "native"), native_variant)
            document["env"]["BENCHMARK_ID"] = "${{ format('#{recipe.fetch('benchmark_id')}{0}', inputs.benchmark_id_suffix) }}"
            document["env"]["BENCHMARK_VARIANT_SUFFIX"] = native_variant ? "-#{native_variant}" : ""
            (document["on"] || document[true])["workflow_dispatch"]["inputs"]["case_id"]["default"] = item.fetch("id")
            (document["on"] || document[true]).values.each do |trigger|
              trigger["inputs"]["variant"]["default"] = native_variant.to_s if trigger.is_a?(Hash) && trigger.dig("inputs", "variant")
            end
          end
          resolved = resolve_provider_steps(document, provider)
          File.write(path, YAML.dump(resolved))
        end
        FileUtils.remove_entry(File.dirname(provider_path))
      end
    directory
  end
end
