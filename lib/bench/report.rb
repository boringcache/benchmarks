module Bench
  class Report
    KEY = %w[adapter_command case lane level runner phase].freeze
    COLUMNS = %w[Tool Case Lane Level Runner Phase Samples Failed Output\ ok Median\ s Min\ s Max\ s].freeze

    def initialize(results_dir)
      @results_dir = results_dir
    end

    def records
      @records ||= Dir.glob(File.join(@results_dir, "**", "*.json")).sort.map { JSON.parse(File.read(it)) }
    end

    def rows
      records.group_by { it.values_at(*KEY) }.map { |key, group| row(key, group) }.sort_by { it.values_at(*KEY).map(&:to_s) }
    end

    def write(out_dir)
      FileUtils.mkdir_p(out_dir)
      File.write(File.join(out_dir, "results.json"), JSON.pretty_generate("rows" => rows) + "\n")
      File.write(File.join(out_dir, "report.md"), markdown)
    end

    def markdown
      table = rows.map do |row|
        row.values_at(*KEY, "samples", "failed", "output_ok", "median_seconds", "min_seconds", "max_seconds").map { it.nil? ? "unmeasured" : it }
      end
      ["# Benchmark results", "", line(COLUMNS), line(COLUMNS.map { "---" }), *table.map { line(it) }, ""].join("\n")
    end

    private
      def row(key, group)
        seconds = group.select { it["exit_status"].to_i.zero? }.filter_map { it["seconds"] }.sort
        KEY.zip(key).to_h.merge(
          "samples" => group.size,
          "failed" => group.count { !it["exit_status"].to_i.zero? },
          "output_ok" => group.count { it["output_ok"] == true },
          "median_seconds" => median(seconds),
          "min_seconds" => seconds.first,
          "max_seconds" => seconds.last,
          "run_urls" => group.filter_map { it["run_url"] }.uniq
        )
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
