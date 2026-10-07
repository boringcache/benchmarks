require "minitest/autorun"
require "tmpdir"
require_relative "../../lib/bench"

module BenchFixture
  STUB = <<~BASH
    #!/usr/bin/env bash
    if [ "$1" = "--version" ]; then echo "boringcache 9.9.9"; exit 0; fi
    tool="$1"; shift
    echo "$tool $*" >> "$STUB_LOG"
    echo '{"operation":"cache_blob_read"}' > "$BORINGCACHE_OBSERVABILITY_JSONL_PATH"
    echo '{"operation":"cache_session_summary","duration_ms":7}' >> "$BORINGCACHE_OBSERVABILITY_JSONL_PATH"
    echo boringcache > upstream/out.txt
  BASH

  def setup
    @root = Dir.mktmpdir("bench")
    @upstream_sha = create_upstream
    write "runners.toml", %(github = "ubuntu-latest"\nlocal = "local"\n)
    write "versions.toml", %(boringcache = "1.40.0"\n)
    write "tools/demo/tool.toml", %([levels]\nbase = ["remote-cache"]\n)
    write "tools/demo/lanes/boringcache-demo.toml", %(provider = "boringcache"\nlevel = "base"\n)
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "base"\nsecrets = ["REMOTE_TOKEN"]\n[env]\nDEMO_CACHE = "${REMOTE_TOKEN}"\n)
    write "tools/demo/lanes/gha.toml", %(provider = "github-actions-cache"\nlevel = "base"\nactions_only = true\nrunners = ["github"]\n)
    write "tools/demo/app/case.toml", <<~TOML
      repo = "#{File.join(@root, "upstream")}"
      branch = "main"
      start_sha = "#{@upstream_sha}"
      prepare = ["test -f upstream/README"]
      check = "test -s upstream/out.txt"
      [runs]
      boringcache-demo = ["local", "github"]
      remote = ["local", "github"]
      gha = ["github"]
    TOML
    write "tools/demo/app/.boringcache.toml", <<~TOML
      workspace = "boringcache/benchmarks"
      [adapters.demo]
      tag = "demo-app"
      command = ["bash", "-c", "echo \\"$DEMO_CACHE\\" > upstream/out.txt"]
      [entries.deps]
      tag = "demo-deps"
      path = "upstream/deps"
    TOML
    write "bin/boringcache", STUB
    File.chmod(0o755, File.join(@root, "bin/boringcache"))
  end

  def teardown
    FileUtils.rm_rf(@root)
  end

  def catalog
    Bench::Catalog.new(@root)
  end

  def write(relative, content)
    path = File.join(@root, relative)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def fixture_env
    { "PATH" => "#{File.join(@root, "bin")}:#{ENV["PATH"]}", "STUB_LOG" => File.join(@root, "stub.log"), "REMOTE_TOKEN" => "remote-secret" }
  end

  def with_fixture_env
    saved = fixture_env.keys.to_h { [it, ENV[it]] }
    ENV.update(fixture_env)
    yield
  ensure
    ENV.update(saved)
  end

  def commit_upstream(message)
    dir = File.join(@root, "upstream")
    File.write(File.join(dir, "README"), "#{message}\n")
    [%w[add README], ["-c", "user.name=bench", "-c", "user.email=bench@example.com", "commit", "--quiet", "-m", message]].each do |args|
      system("git", *args, chdir: dir, exception: true)
    end
    `git -C #{dir} rev-parse HEAD`.strip
  end

  private
    def create_upstream
      dir = File.join(@root, "upstream")
      FileUtils.mkdir_p(dir)
      [%w[init --quiet --initial-branch main], %w[config uploadpack.allowAnySHA1InWant true], %w[config uploadpack.allowFilter true]].each do |args|
        system("git", *args, chdir: dir, exception: true)
      end
      commit_upstream("init")
    end
end
