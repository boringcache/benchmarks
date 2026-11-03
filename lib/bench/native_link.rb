module Bench
  module NativeLink
    def self.prefix(env)
      base = "nativelink/#{env.fetch("BENCH_CASE")}"
      env.fetch("BENCH_PHASE") == "rolling" ? base : "#{base}/runs/#{env.fetch("BENCH_RUN_ID")}"
    end
  end
end
