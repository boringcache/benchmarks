module Bench
  class Report
    KEY = %w[adapter_command case lane level runner phase step sha boringcache attempt cache_seeded cache_save_timing machine cpu cores].freeze
    COLUMNS = %w[Tool Case Lane Level Runner Phase Step Commit CLI Attempt Seeded Save Machine CPU Cores Samples Failed Seed\ failed Timed\ median\ s Timed\ min\ s Timed\ max\ s].freeze

    def initialize(results_dir)
      @results_dir = results_dir
    end

    def records
      @records ||= Dir.glob(File.join(@results_dir, "**", "*.json")).sort.map { JSON.parse(File.read(it)) }
    end

    def rows
      records.group_by { key(it) }.map { |key, group| row(key, group) }.sort_by { it.values_at(*KEY).map(&:to_s) }
    end

    def write(out_dir)
      FileUtils.mkdir_p(out_dir)
      File.write(File.join(out_dir, "results.json"), JSON.pretty_generate("rows" => rows) + "\n")
      File.write(File.join(out_dir, "report.md"), markdown)
    end

    def markdown
      table = rows.map do |row|
        row.merge("sha" => row["sha"]&.slice(0, 12)).values_at(*KEY).map { it.nil? ? "-" : it } +
          row.values_at("samples", "failed", "seed_failed", "median_seconds", "min_seconds", "max_seconds").map { it.nil? ? "unmeasured" : it }
      end
      ["# Benchmark results", "", line(COLUMNS), line(COLUMNS.map { "---" }), *table.map { line(it) }, ""].join("\n")
    end

    private
      def key(record)
        [*record.values_at(*%w[adapter_command case lane level runner phase step sha]), record.dig("versions", "boringcache_release") || record.dig("versions", "boringcache"),
         [record["attempt"].to_i, 1].max, record["cache_seeded"], record["cache_save_timing"], record["machine"],
         record.dig("observed", "machine", "cpu"), record.dig("observed", "machine", "cores")]
      end

      def row(key, group)
        seconds = group.select { passed?(it) && seeded?(it) }.filter_map { it["seconds"] }.sort
        KEY.zip(key).to_h.merge(
          "samples" => group.size,
          "failed" => group.count { !passed?(it) },
          "seed_failed" => group.count { passed?(it) && !seeded?(it) },
          "median_seconds" => median(seconds),
          "min_seconds" => seconds.first,
          "max_seconds" => seconds.last,
          "run_urls" => group.filter_map { it["run_url"] }.uniq
        )
      end

      def passed?(record)
        record["exit_status"] == 0 && record["output_ok"] == true
      end

      def seeded?(record)
        record["phase"] != "warm" || seeds.fetch(record.values_at("adapter_command", "case", "scope"), false)
      end

      def seeds
        @seeds ||= records.select { it["phase"] == "cold" }.to_h { [it.values_at("adapter_command", "case", "scope"), passed?(it)] }
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
