require "json"

path = "upstream/nx.json"
config = JSON.parse(File.read(path))
original = JSON.generate(config)
%w[nxCloudId nxCloudAccessToken nxCloudUrl codexCacheBust].each { |key| config.delete(key) }
config.fetch("tasksRunnerOptions", {}).each_value do |runner|
  runner.delete("runner") if %w[nx-cloud @nrwl/nx-cloud].include?(runner["runner"])
  %w[accessToken nxCloudId nxCloudUrl].each { |key| runner.fetch("options", {}).delete(key) }
end
globals = (config["namedInputs"] ||= {})["sharedGlobals"] ||= []
globals << { "env" => "BENCH_NX_CACHE_KEYSPACE" } unless globals.include?({ "env" => "BENCH_NX_CACHE_KEYSPACE" })
File.write(path, JSON.pretty_generate(config) + "\n") unless JSON.generate(config) == original
