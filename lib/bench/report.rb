module Bench
  class Report
    KEY = %w[adapter_command case lane level runner phase step sha boringcache attempt cache_seeded cache_save_timing machine cpu cores].freeze
    COLUMNS = %w[Tool Case Lane Level Runner Phase Step Commit CLI Attempt From\ fresh\ run Save Machine CPU Cores Samples Failed Seed\ failed Timed\ median\ s Timed\ min\ s Timed\ max\ s Cache\ API\ errors].freeze
    MATCHED = %w[adapter_command case runner series boringcache steps first_step last_step lane level machine median_seconds min_seconds max_seconds cache_api_error_steps].freeze
    MATCHED_COLUMNS = %w[Tool Case Runner Series CLI Steps First\ step Last\ step Lane Level Machine Timed\ median\ s Timed\ min\ s Timed\ max\ s Steps\ with\ cache\ API\ errors].freeze

    def initialize(results_dir, runs: nil)
      @results_dir = results_dir
      @runs = runs
    end

    def records
      @records ||= Dir.glob(File.join(@results_dir, "**", "*.json")).sort.map { JSON.parse(File.read(it)) }
        .select { @runs.nil? || @runs.include?("#{it["adapter_command"]}/#{it["case"]} #{it["lane"]} #{it["runner"]}") }
    end

    def rows
      records.group_by { key(it) }.map { |key, group| row(key, group) }.sort_by { it.values_at(*KEY).map(&:to_s) }
    end

    def write(out_dir)
      FileUtils.mkdir_p(out_dir)
      File.write(File.join(out_dir, "results.json"), JSON.pretty_generate("rows" => rows, "matched" => matched) + "\n")
      File.write(File.join(out_dir, "report.md"), markdown)
    end

    def matched
      @matched ||= matched_steps.flat_map do |(tool, kase, runner, series, cli), steps|
        steps.values.flat_map(&:values).group_by { it["lane"] }.map do |lane, group|
          seconds = group.filter_map { timed_seconds(it) }.sort
          { "adapter_command" => tool, "case" => kase, "runner" => runner, "series" => series, "boringcache" => cli, "steps" => steps.size,
            "first_step" => steps.keys.min, "last_step" => steps.keys.max, "lane" => lane, "level" => group.first["level"], "machine" => group.first["machine"],
            "median_seconds" => median(seconds), "min_seconds" => seconds.first, "max_seconds" => seconds.last,
            "cache_api_error_steps" => group.count { cache_api_errors(it).to_i.positive? } }
        end
      end.sort_by { it.values_at(*MATCHED.first(5), "lane").map(&:to_s) }
    end

    def markdown
      table = rows.map do |row|
        row.merge("sha" => row["sha"]&.slice(0, 12)).values_at(*KEY).map { it.nil? ? "-" : it } +
          row.values_at("samples", "failed", "seed_failed", "median_seconds", "min_seconds", "max_seconds").map { it.nil? ? "unmeasured" : it } +
          [row["cache_api_errors"] || "-"]
      end
      matched_table = matched.map { |row| row.values_at(*MATCHED).map { it.nil? ? "-" : it } }
      ["# Benchmark results", "", line(COLUMNS), line(COLUMNS.map { "---" }), *table.map { line(it) }, "",
       "## Matched rolling steps", "",
       "Rolling steps at which every lane on the runner passed, each on its own rolling cache after that cache's first step. Steps continued from a fresh run's cache and Actions cache steps that restored nothing are left out. Times include post-job saves.", "",
       line(MATCHED_COLUMNS), line(MATCHED_COLUMNS.map { "---" }), *matched_table.map { line(it) }, ""].join("\n")
    end

    private
      def key(record)
        [*record.values_at(*%w[adapter_command case lane level runner phase step sha]), record.dig("versions", "boringcache_release") || record.dig("versions", "boringcache"),
         [record["attempt"].to_i, 1].max, record["cache_seeded"], save_timing(record), record["machine"],
         record.dig("observed", "machine", "cpu"), record.dig("observed", "machine", "cores")]
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
        records.select { matchable?(it) }.group_by { it.values_at("adapter_command", "case", "runner") }.flat_map do |(tool, kase, runner), group|
          lanes = group.map { it["lane"] }.uniq
          next [] if lanes.size < 2

          group.group_by { [series(it), it["step"]] }.filter_map do |(series, step), at_step|
            by_lane = at_step.group_by { it["lane"] }.transform_values { |tries| tries.min_by { it["attempt"].to_i } }
            next unless lanes.all? { by_lane.key?(it) }

            cli = by_lane.values.filter_map { it.dig("versions", "boringcache_release") || it.dig("versions", "boringcache") }.uniq.sort.join(", ")
            [[tool, kase, runner, series, (cli unless cli.empty?)], step, by_lane]
          end
        end.group_by(&:first).transform_values { it.to_h { |_, step, by_lane| [step, by_lane] } }
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
        record["exit_status"] == 0 && record["output_ok"] == true
      end

      def seeded?(record)
        return seeds.fetch(record.values_at("adapter_command", "case", "scope"), false) if record["phase"] == "warm"
        return true unless record["phase"] == ROLLING && record.key?("cache_restored_key") && record["cache_restored_key"].nil?

        first_step = restoring_scopes[record.values_at("adapter_command", "case", "cache_scope")]
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
