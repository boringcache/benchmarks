require_relative 'benchmark-evidence'
require_relative 'collect-series'
$stdout.sync = true
id = Integer(ENV.fetch('EVIDENCE_RUN_ID'))
allowed = {
  37320869828 => ['cadence-fresh-01', 1],
  37327069343 => ['cadence-fresh-01', 2],
  37322636399 => ['cadence-rolling-seed', 1],
  37323174641 => ['cadence-rolling-advance', 1]
}
series, sample = allowed.fetch(id)
raise 'Unexpected series or sample' unless [ENV.fetch('EVIDENCE_SERIES'), Integer(ENV.fetch('EVIDENCE_SAMPLE'))] == [series, sample]
github = BenchmarkEvidence::GitHub.new
deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 4 * 60 * 60
loop do
  run = github.api("repos/boringcache/benchmarks/actions/runs/#{id}")
  break if run.fetch('status') == 'completed'
  raise 'Qualification run has not completed within four hours' if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
  puts "Run #{id}: #{run.fetch('status')}"
  sleep 60
end
directory = "/tmp/cadence-evidence-#{id}"
BenchmarkEvidence.export(repository: 'boringcache/benchmarks', run_id: id, directory: directory, github: github)
raise 'Incomplete run export' unless BenchmarkEvidence.verify(directory).fetch('state') == 'complete'
puts JSON.generate(CollectSeries.call("results/zed-nix/#{series}", evidence_directory: directory, sample: sample))
ARGV.replace([id.to_s])
load File.join(__dir__, 'archive-cadence-evidence.rb')
