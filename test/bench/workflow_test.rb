require_relative "test_helper"
require "yaml"

class WorkflowTest < Minitest::Test
  def test_patched_bitrise_is_installed_before_lane_preparation
    action = YAML.load_file(File.join(Bench::ROOT, ".github/actions/phase/action.yml"))
    steps = action.fetch("runs").fetch("steps")
    prepare = steps.index { it["id"] == "prepare" }
    download = steps.index { it["run"].to_s.include?("boringcache artifact pull") }
    installer = steps.index { it["run"] == "bash scripts/install-boringcache.sh" }

    assert_operator installer, :<, download
    assert_operator download, :<, prepare
    [installer, download].each do |index|
      refute_includes steps[index].fetch("if"), "steps.prepare"
    end
  end
end
