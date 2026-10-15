require_relative "test_helper"

class CheckTest < Minitest::Test
  include BenchFixture

  def test_consistent_catalog_has_no_problems
    assert_empty Bench::Check.new(catalog).problems
  end

  def test_rejects_floating_ubuntu_runner
    write "runners.toml", %([github]\nlabel = "ubuntu-latest"\nmachine = "github 4c"\n[local]\nlabel = "local"\nmachine = "local"\n)

    assert_equal ["runners.toml: github must use an explicit Ubuntu version"], Bench::Check.new(catalog).problems
  end

  def test_rolling_list_must_name_existing_projects
    write "rolling.toml", %(demo = ["app", "missing"]\n)

    assert_equal ["rolling.toml: no demo cases for project \"missing\""], Bench::Check.new(catalog).problems
    assert_equal [["demo", "app"], ["demo", "missing"]], catalog.rolling.map { |tool, project| [tool.name, project] }
  end

  def test_nightly_lanes_must_be_runs_of_the_case
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")) + %([nightly]\nremote = ["github"]\ngha = ["local"]\n)

    assert_equal ["demo/app: nightly gha on local is not in [runs]"], Bench::Check.new(catalog).problems
  end

  def test_a_script_case_needs_a_command_list_and_lanes_that_keep_the_plan_command
    write "tools/demo/lanes/boringcache-phases.toml", %(provider = "boringcache"\nlevel = "base"\nphases = true\n)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]\n", %(script = "make"\n[runs]\nboringcache-phases = ["local"]\n))

    assert_equal ["demo/app: script must be a command list", "demo/app: boringcache-phases replaces the plan command, which a script case does not run"], Bench::Check.new(catalog).problems
  end

  def test_a_seed_names_another_boringcache_lane_with_the_same_entries_on_the_same_runners
    write "tools/demo/lanes/boringcache-seeded.toml", %(provider = "boringcache"\nlevel = "base"\nplan = "other"\nseed = "boringcache-demo"\n)
    write "tools/demo/lanes/remote-seeded.toml", %(provider = "remote"\nlevel = "base"\nseed = "remote"\n)
    write "tools/demo/app/other/.boringcache.toml", %(workspace = "boringcache/benchmarks"\n[adapters.demo]\ntag = "demo-app"\n[entries.deps]\ntag = "demo-other-deps"\npath = "upstream/deps"\n)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("boringcache-demo = [\"local\", \"github\"]", "boringcache-demo = [\"github\"]").sub("[runs]\n", "[runs]\nboringcache-seeded = [\"local\"]\n")

    assert_equal ["demo/lanes/remote-seeded: seed must name another BoringCache lane",
                  "demo/app: boringcache-seeded seeds from boringcache-demo, which does not run on local",
                  "demo/app: boringcache-seeded seeds from boringcache-demo, whose plan has different entries"], Bench::Check.new(catalog).problems
  end

  def test_an_incremental_lane_needs_a_plan_without_the_compiler_cache
    write "tools/demo/lanes/boringcache-incremental.toml", %(provider = "boringcache"\nlevel = "base"\nplan = "incremental"\n[env]\nCARGO_INCREMENTAL = "1"\n)
    write "tools/demo/app/incremental/.boringcache.toml", %(workspace = "boringcache/benchmarks"\n[adapters.cargo]\nprofiles = ["deps"]\n)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]\n", "[runs]\nboringcache-incremental = [\"local\"]\n")

    assert_equal ["demo/app: boringcache-incremental sets CARGO_INCREMENTAL=1, which sccache refuses; its plan needs compiler-cache = \"none\""], Bench::Check.new(catalog).problems

    write "tools/demo/app/incremental/.boringcache.toml", %(workspace = "boringcache/benchmarks"\n[adapters.cargo]\ncompiler-cache = "none"\nprofiles = ["deps"]\n)
    assert_empty Bench::Check.new(catalog).problems
  end

  def test_versions_case_pins_name_known_cases_and_release_tags
    write "versions.toml", %(boringcache = "1.40.0"\n[cases]\n"demo/app" = "latest"\n"demo/missing" = "vcli-canary-abc123def"\n)

    assert_equal ["versions.toml: demo/app must be a CLI release tag such as v1.41.0 or vcli-canary-<sha>", "versions.toml: [cases] names unknown case demo/missing"],
                 Bench::Check.new(catalog).problems
  end

  def test_accepts_explicit_ubuntu_26_runner
    write "runners.toml", %([github]\nlabel = "ubuntu-26.04"\nmachine = "github 4c"\n[local]\nlabel = "local"\nmachine = "local"\n)

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

  def test_namespace_cache_volume_lanes_must_name_cache_paths
    write "tools/demo/lanes/volume.toml", %(provider = "namespace"
level = "base"
setup = ["namespace-cache"]
)
    write "tools/demo/app/case.toml", File.read(File.join(@root, "tools/demo/app/case.toml")).sub("[runs]\n", %([runs]\nvolume = ["local"]\n))

    assert_equal ["demo/app: volume mounts the Namespace cache volume without cache paths"], Bench::Check.new(catalog).problems

    write "tools/demo/lanes/volume.toml", %(provider = "namespace"
level = "base"
setup = ["namespace-cache"]
paths = ["upstream/target"]
)

    assert_empty Bench::Check.new(catalog).problems
  end

  def test_lane_level_must_exist_in_tool
    write "tools/demo/lanes/remote.toml", %(provider = "remote"\nlevel = "plus"\n)

    assert_includes Bench::Check.new(catalog).problems, %(demo/lanes/remote: level "plus" is not in tool.toml)
  end
end
