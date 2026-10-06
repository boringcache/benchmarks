# frozen_string_literal: true

require_relative "benchmark-cases"

module BenchmarkIdentity
  def self.verify(item, expected, root: BenchmarkCases::ROOT)
    return if expected.to_s.empty?

    identity = JSON.parse(expected)
    unless identity.is_a?(Hash) && %w[harness_sha case_id definition_sha256].all? { |key| identity[key].is_a?(String) }
      raise BenchmarkCases::Error, "Expected a scheduled harness and case identity object"
    end
    actual = BenchmarkCases.command("git", "rev-parse", "HEAD", chdir: root).strip
    unless identity.fetch("harness_sha").match?(/\A[0-9a-f]{40}\z/) && actual == identity.fetch("harness_sha")
      raise BenchmarkCases::Error, "Harness commit differs from the scheduled plan; no workload prepared"
    end
    unless identity.fetch("case_id") == item.fetch("id") && identity.fetch("definition_sha256") == BenchmarkCases.definition_sha256(item, root: root)
      raise BenchmarkCases::Error, "Case definition differs from the scheduled plan; no workload prepared"
    end
    identity
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    BenchmarkIdentity.verify(BenchmarkCases.load_case(ENV.fetch("BENCHMARK_CASE_ID")), ENV.fetch("BENCHMARK_EXPECTED_IDENTITY", ""))
  rescue BenchmarkCases::Error, KeyError, JSON::ParserError => error
    abort error.message
  end
end
