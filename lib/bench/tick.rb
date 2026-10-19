module Bench
  class Tick
    RUN_FIELDS = "databaseId,displayTitle,status,conclusion,createdAt".freeze
    WAITING = %w[queued pending waiting requested].freeze
    ACTIVE = ["in_progress", *WAITING].freeze

    def self.title(tool, project) = "#{tool} - #{project} (rolling)"

    def self.plan(projects, runs, behind:)
      notes = []
      chosen = projects.select do |tool, project|
        title = title(tool, project)
        mine = runs.select { it["displayTitle"].to_s.sub(/ step \d+\z/, "").casecmp?(title) }
        active = runs.find { ACTIVE.include?(it["status"]) && [title.downcase, "#{tool} - #{project} (sample)".downcase].include?(it["displayTitle"].to_s.sub(/ step \d+\z/, "").downcase) }
        if active
          notes << ["busy", title, "run #{active["databaseId"]} is #{active["status"]}"]
          next false
        end
        last = mine.select { it["status"] == "completed" }.max_by { it["createdAt"] }
        notes << ["REVIEW", title, "last run #{last["databaseId"]} concluded #{last["conclusion"]}"] if last && last["conclusion"] != "success"
        unless behind.call(tool, project)
          notes << ["current", title, "no upstream commit due"]
          next false
        end
        true
      rescue Error => error
        notes << ["FAILED", title, "upstream check failed: #{error.message}"]
        false
      end
      [chosen, notes]
    end

    def initialize(repo, gh: Bench.method(:gh), out: $stdout, now: Time.now.utc)
      @repo = repo
      @gh = gh
      @out = out
      @now = now
    end

    def call(projects, behind:, dry_run: false)
      runs = JSON.parse(@gh.call("run", "list", "-R", @repo, "--workflow", "project.yml", "--limit", "300", "--json", RUN_FIELDS))
      runs += ACTIVE.flat_map do |status|
        @gh.call("api", "--paginate", "repos/#{@repo}/actions/workflows/project.yml/runs?per_page=100&status=#{status}", "--jq",
                 ".workflow_runs[] | {databaseId: .id, displayTitle: .display_title, status, conclusion, createdAt: .created_at}").lines.map { JSON.parse(it) }
      end
      chosen, notes = self.class.plan(projects, runs, behind:)
      notes.each { |verb, title, note| @out.puts format("%-8s %s (%s)", verb, title, note) }
      failed = chosen.count do |tool, project|
        ok = dry_run || dispatch(tool, project)
        @out.puts "#{ok ? "dispatch" : "FAILED  "} #{self.class.title(tool, project)}#{" (dry run)" if dry_run}"
        !ok
      end
      @out.puts "#{dry_run ? "would dispatch" : "dispatched"} #{chosen.size - failed} of #{projects.size} projects at #{@now.strftime("%H:%M")} UTC"
      failed + notes.count { it.first == "FAILED" }
    end

    private
      def dispatch(tool, project)
        @gh.call("workflow", "run", "project.yml", "-R", @repo, "--ref", "main", "-f", "tool=#{tool}", "-f", "project=#{project}", "-f", "mode=rolling")
        true
      rescue Error
        false
      end
  end
end
