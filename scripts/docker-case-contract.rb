# frozen_string_literal: true

require_relative "benchmark-plan"

module DockerCaseContract
  FIDELITY = %w[direct-step matrix-member wrapper-projection diagnostic-tool-cache diagnostic-overlay].freeze

  def self.command(item, ref, prefix)
    docker = item.fetch("docker")
    source = "#{prefix}.work/#{item.fetch('id')}/source"
    args = ["docker", "buildx", "build", "--file", "#{source}/#{docker.fetch('dockerfile')}"]
    args += ["--platform", docker["platform"]] if docker["platform"]
    args += ["--target", docker["target"]] if docker["target"]
    docker.fetch("build_args", []).each { |arg| args += ["--build-arg", arg.gsub("{PROJECT_REF}", item.fetch("refs").fetch(ref))] }
    args += docker.fetch("extra_args", [])
    args << "--push" if docker["output"] == "ghcr"
    args << "--load" if docker["output"] == "load"
    image = docker["output"] == "ghcr" ? "ghcr.io/boringcache/#{docker.fetch('image')}-proof" : "cache-proof/#{docker.fetch('image')}"
    args + ["--tag", "#{image}:#{ref}", "#{source}/#{docker.fetch('context', '.')}" ]
  end

  def self.validate(item, plans)
    id = item.fetch("id")
    raise "#{id}: missing upstream workflow anchor" unless item.dig("source", "workflow").to_s.start_with?(".github/workflows/")
    raise "#{id}: missing fidelity classification" unless FIDELITY.include?(item.dig("fidelity", "level"))
    raise "#{id}: missing upstream evidence" unless item.dig("source", "evidence_run") || item.dig("source", "pain_url")
    raise "#{id}: unsupported build family" unless item.fetch("docker").fetch("build_family", "buildx-build") == "buildx-build"
    raise "#{id}: invalid output contract" unless %w[none load ghcr].include?(item.dig("docker", "output"))
    entries = [["main", File.join(plans, ".boringcache.toml"), "../../"]]
    entries += item.fetch("refs").map { |ref, _| [ref, File.join(plans, "refs", ref, ".boringcache.toml"), "../../../../"] }
    entries.each do |ref, path, prefix|
      raise "#{id}/#{ref}: source revision must be pinned" unless item.fetch("refs").fetch(ref).match?(/\A[0-9a-f]{40}\z/)
      plan = BenchmarkPlan.load(path)
      raise "#{id}/#{ref}: incorrect workspace" unless plan["workspace"] == "boringcache/benchmarks"
      docker = plan.fetch("adapters").fetch("docker")
      raise "#{id}/#{ref}: Docker command differs from its recipe" unless docker["command"] == command(item, ref, prefix)
      raise "#{id}/#{ref}: case cache identity differs" unless docker["tag"] == "docker-cache-proof-#{id}"
      raise "#{id}/#{ref}: explicit cohort requires no-git and no-platform" unless docker["no-git"] && docker["no-platform"]
    end
  end
end
