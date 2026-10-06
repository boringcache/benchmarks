# frozen_string_literal: true

artifact = Dir["upstream/spring-ai-commons/target/spring-ai-commons-*.jar"].find { |path| File.file?(path) }
abort "Spring AI commons JAR is missing or empty" unless artifact && File.size?(artifact)
