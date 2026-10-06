# frozen_string_literal: true

module BenchmarkScaffold
  def self.go(item, directory:, tool_version:)
    id = item.fetch("id")
    source = item.fetch("source")
    revision = source.fetch("revision")
    item["source"] = {"repository" => source.fetch("repository"), "pins" => [{"path" => "upstream", "kind" => "gitlink", "revision" => revision}]}
    item["execution"] = {"sync" => "fixed",
      "workflows" => %w[fresh rolling].map { |lane| {"path" => ".github/workflows/native-#{lane}-benchmark.yml", "lane" => lane, "inputs" => {"case_id" => id}} },
      "native" => {"action" => ".github/actions/go-benchmark", "benchmark_id" => id,
        "fresh_inputs" => {"go_version" => tool_version}, "rolling_inputs" => {"go_version" => tool_version}},
      "cache_tags" => {"#{id}-local" => "{scope}"},
      "blockers" => ["Review the upstream command and recipe digests, implement scripts/verify-output.rb, then remove this blocker after preparation and output verification"]}
    item["comparison"].merge!("providers" => %w[boringcache actions-cache], "primary_metric" => "build_and_reuse_seconds",
      "timed_scope" => "Declared Go build plus measured cache restore/setup; dependency installation in the command is included; verification and unmeasured post-job save are excluded",
      "storage" => "provider-reported")
    item["verification"] = ["Reviewed upstream recipe and command", "Case-owned output check completes successfully"]
    payload = File.join(directory, "payload")
    FileUtils.mkdir_p(File.join(payload, "scripts"))
    File.write(File.join(payload, ".gitmodules"), "[submodule \"upstream\"]\n\tpath = upstream\n\turl = https://github.com/#{source.fetch('repository')}.git\n\tshallow = true\n")
    command = ["go", "build", "./..."]
    File.write(File.join(payload, ".boringcache.toml"), <<~TOML)
      workspace = "boringcache/benchmarks"

      [adapters.go]
      tag = "#{id}-local"
      no-platform = true
      no-git = true
      command = #{JSON.generate(command)}
    TOML
    BenchmarkCases.write_json(File.join(payload, "recipe-contract.json"), {
      "schema_version" => 1, "upstream_files" => {"go.mod" => "0" * 64}, "commands" => {"go" => command}})
    File.write(File.join(payload, "scripts/verify-output.rb"), <<~RUBY)
      # frozen_string_literal: true

      abort "Implement and review this workload's output check before execution"
    RUBY
    item
  end
end
