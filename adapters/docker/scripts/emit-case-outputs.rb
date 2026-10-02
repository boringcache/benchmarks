#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
case_id, ref = ARGV
raise "Use CASE_ID REF_KEY" unless case_id && ref
root = BenchmarkPlan::ROOT
item = JSON.parse(File.read(File.join(root, "cases", "#{case_id}.json")))
raise "Case ID mismatch" unless item.fetch("id") == case_id
sha = item.fetch("refs").fetch(ref)
directory = "plans/#{case_id}/refs/#{ref}"
command = BenchmarkPlan.command("docker", File.join(root, directory, ".boringcache.toml"))
raise "Selected plan must use Docker Buildx" unless command.first(3) == %w[docker buildx build]
after = ->(flag) { index = command.index(flag); index ? command.fetch(index + 1) : "" }
output = command.include?("--push") ? "ghcr" : command.include?("--load") ? "load" : "none"
docker = item.fetch("docker")
raise "Output differs from the case contract" unless output == docker.fetch("output")
image_repository = output == "ghcr" ? "ghcr.io/#{ENV.fetch('GITHUB_REPOSITORY_OWNER')}/#{docker.fetch('image')}-proof" : "cache-proof/#{docker.fetch('image')}"
workflow = item.fetch("workflow", {})
matrix = workflow.fetch("native_matrix", {"include" => []})
values = {"case_id" => case_id, "case_ref_key" => ref, "plan_directory" => directory,
  "benchmark_id" => "#{case_id}-#{ref.match?(/\A[0-9a-f]{40}\z/) ? ref[0,12] : ref}", "cache_id" => docker.fetch("cache_id", case_id),
  "fidelity_level" => item.fetch("fidelity").fetch("level"), "project_repo" => item.fetch("source").fetch("repo"), "project_ref" => sha,
  "dockerfile_path" => after.call("--file"), "docker_context" => command.last, "image_repository" => image_repository,
  "image_tag" => "#{after.call('--tag').split(':').last}-#{ENV.fetch('GITHUB_RUN_ID','local')}", "build_output" => output,
  "target" => after.call("--target"), "platforms" => after.call("--platform"),
  "build_args" => command.each_index.filter_map { |i| command[i + 1] if command[i] == "--build-arg" }.join("\n"),
  "docker_tool_cache" => docker.fetch("tool_cache", ""), "sbom" => command.include?("--sbom=true"),
  "provenance" => command.any? { |value| value.start_with?("--provenance=") && value != "--provenance=false" },
  "cli_version" => "", "runner_label" => workflow.fetch("runner_label", "ubuntu-latest"), "cli_platform" => workflow.fetch("cli_platform", "linux-amd64"),
  "free_disk_space" => workflow.fetch("free_disk_space", false), "setup_qemu" => workflow.fetch("setup_qemu", false),
  "rust_target_cache_kind" => docker.dig("rust_target_cache", "kind").to_s,
  "rust_target_cache_id_pattern" => docker.dig("rust_target_cache", "id_pattern").to_s,
  "native_matrix" => JSON.generate(matrix), "native_matrix_enabled" => !matrix.fetch("include").empty?}
values.each { |name, value| BenchmarkPlan.write_output(name, value) }
