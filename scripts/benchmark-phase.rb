# frozen_string_literal: true

require_relative "benchmark-plan"

module BenchmarkPhase
  def self.scope(env, require_published: false)
    id = env.fetch("BENCHMARK_ID")
    lane = env.fetch("CACHE_LANE")
    raise "Use fresh or rolling" unless %w[fresh rolling].include?(lane)
    raise "Invalid benchmark ID" unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    series = env.fetch("BENCHMARK_SERIES_ID", "")
    if !series.empty?
      raise "Invalid series ID" unless series.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
      sample = env.fetch("BENCHMARK_SAMPLE")
      raise "Invalid sample number" unless sample.match?(/\A[1-9][0-9]*\z/)
      return "#{id}-series-#{series}" if lane == "rolling"
      "#{id}-series-#{series}-s#{sample}-#{run_identity(env)}"
    elsif require_published && env["PHASE"] == "warm"
      scope = env.fetch("PUBLISHED_SCOPE", "")
      raise "Legacy warm phase requires its published cache scope" unless scope.match?(/\A[a-z0-9][a-z0-9._-]+\z/)
      scope
    elsif lane == "rolling"
      ref = env.fetch("GITHUB_REF_NAME").gsub(/[^A-Za-z0-9._-]/, "-").sub(/\A-/, "").sub(/-\z/, "")
      "#{id}-rolling-#{ref.empty? ? 'main' : ref}"
    else
      "#{id}-run-#{run_identity(env)}"
    end
  end

  def self.run_identity(env)
    run, attempt = env.values_at("GITHUB_RUN_ID", "GITHUB_RUN_ATTEMPT")
    raise "Run and attempt must be positive integers" unless [run, attempt].all? { |value| value&.match?(/\A[1-9][0-9]*\z/) }
    "r#{run}-a#{attempt}"
  end

  def self.policy(phase, publish_on_warm)
    raise "Phase must be publish or warm" unless %w[publish warm].include?(phase)
    raise "publish-on-warm must be true or false" unless %w[true false].include?(publish_on_warm)
    publish = phase == "publish" || publish_on_warm == "true"
    {"publish_cache" => publish, "require_hit" => phase == "warm"}
  end
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "scope"
    puts BenchmarkPhase.scope(ENV, require_published: ARGV.delete("--require-published") == "--require-published")
  when "policy"
    BenchmarkPhase.policy(ENV.fetch("PHASE"), ENV.fetch("PUBLISH_ON_WARM", "false")).each do |name, value|
      BenchmarkPlan.write_output(name, value)
    end
  else
    abort "Use benchmark-phase.rb scope or policy"
  end
end
