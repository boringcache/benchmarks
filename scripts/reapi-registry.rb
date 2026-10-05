# frozen_string_literal: true

require "json"
require "fileutils"
require "socket"
require "timeout"
require "open3"
require "securerandom"
require "digest"
require "base64"

# Temporary shared entrypoint for native clients without a managed adapter.
# The CLI owns authentication, cache storage, publication and shutdown flushing.
module ReapiRegistry
  class Error < StandardError; end

  def self.elapsed
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def self.with_process(command, port:, log:, startup_timeout: 120, shutdown_timeout: 180)
    FileUtils.mkdir_p(File.dirname(log))
    File.open(log, "w") do |output|
      pid = Process.spawn(*command, out: output, err: output)
      reaped = false
      begin
        deadline = elapsed + startup_timeout
        loop do
          if Process.waitpid(pid, Process::WNOHANG)
            reaped = true
            raise Error, "Cache process exited before readiness; see #{log}"
          end
          begin
            Socket.tcp("127.0.0.1", port, connect_timeout: 1) { |socket| socket.remote_address }
            break
          rescue SystemCallError, IOError
            raise Error, "Cache process did not become ready; see #{log}" if elapsed >= deadline
            sleep 0.1
          end
        end
        yield
      ensure
        original_error = $!
        unless reaped
          Process.kill("INT", pid) rescue Errno::ESRCH
          begin
            _, status = Timeout.timeout(shutdown_timeout) { Process.wait2(pid) }
            unless status.success?
              detail = original_error ? "; #{original_error.message}" : ""
              raise Error, "Cache shutdown failed (#{status.exitstatus}); see #{log}#{detail}"
            end
          rescue Timeout::Error
            Process.kill("KILL", pid) rescue Errno::ESRCH
            Process.waitpid(pid)
            raise Error, "Cache shutdown exceeded #{shutdown_timeout}s; see #{log}"
          end
        end
      end
    end
  end

  def self.command(provider:, phase:, workspace:, tag:, port: 5060)
    raise Error, "Use cold, warm or commit" unless %w[cold warm commit].include?(phase)
    case provider
    when "boringcache"
      args = ["boringcache", "cache-registry", workspace, tag, "--port", "5061", "--reapi-port", port.to_s,
        "--no-git", "--no-platform", "--fail-on-cache-error"]
      args << "--read-only" if phase == "warm"
      args
    when "bazel-remote"
      args = ["bazel-remote", "--dir", "reapi-store", "--max_size", "10", "--storage_mode", "uncompressed",
        "--http_address", "127.0.0.1:5061", "--grpc_address", "127.0.0.1:#{port}"]
      args += ["--htpasswd_file", ".reapi-readonly-auth", "--allow_unauthenticated_reads"] if phase == "warm"
      args
    else
      raise Error, "Unknown REAPI provider: #{provider}"
    end
  end

  def self.run(command:, provider:, phase:, workspace:, tag:, directory: "reapi-evidence")
    FileUtils.mkdir_p(directory)
    if provider == "bazel-remote" && phase == "warm"
      # No client receives this random credential: anonymous reads are allowed,
      # while writes require authentication and are rejected.
      hash = Base64.strict_encode64(Digest::SHA1.digest(SecureRandom.bytes(32)))
      File.write(".reapi-readonly-auth", "benchmark:{SHA}#{hash}\n", perm: 0o600)
    end
    measurements = {"provider" => provider, "phase" => phase, "command" => command, "success" => false}
    setup_started = elapsed
    with_process(self.command(provider: provider, phase: phase, workspace: workspace, tag: tag),
      port: 5060, log: File.join(directory, "registry.log")) do
      measurements["restore_or_setup_seconds"] = elapsed - setup_started
      started = elapsed
      File.open(File.join(directory, "build.log"), "w") do |log|
        Open3.popen2e(*command) do |input, output, process|
          input.close
          output.each_line { |line| log.write(line); $stdout.write(line) }
          measurements["build_success"] = process.value.success?
        end
      end
      measurements["build_seconds"] = elapsed - started
      measurements["shutdown_started"] = elapsed
    end
    measurements["save_seconds"] = elapsed - measurements.delete("shutdown_started")
    raise Error, "Native build failed; see #{directory}/build.log" unless measurements["build_success"]
    measurements["success"] = true
  ensure
    if measurements
      measurements.delete("shutdown_started")
      File.write(File.join(directory, "timing.json"), JSON.pretty_generate(measurements) + "\n")
    end
  end
end
