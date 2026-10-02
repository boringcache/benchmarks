# frozen_string_literal: true

require "toml-rb"
require "json"
require "optparse"
require "shellwords"
require "fileutils"
require "open3"

module BenchmarkPlan
  ROOT = File.expand_path("..", __dir__)

  def self.load(path = File.join(ROOT, ".boringcache.toml"))
    TomlRB.load_file(path)
  end

  def self.settings(path)
    File.readlines(path).filter_map do |line|
      line = line.strip
      next if line.empty? || line.start_with?("#")
      key, value = line.split("=", 2)
      raise "Invalid setting in #{path}" unless value
      fields = Shellwords.split(value)
      raise "Expected one value for #{key}" if fields.length > 1
      [key, fields.first.to_s]
    end.to_h
  end

  def self.require_match(condition, message)
    raise message unless condition
  end

  def self.command(adapter, path = File.join(ROOT, ".boringcache.toml"))
    args = load(path).fetch("adapters").fetch(adapter).fetch("command")
    raise "adapters.#{adapter}.command must be a nonempty argv array" unless args.is_a?(Array) && !args.empty? && args.all? { |item| item.is_a?(String) }
    args
  end

  def self.run(argv)
    adapter = argv.shift
    directory = "."
    print0 = false
    OptionParser.new do |parser|
      parser.on("--working-directory PATH") { |value| directory = value }
      parser.on("--print0") { print0 = true }
    end.parse!(argv)
    raise "Unexpected arguments: #{argv.join(' ')}" unless argv.empty?
    args = command(adapter)
    if print0
      $stdout.write(args.join("\0") + "\0")
    else
      target = File.realpath(File.expand_path(directory, ROOT))
      raise "Working directory must stay inside the case checkout" unless target == ROOT || target.start_with?(ROOT + "/")
      exec(*args, chdir: target)
    end
  end

  def self.replace_setting(body, key, value)
    lines = body.lines
    start = lines.index { |line| line.match?(/^#{Regexp.escape(key)}\s*=/) }
    if start
      finish = start + 1
      finish += 1 while lines[start].include?("[") && !lines[start...finish].join.include?("]") && finish < lines.length
      lines[start...finish] = value.nil? ? [] : ["#{key} = #{value}\n"]
    elsif value
      index = lines.index { |line| line.start_with?("command = [") } || lines.length
      lines.insert(index, "#{key} = #{value}\n")
    end
    lines.join
  end

  def self.render_command(args)
    "command = [\n" + args.map { |value| "  #{JSON.generate(value)},\n" }.join + "]\n"
  end

  def self.replace_command(text, args)
    pattern = /^command\s*=\s*\[.*?^\]\n?/m
    raise "Expected one command array" unless text.scan(pattern).length == 1
    text.sub(pattern, render_command(args))
  end

  def self.write_output(name, value)
    value = value.to_s
    raise "Invalid output name" unless name.match?(/\A[a-zA-Z0-9_]+\z/)
    content = if value.include?("\n")
      require "securerandom"
      delimiter = "benchmark_#{SecureRandom.hex(16)}"
      "#{name}<<#{delimiter}\n#{value}\n#{delimiter}\n"
    else
      "#{name}=#{value}\n"
    end
    ENV["GITHUB_OUTPUT"] ? File.open(ENV["GITHUB_OUTPUT"], "a") { |file| file.write(content) } : $stdout.write(content)
  end
end
