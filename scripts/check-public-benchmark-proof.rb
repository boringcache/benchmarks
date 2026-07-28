#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

index_path = ARGV[0] || File.expand_path("../data/latest/index.json", __dir__)
payload = JSON.parse(File.read(index_path))

required_product_refs = %w[cli_version web_revision].freeze
errors = []

payload.fetch("entries").each do |entry|
  next unless entry["public"] == true

  lanes = entry["lanes"].is_a?(Hash) ? entry["lanes"] : { entry["lane"] => entry }
  lanes.each do |lane, lane_entry|
    label = "#{entry.fetch("benchmark")}/#{lane}"
    boringcache = lane_entry.dig("comparison", "boringcache")
    next unless boringcache.is_a?(Hash)

    classification = boringcache["classification"].is_a?(Hash) ? boringcache["classification"] : {}
    next unless classification["sample_valid"] == true

    refs = boringcache["product_refs"].is_a?(Hash) ? boringcache["product_refs"] : {}
    required_product_refs.each do |key|
      next unless refs[key].to_s.empty?

      errors << "#{label}: missing product_refs.#{key} for public valid BoringCache proof"
    end

    action_ref_present = !refs["action_ref"].to_s.empty?
    action_sha_present = !refs["action_sha"].to_s.empty?
    if action_ref_present != action_sha_present
      missing_key = action_ref_present ? "action_sha" : "action_ref"
      errors << "#{label}: missing product_refs.#{missing_key} for Action-backed public proof"
    end

    if boringcache["product_refs_consistent"] != true
      errors << "#{label}: product_refs_consistent must be true for public valid BoringCache proof"
    end

    import_status = classification["cache_import_status"].to_s
    reporting_mode = classification["reporting_mode"].to_s
    if !import_status.empty? && import_status != "ok" && reporting_mode == "comparative"
      errors << "#{label}: cache_import_status=#{import_status} cannot be comparative public proof"
    end
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "public benchmark proof guardrails passed: #{index_path}"
