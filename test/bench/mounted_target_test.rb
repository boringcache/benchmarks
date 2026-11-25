require_relative "test_helper"

class MountedTargetTest < Minitest::Test
  def test_replaces_only_the_target_and_keeps_sccache_and_dependency_tags
    root = File.expand_path("../..", __dir__)
    %w[nushell zed codex ferrum-fuzz].each do |project|
      plan = TomlRB.load_file(File.join(root, "tools/cargo", project, "plus/.boringcache.toml"))
      expected = plan.fetch("entries").reject { |_, entry| entry["kind"] == "cargo-target" }
      adapters = Marshal.load(Marshal.dump(plan.fetch("adapters")))
      Bench::MountedTarget.remove_archive(plan)
      assert_equal expected, plan.fetch("entries")
      assert_equal expected.keys, plan.dig("profiles", "cargo-product", "entries")
      assert_equal adapters, plan.fetch("adapters")
    end
  end
end
