# frozen_string_literal: true

artifact = Dir["upstream/sdk/all/build/libs/opentelemetry-sdk-*.jar"].find { |path| File.file?(path) }
abort "OpenTelemetry SDK JAR is missing or empty" unless artifact && File.size?(artifact)
