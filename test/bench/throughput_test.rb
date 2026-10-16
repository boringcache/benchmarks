require "minitest/autorun"
require "stringio"
require "tmpdir"
require_relative "../../scripts/throughput"

class ThroughputTest < Minitest::Test
  def setup
    @plan = Throughput.plan
    @throughput = Throughput.new(@plan, run_id: "123")
  end

  def test_every_runner_saves_each_lane_and_payload_in_the_same_job_and_as_a_producer
    %w[same produce].each do |kind|
      jobs = @throughput.jobs(kind)
      assert_equal @plan["runners"].size * @plan["lanes"].size * @plan["payloads"].size, jobs.size
      assert jobs.all? { it["key"] == "throughput-123-#{kind}-#{it["runner"]}-#{it["lane"]}-#{it["payload"]}" }
    end
  end

  def test_consumers_restore_the_producer_key
    produced = @throughput.jobs("produce").to_h { [it["name"], it["key"]] }
    consume = @throughput.jobs("consume")
    assert consume.all? { produced.fetch(it["producer_artifact"].delete_prefix("throughput-")) == it["key"] }
    assert_equal consume.size, consume.map { it["name"] }.uniq.size
    assert consume.any? { it.values_at("producer", "runner", "lane") == %w[github depot-4 boringcache] }
  end

  def test_actions_cache_is_never_restored_across_cache_stores
    pairs = @throughput.jobs("consume").select { it["lane"] == "actions-cache" }.map { it.values_at("producer", "runner") }
    assert_includes pairs, %w[depot-4 depot-4]
    assert_includes pairs, %w[namespace-4 github]
    refute_includes pairs, %w[github depot-4]
    refute_includes pairs, %w[depot-4 github]
  end

  def test_preflight_uses_the_small_payload
    assert_equal @plan["preflight_bytes"], Throughput.new(@plan, run_id: "1", preflight: true).jobs("same").first["bytes"]
    assert_raises(ArgumentError) { Throughput.new(@plan, run_id: "1; rm") }
  end

  def test_record_times_each_operation_between_its_marks
    with_job("same") do |job, dir|
      File.write(File.join(dir, "marks"), "save_start 10.0 eth0=100,1000\nsave_end 30.5 eth0=150,5001000\nrestore_start 31.0 eth0=150,5001000\nrestore_end 43.25 eth0=4000150,5002000\n")
      record = job.record("save" => "success", "lookup" => "success", "restore" => "success", "restore_check" => "success")
      assert_equal({ "seconds" => 20.5, "network_bytes" => 5_000_000, "step_ok" => true, "ok" => true }, record["save"])
      assert_equal({ "seconds" => 12.25, "network_bytes" => 4_000_000, "step_ok" => true, "ok" => true }, record["restore"])
      assert_equal [0, true], record.values_at("exit_status", "output_ok")
    end
  end

  def test_network_bytes_come_from_the_busiest_interface_when_interfaces_count_the_same_traffic
    with_job("same") do |job, dir|
      File.write(File.join(dir, "marks"), "restore_start 1.0 eth0=1000,0 enP1s1=500,0 docker0=0,0\nrestore_end 9.0 eth0=4001000,10 enP1s1=4000500,10 docker0=0,0\n")
      assert_equal 4_000_000, job.record("restore" => "success", "restore_check" => "success").dig("restore", "network_bytes")
    end
  end

  def test_a_save_that_cannot_be_found_afterwards_is_not_ok
    with_job("produce") do |job, dir|
      File.write(File.join(dir, "marks"), "save_start 10.0\nsave_end 12.0\n")
      record = job.record("save" => "success", "lookup" => "failure")
      assert_equal({ "seconds" => 2.0, "step_ok" => true, "ok" => false }, record["save"])
      assert_equal [0, false], record.values_at("exit_status", "output_ok")
    end
  end

  def test_a_failed_restore_is_recorded_as_a_failure
    with_job("consume") do |job, dir|
      File.write(File.join(dir, "marks"), "restore_start 1.0 eth0=0,0\nrestore_end 2.0 eth0=0,0\nsecond_restore_start 3.0 eth0=0,0\nsecond_restore_end 4.0 eth0=0,0\n")
      record = job.record("restore" => "failure", "restore_check" => "failure", "second_restore" => "success", "second_restore_check" => "success")
      assert_equal false, record.dig("restore", "ok")
      assert_equal true, record.dig("second_restore", "ok")
      assert_equal [1, false], record.values_at("exit_status", "output_ok")
    end
  end

  def test_generated_payloads_restore_check_against_their_digest
    %w[random compressible].each do |payload|
      with_job("same", payload:, bytes: 4096) do |job, _dir|
        assert_equal 0, job.generate
        assert_equal 4096, File.size("payload/data.bin")
        assert_equal %w[a b c d], File.binread("payload/data.bin").chars.uniq.sort if payload == "compressible"
        assert_equal 0, job.check
        File.binwrite("payload/data.bin", "x" * 4096)
        assert_equal 1, job.check
        job.clear
        assert_equal 1, job.check
      end
    end
  end

  def test_a_consumer_refuses_a_failed_producer
    with_job("consume") do |job, dir|
      producer = File.join(dir, "producer")
      FileUtils.mkdir_p(producer)
      record = { "name" => "produce-github-boringcache-random", "key" => job.job["key"], "sha256" => "f" * 64, "exit_status" => 0, "output_ok" => false }
      File.write(File.join(producer, "produce-github-boringcache-random.json"), JSON.generate(record))
      assert_raises(RuntimeError) { job.producer(producer) }
      File.write(File.join(producer, "produce-github-boringcache-random.json"), JSON.generate(record.merge("output_ok" => true)))
      assert_equal 0, job.producer(producer)
      assert_equal "f" * 64, File.read(File.join(dir, "sha256"))
    end
  end

  def test_report_takes_medians_and_spread_of_passing_jobs
    Dir.mktmpdir("throughput-report") do |dir|
      [10.0, 20.0, 30.0, 40.0, 1.0].each_with_index do |seconds, index|
        ok = index < 4
        record = { "kind" => "same", "lane" => "boringcache", "payload" => "random", "producer_machine" => "github 4c", "machine" => "github 4c",
                   "versions" => { "boringcache" => "1.42.0" }, "auth_seconds" => 1.0, "exit_status" => ok ? 0 : 1, "output_ok" => ok,
                   "save" => { "seconds" => seconds, "network_bytes" => 4_300_000_000, "ok" => ok },
                   "restore" => { "seconds" => seconds / 2, "network_bytes" => 4_300_000_000, "ok" => ok } }
        File.write(File.join(dir, "#{index}.json"), JSON.generate(record))
      end
      report = ThroughputReport.new(dir, @plan)
      row = report.rows("same").first
      assert_equal [5, 1], row.values_at("samples", "failed")
      assert_equal({ "median" => 25.0, "p10" => 13.0, "p90" => 37.0, "network_bytes" => 4_300_000_000 }, row["save"])
      assert_includes report.markdown, "| boringcache | random | github 4c | 1.42.0 | 5 | 1 | 25.0 | 13.0–37.0 | 4300 | 12.5 | 6.5–18.5 | 4300 | 1.0 |"
      refute_includes report.markdown, "actions-cache"
    end
  end

  def test_cleanup_deletes_github_entries_under_the_prefix
    calls = []
    out = StringIO.new
    cleanup = ThroughputCleanup.new(prefix: "throughput-123-", env: { "GITHUB_REPOSITORY" => "boringcache/benchmarks" }, out:)
    cleanup.define_singleton_method(:capture) { |*args| calls << args; args.include?("--paginate") ? "11\n12\n" : "" }
    assert_equal 0, cleanup.call
    assert_equal %w[repos/boringcache/benchmarks/actions/caches/11 repos/boringcache/benchmarks/actions/caches/12], calls.drop(1).map(&:last)
    assert_match "Deleted 2 GitHub Actions cache entries", out.string
    assert_equal "repos/boringcache/benchmarks/actions/caches?per_page=100&key=throughput-123-", calls.first[3]
    assert_raises(ArgumentError) { ThroughputCleanup.new(prefix: "chroma-") }
  end

  private
    def with_job(kind, payload: "random", bytes: 1024)
      job = Throughput.new(@plan, run_id: "123", bytes:).jobs(kind).find { it["lane"] == "boringcache" && it["payload"] == payload }
      Dir.mktmpdir("throughput") do |dir|
        Dir.chdir(dir) { yield ThroughputJob.new(job, dir:, env: {}), dir }
      end
    end
end
