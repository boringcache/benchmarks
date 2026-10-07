require_relative "test_helper"

class CheckTest < Minitest::Test
  include BenchFixture

  def test_consistent_catalog_has_no_problems
    assert_empty Bench::Check.new(catalog).problems
  end

  def test_rejects_short_sha_unknown_lane_and_disallowed_runner
    write "tools/demo/app/case.toml", <<~TOML
      repo = "owner/app"
      branch = "main"
      start_sha = "abc123"
      check = "true"
      [runs]
      missing = ["local"]
      gha = ["local"]
      remote = ["nowhere"]
    TOML

    assert_equal [
      "demo/app: start_sha must be a full 40-character sha",
      "demo/app: unknown lane missing",
      "demo/app: gha cannot run on local",
      "demo/app: remote uses unknown runner nowhere"
    ], Bench::Check.new(catalog).problems
  end

  def test_boringcache_lane_needs_its_plan
    FileUtils.rm(File.join(@root, "tools/demo/app/.boringcache.toml"))

    assert_includes Bench::Check.new(catalog).problems, "demo/app: boringcache-demo has no plan at ./.boringcache.toml"
  end

  def test_boringcache_plan_must_cache_every_shared_path
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml"))
      .sub("check = ", %(shared = ["upstream/deps", ".store", ".missing"]\ncheck = )).concat(%([env]\nSTORE = "${BENCH_DIR}/.store"\n))
    write "tools/demo/app/.boringcache.toml", File.read(File.join(@root, "tools/demo/app/.boringcache.toml"))
      .concat(%([entries.store]\ntag = "demo-store"\npath-env = "STORE"\n))

    assert_equal ["demo/app: boringcache-demo does not cache shared path .missing"], Bench::Check.new(catalog).problems
  end

  def test_lane_level_must_exist_in_tool
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "plus"\n)

    assert_includes Bench::Check.new(catalog).problems, %(demo/lanes/remote: level "plus" is not in tool.toml)
  end
end
