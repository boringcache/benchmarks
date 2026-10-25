module Bench
  class Report
    KEY = %w[adapter_command case lane level runner phase step sha boringcache attempt cache_seeded cache_save_timing machine cpu cores].freeze
    COLUMNS = %w[Tool Case Lane Level Runner Phase Step Commit CLI Attempt From\ fresh\ run Save Machine CPU Cores Samples Failed Seed\ failed Save\ failed Timed\ median\ s Timed\ min\ s Timed\ max\ s Cache\ API\ errors].freeze
    MATCHED = %w[adapter_command case runner series boringcache steps first_step last_step lane level machine median_seconds min_seconds max_seconds cache_api_error_steps].freeze
    MATCHED_COLUMNS = %w[Tool Case Runner Series CLI Steps First\ step Last\ step Lane Level Machine Timed\ median\ s Timed\ min\ s Timed\ max\ s Steps\ with\ cache\ API\ errors].freeze
    READ_ONLY = %w[adapter_command case lane level machine reads boringcache steps first_step last_step median_seconds source_median_seconds cache_api_error_steps].freeze
    READ_ONLY_COLUMNS = %w[Tool Case Lane Level Machine Reads CLI Steps First\ step Last\ step Timed\ median\ s Source\ timed\ median\ s Steps\ with\ cache\ API\ errors].freeze

    def initialize(results_dir, runs: nil, nightly: [], sample_runs: [])
      @results_dir = results_dir
      @runs = runs
      @nightly = nightly
      @sample_runs = sample_runs
    end

    def records
      @records ||= source_records.reject { it["excluded"] }
    end

    def rows
      records.reject { it["phase"] == "sample" }.group_by { key(it) }.map { |key, group| row(key, group) }.sort_by { it.values_at(*KEY).map(&:to_s) }
    end

    def write(out_dir)
      FileUtils.mkdir_p(out_dir)
      File.write(File.join(out_dir, "results.json"), JSON.pretty_generate("rows" => rows, "matched" => matched, "read_only" => read_only, "samples" => samples, "latest" => latest) + "\n")
      File.write(File.join(out_dir, "report.md"), markdown)
    end

    def matched
      @matched ||= matched_steps.flat_map do |(tool, kase, runner, series, cli, _lanes), steps|
        steps.values.flat_map(&:values).group_by { it["lane"] }.map do |lane, group|
          seconds = group.filter_map { timed_seconds(it) }.sort
          { "adapter_command" => tool, "case" => kase, "runner" => runner, "series" => series, "boringcache" => cli, "steps" => steps.size,
            "first_step" => steps.keys.min, "last_step" => steps.keys.max, "lane" => lane, "level" => group.first["level"], "machine" => group.first["machine"],
            "median_seconds" => median(seconds), "min_seconds" => seconds.first, "max_seconds" => seconds.last,
            "cache_api_error_steps" => group.count { cache_api_errors(it).to_i.positive? } }
        end
      end.sort_by { it.values_at(*MATCHED.first(5), "lane").map(&:to_s) }
    end

    def read_only
      @read_only ||= records.select { it["read_only"] && it["phase"] == ROLLING && passed?(it) }
        .group_by { it.values_at("adapter_command", "case", "lane", "runner", "step") }.values.map { |tries| tries.min_by { it["attempt"].to_i } }
        .filter_map { |reader| (source = sources[reader.values_at("adapter_command", "case", "cache_scope", "step", "sha")]) && before_save?(reader, source) && [reader, source] }
        .group_by { |reader, _| [*reader.values_at("adapter_command", "case", "lane", "level", "machine", "cache_scope"), cli(reader)] }
        .map do |(tool, kase, lane, level, machine, reads, version), pairs|
          steps = pairs.map { |reader, _| reader["step"] }
          { "adapter_command" => tool, "case" => kase, "lane" => lane, "level" => level, "machine" => machine, "reads" => reads, "boringcache" => version,
            "steps" => pairs.size, "first_step" => steps.min, "last_step" => steps.max,
            "median_seconds" => median(pairs.filter_map { timed_seconds(it[0]) }.sort), "source_median_seconds" => median(pairs.filter_map { timed_seconds(it[1]) }.sort),
            "cache_api_error_steps" => pairs.count { cache_api_errors(it[0]).to_i.positive? } }
        end.sort_by { it.values_at(*READ_ONLY.first(7)).map(&:to_s) }
    end

    def markdown
      table = rows.map do |row|
        row.merge("sha" => row["sha"]&.slice(0, 12)).values_at(*KEY).map { it.nil? ? "-" : it } +
          row.values_at("samples", "failed", "seed_failed", "save_failed", "median_seconds", "min_seconds", "max_seconds").map { it.nil? ? "unmeasured" : it } +
          [row["cache_api_errors"] || "-"]
      end
      matched_table = matched.map { |row| row.values_at(*MATCHED).map { it.nil? ? "-" : it } }
      read_only_table = read_only.map { |row| row.values_at(*READ_ONLY).map { it.nil? ? "-" : it } }
      latest_columns = %w[Tool Case Lane Runner Step Commit CLI Started Attempt Status Seconds Run]
      latest_rows = latest.map { it.values_at("adapter_command", "case", "lane", "runner", "step", "sha", "boringcache", "started_at", "attempt", "status", "seconds", "run_url").map { |value| value.nil? ? "unmeasured" : value } }
      ["# Benchmark results", "", "## Latest recorded rolling attempts", "",
       "`save failed`: the build passed but its cache save failed. `stale restore`: the step restored an older step's cache than the lane's previous step. `seed failed`: the step restored nothing from its rolling cache.", "",
       line(latest_columns), line(latest_columns.map { "---" }), *latest_rows.map { line(it) }, "",
       "## Measurements", "", line(COLUMNS), line(COLUMNS.map { "---" }), *table.map { line(it) }, "",
       "## Matched rolling steps", "",
       "Rolling steps at which every lane on the runner passed, each on its own rolling cache after that cache's first step. Steps continued from a fresh run's cache, steps that restored nothing or an older step's cache than the lane's previous step, and steps whose cache save failed are left out. Times include post-job saves.", "",
       line(MATCHED_COLUMNS), line(MATCHED_COLUMNS.map { "---" }), *matched_table.map { line(it) }, "",
       "## Historical shared-cache builds", "",
       "Historical builds using another runner's cache, paired with that runner's passing build at the same commit. These timings exclude cache saves.", "",
       line(READ_ONLY_COLUMNS), line(READ_ONLY_COLUMNS.map { "---" }), *read_only_table.map { line(it) }, "",
       "## Runner samples", "", sample_table, ""].join("\n")
    end

    def latest
      source_records.select { it["phase"] == ROLLING && !it["read_only"] }
        .group_by { it.values_at("adapter_command", "case", "lane", "runner") }.values.map do |group|
          record = group.max_by { [it["started_at"].to_s, it["step"].to_i, it["attempt"].to_i] }
          status = if record["excluded"]
            "excluded"
          elsif !built?(record)
            "failed"
          elsif save_failed?(record)
            "save failed"
          elsif save_timing(record) == "post-job" || !timed_seconds(record)
            "unmeasured"
          elsif stale?(record)
            "stale restore"
          elsif !seeded?(record)
            "seed failed"
          else
            "passed"
          end
          record.slice("adapter_command", "case", "lane", "runner", "step", "sha", "started_at", "attempt", "run_url", "excluded").merge(
            "boringcache" => cli(record), "status" => status, "seconds" => (timed_seconds(record) if status == "passed"))
        end.sort_by { it.values_at("adapter_command", "case", "lane", "runner") }
    end

    def samples
      records.select { it["phase"] == "sample" }.map do |record|
        record.slice("adapter_command", "case", "lane", "level", "runner", "machine", "sha", "step", "run_url", "started_at", "cache_source", "exit_status", "output_ok", "job_conclusion").merge(
          "boringcache" => cli(record), "cpu" => record.dig("observed", "machine", "cpu"), "cores" => record.dig("observed", "machine", "cores"),
          "cache" => record["read_only"] ? "GitHub build" : record["provider"], "operations" => record["read_only"] ? "restore, build" : "restore, build, save",
          "seconds" => (timed_seconds(record) if passed?(record) && save_timing(record) != "post-job"))
      end.sort_by { it.values_at("adapter_command", "case", "run_url", "lane", "runner").map(&:to_s) }
    end

    private
      def source_records
        @source_records ||= Dir.glob(File.join(@results_dir, "**", "*.json")).sort.map { JSON.parse(File.read(it)) }
          .reject { it["experimental"] }
          .select { @runs.nil? || @runs.include?("#{it["adapter_command"]}/#{it["case"]} #{it["lane"]} #{it["runner"]}") || ((it["phase"] == "sample" || it["read_only"]) && @sample_runs.include?("#{it["adapter_command"]}/#{it["case"]} #{it["lane"]} #{it["runner"]}")) }
      end

      def sample_table
        columns = %w[Tool Case Run Commit Lane Level Machine CPU Cores Cache Operations CLI Seconds Exit Output Job]
        body = samples.map do |sample|
          [sample["adapter_command"], sample["case"], sample["run_url"], sample["sha"]&.slice(0, 12), sample["lane"].delete_suffix("-reader"), *sample.values_at("level", "machine", "cpu", "cores", "cache", "operations", "boringcache", "seconds", "exit_status", "output_ok", "job_conclusion")]
            .map { it.nil? ? "unmeasured" : it }
        end
        [line(columns), line(columns.map { "---" }), *body.map { line(it) }].join("\n")
      end

      def key(record)
        [*record.values_at(*%w[adapter_command case lane level runner phase step sha]), cli(record),
         [record["attempt"].to_i, 1].max, record["cache_seeded"], save_timing(record), record["machine"],
         record.dig("observed", "machine", "cpu"), record.dig("observed", "machine", "cores")]
      end

      def cli(record)
        version = record.dig("versions", "boringcache_release") || record.dig("versions", "boringcache")
        settings = record.fetch("product_env", {}).merge(record.fetch("plan_settings", {}))
        [version, *settings.map { |key, value| "#{key}=#{value}" }, *record.fetch("product_args", [])].compact.join(" ") if version
      end

      def save_timing(record)
        record.key?("post_job_save_seconds") ? "post-job, timed" : record["cache_save_timing"]
      end

      def timed_seconds(record)
        record["seconds"] && (record["seconds"] + record["post_job_save_seconds"].to_f).round(3)
      end

      def row(key, group)
        seconds = group.select { passed?(it) && seeded?(it) }.filter_map { timed_seconds(it) }.sort
        KEY.zip(key).to_h.merge(
          "samples" => group.size,
          "failed" => group.count { !passed?(it) },
          "seed_failed" => group.count { passed?(it) && !seeded?(it) },
          "save_failed" => group.count { save_failed?(it) },
          "median_seconds" => median(seconds),
          "min_seconds" => seconds.first,
          "max_seconds" => seconds.last,
          "cache_api_errors" => group.filter_map { cache_api_errors(it) }.then { it.empty? ? nil : it.sum },
          "run_urls" => group.filter_map { it["run_url"] }.uniq
        )
      end

      def cache_api_errors(record)
        record.dig("provider_reported", "cache_session_summary", "backend_api", "total_error_count")
      end

      def matched_steps
        records.select { it["phase"] == ROLLING && it["cache_scope"] == it["scope"] }.group_by { [*it.values_at("adapter_command", "case"), it["cadence"] || it["runner"], series(it)] }.flat_map do |(tool, kase, runner, series), group|
          joined = group.group_by { it["lane"] }.transform_values { |records| records.map { it["step"] }.min }
          next [] if joined.size < 2

          group.group_by { it["step"] }.filter_map do |step, at_step|
            lanes = joined.select { |lane, first| first < step && (at_step.any? { it["lane"] == lane } || !@nightly.include?("#{tool}/#{kase} #{lane} #{runner}")) }.keys.sort
            by_lane = at_step.select { matchable?(it) }.group_by { it["lane"] }.transform_values { |tries| tries.min_by { it["attempt"].to_i } }.slice(*lanes)
            next unless lanes.size >= 2 && lanes.all? { by_lane.key?(it) }
            next unless by_lane.values.map { it["sha"] }.uniq.size == 1

            cli = by_lane.values.filter_map { cli(it) }.uniq.sort.join(", ")
            [[tool, kase, runner, series, (cli unless cli.empty?), lanes], step, by_lane]
          end
        end.group_by(&:first).transform_values { it.to_h { |_, step, by_lane| [step, by_lane] } }
      end

      def before_save?(reader, source)
        reader["started_at"] && source["started_at"] && Time.iso8601(reader["started_at"]) < Time.iso8601(source["started_at"]) + timed_seconds(source)
      end

      def sources
        @sources ||= records.select { matchable?(it) }.group_by { it.values_at("adapter_command", "case", "scope", "step", "sha") }
          .transform_values { |tries| tries.min_by { it["attempt"].to_i } }
      end

      def matchable?(record)
        record["phase"] == ROLLING && record["cache_scope"] == record["scope"] && passed?(record) && seeded?(record) && save_timing(record) != "post-job" &&
          record["step"] > first_steps.fetch(record.values_at("adapter_command", "case", "cache_scope"))
      end

      def first_steps
        @first_steps ||= records.select { it["phase"] == ROLLING && it["step"] }.group_by { it.values_at("adapter_command", "case", "cache_scope") }
          .transform_values { |group| group.map { it["step"] }.min }
      end

      def series(record)
        record["scope"].delete_prefix("#{record["lane"]}-#{record["runner"]}-")
      end

      def passed?(record)
        built?(record) && !save_failed?(record)
      end

      def built?(record)
        record["exit_status"] == 0 && record["output_ok"] == true && record.fetch("job_conclusion", "success") == "success"
      end

      def save_failed?(record)
        record["cache_save"] == "failed"
      end

      def stale?(record)
        return false unless record["phase"] == ROLLING && record["cache_scope"] == record["scope"]

        restored = record["cache_restored_key"].to_s[/\A#{Regexp.escape("#{record["adapter_command"]}-#{record["case"]}-#{record["cache_scope"]}-")}(\d+)\z/, 1] or return false
        previous = scope_steps.fetch(record.values_at("adapter_command", "case", "cache_scope"), []).select { it < record["step"] }.max
        !previous.nil? && restored.to_i < previous
      end

      def scope_steps
        @scope_steps ||= source_records.select { it["phase"] == ROLLING && it["step"] }.group_by { it.values_at("adapter_command", "case", "scope") }
          .transform_values { |group| group.map { it["step"] }.uniq }
      end

      def seeded?(record)
        return seeds.fetch(record.values_at("adapter_command", "case", "scope"), false) if record["phase"] == "warm"
        return false if stale?(record)
        return true unless record["phase"] == ROLLING && record.key?("cache_restored_key") && record["cache_restored_key"].nil?

        scopes = record["cache_restore_tracked"] ? first_steps : restoring_scopes
        first_step = scopes[record.values_at("adapter_command", "case", "cache_scope")]
        first_step.nil? || record["step"] == first_step
      end

      def seeds
        @seeds ||= records.select { it["phase"] == "cold" }.to_h { [it.values_at("adapter_command", "case", "scope"), passed?(it)] }
      end

      def restoring_scopes
        @restoring_scopes ||= records.select { it["phase"] == ROLLING }.group_by { it.values_at("adapter_command", "case", "cache_scope") }
          .select { |_, group| group.any? { it["cache_restored_key"] } }.transform_values { |group| group.filter_map { it["step"] }.min }
      end

      def median(values)
        return if values.empty?

        middle = values.size / 2
        values.size.odd? ? values[middle] : ((values[middle - 1] + values[middle]) / 2.0).round(3)
      end

      def line(cells)
        "| #{cells.join(" | ")} |"
      end
  end
end
