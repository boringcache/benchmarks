require "tmpdir"
require "yaml"
require_relative "../lib/bench"
require_relative "../tools/docker/shared/euro-office-cache"

def github(path, accept: "application/vnd.github+json", **query)
  args = query.flat_map { |key, value| ["-f", "#{key}=#{value}"] }
  Bench.gh("api", "--method", "GET", "-H", "Accept: #{accept}", path, *args)
end

def upstream_file(repo, sha, path)
  github("repos/#{repo}/contents/#{path}", accept: "application/vnd.github.raw+json", ref: sha)
end

case_id, ref = ARGV
kase = Bench::Catalog.new(Bench::ROOT).find_case(case_id)
repo = kase.repo
ref ||= kase.branch
sha = JSON.parse(github("repos/#{repo}/commits/#{ref}")).fetch("sha")
puts "#{case_id}: #{repo}@#{sha}"

case case_id
when "docker/euro-office-cache"
  core = JSON.parse(github("repos/#{repo}/contents/core", ref: sha)).fetch("sha")
  %i[core wasm].zip(%w[core core-wasm]).each do |method, name|
    source = upstream_file("Euro-Office/core", core, ".docker/#{name}.bake.Dockerfile")
    [true, false].each { |local_cache| EuroOfficeCache.public_send(method, source, third_party: "upstream-check", local_cache:) }
  end
when "docker/llama-cpp"
  Dir.mktmpdir("llama-overlay") do |dir|
    File.write(File.join(dir, "cuda.Dockerfile"), upstream_file(repo, sha, ".devops/cuda.Dockerfile"))
    system(RbConfig.ruby, File.join(kase.overlay_dir, "prepare.rb"),
      "cuda.Dockerfile", "ccache.Dockerfile", chdir: dir, exception: true)
  end
when "docker/posthog"
  Dir.mktmpdir("posthog-overlay") do |dir|
    FileUtils.cp_r(kase.overlay_dir, dir)
    FileUtils.mkdir_p(File.join(dir, "upstream"))
    File.write(File.join(dir, "upstream/Dockerfile"), upstream_file(repo, sha, "Dockerfile"))
    system("bash", "overlay/prepare.sh", chdir: dir, exception: true)
  end
when "pants/backend-ai"
  workflow = YAML.safe_load(upstream_file(repo, sha, ".github/workflows/build-test.yml"), aliases: true)
  upstream_step = workflow.fetch("jobs").values.flat_map { |job| job.fetch("steps", []) }.find { |step| step["name"] == "Build both lazy and fat packages" }
  upstream = upstream_step&.fetch("run")&.lines&.find { |line| line.start_with?("pants ") }
  benchmark = TomlRB.load_file(File.join(kase.dir, ".boringcache.toml")).dig("adapters", "pants", "command")
  abort "Backend.AI CI changed its Pants packaging command" unless upstream &&
    Shellwords.split(upstream) == benchmark - %w[--no-pantsd --stats-log]
when "cargo/nushell"
  workflow = YAML.safe_load(upstream_file(repo, sha, ".github/workflows/ci.yml"), aliases: true)
  job = workflow.fetch("jobs").fetch("root")
  env = job.fetch("env")
  steps = job.fetch("steps").select { |step| %w[Build Test Doctest].include?(step["name"]) }
  upstream = steps.map do |step|
    command = step.fetch("run").gsub("${{ github.workspace }}/", "")
      .gsub(/\$\{\{ env\.([\w-]+) \}\}/) { env.fetch(Regexp.last_match(1)) }
    Shellwords.split(command)
  end
  benchmark = File.readlines(File.join(kase.overlay_dir, "ci.sh")).grep(/\Acargo_step /).map do |line|
    ["cargo", "--config", ".cargo/ci.toml", *Shellwords.split(line).drop(3)]
  end
  abort "Nushell CI changed its Cargo build or test commands" unless upstream == benchmark
else
  abort "No upstream check for #{case_id}"
end
