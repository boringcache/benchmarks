require_relative "test_helper"

class JavaCaPreparationTest < Minitest::Test
  CASES = %w[gradle/opentelemetry-java maven/spring-ai sbt/play sbt/lila].freeze

  def run_preparation(id, mise_exit: 0)
    Dir.mktmpdir("java preparation ") do |directory|
      bin = File.join(directory, "bin")
      FileUtils.mkdir_p(bin)
      File.write(File.join(bin, "mise"), "#!/bin/sh\necho mise-$1 >> \"$LOG\"\nexit #{mise_exit}\n")
      File.write(File.join(bin, "java"), "#!/bin/sh\ntest -f \"$1\" && test \"$2\" = --apply || exit 1\necho java >> \"$LOG\"\n")
      FileUtils.chmod(0o755, Dir[File.join(bin, "*")])
      log = File.join(directory, "calls")
      kase = Bench::Catalog.new(Bench::ROOT).find_case(id)
      success = system({"PATH" => "#{bin}:#{ENV.fetch('PATH')}", "JAVA_HOME" => directory,
        "TEST_JAVA_HOME" => directory, "BENCH_ROOT" => Bench::ROOT, "LOG" => log},
        "bash", "-c", kase.prepare.first, chdir: directory)
      [success, File.readlines(log, chomp: true)]
    end
  end

  def test_every_java_case_repairs_each_selected_jdk_after_installation
    CASES.each do |id|
      success, calls = run_preparation(id)

      assert success, id
      assert_equal ["mise-trust", "mise-install", *Array.new(id.start_with?("gradle/") ? 2 : 1, "java")], calls, id
    end
  end

  def test_failed_installation_stops_before_java_store_changes
    success, calls = run_preparation(CASES.first, mise_exit: 1)

    refute success
    assert_equal ["mise-trust"], calls
  end
end
