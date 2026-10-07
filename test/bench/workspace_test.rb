require_relative "test_helper"

class WorkspaceTest < Minitest::Test
  def test_scope_plan_suffixes_adapter_entry_and_inline_tool_cache_tags
    plan = TomlRB.parse(<<~TOML)
      workspace = "boringcache/benchmarks"
      [entries.deps]
      tag = "deps"
      path = "upstream/.pnpm-store"
      [adapters.turbo]
      tag = "turbo-main"
      [adapters.docker]
      tag = "posthog"
      tool-cache = ["turbo:turbo-main", "sccache"]
      mount-cache = true
    TOML

    scoped = Bench::Workspace.scope_plan(plan, "r1")

    assert_equal "deps-r1", scoped.dig("entries", "deps", "tag")
    assert_equal "turbo-main-r1", scoped.dig("adapters", "turbo", "tag")
    assert_equal "posthog-r1", scoped.dig("adapters", "docker", "tag")
    assert_equal ["turbo:turbo-main-r1", "sccache"], scoped.dig("adapters", "docker", "tool-cache")
    assert_equal "boringcache/benchmarks", scoped["workspace"]
  end
end
