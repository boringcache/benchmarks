#!/usr/bin/env ruby
# frozen_string_literal: true

module BenchmarkReporting
  module_function

  def most_common(values)
    values = values.compact.reject { |value| value.to_s.empty? }
    return nil if values.empty?

    values.group_by(&:itself).max_by { |_, grouped| grouped.length }&.first
  end

  def rolling_reseed_count(classification)
    reseed_count = classification["rolling_reseed_count"]
    reseed_count = 1 if reseed_count.nil? && classification["rolling_reseed"] == true
    reseed_count.to_i
  end

  def legacy_rolling_reseed_investigation?(lane:, category:, classification:)
    lane.to_s == "rolling" &&
      category.to_s == "docker" &&
      rolling_reseed_count(classification).positive?
  end

  def invalid_sample?(classification)
    return true if classification["sample_valid"] == false
    return true if classification["invalid_count"].to_i.positive?

    if classification.key?("sample_valid_count") && classification.key?("sample_count")
      return true if classification["sample_valid_count"].to_i < classification["sample_count"].to_i
    end

    false
  end

  def reporting_mode(lane:, category:, classification:)
    mode = classification["reporting_mode"].to_s
    return mode unless mode.empty?
    return "invalid" if invalid_sample?(classification)
    return "investigation_only" if legacy_rolling_reseed_investigation?(lane: lane, category: category, classification: classification)

    "comparative"
  end

  def reporting_summary(lane:, category:, classification:, sample_count:)
    case reporting_mode(lane: lane, category: category, classification: classification)
    when "invalid"
      reason = classification["validity_reason"] || classification["reporting_reason"] || "invalid_sample"
      {
        "comparative" => false,
        "status" => "invalid",
        "reason" => reason,
        "headline_scenario" => invalid_headline_scenario(reason: reason, lane: lane),
        "headline_label" => invalid_headline_label(reason: reason, lane: lane),
        "result_text" => "invalid sample",
        "note" => classification["reporting_note"] || invalid_note(reason: reason, lane: lane)
      }
    when "investigation_only"
      reason = classification["reporting_reason"] || "investigation_only"
      {
        "comparative" => false,
        "status" => "investigation_only",
        "reason" => reason,
        "headline_scenario" => investigation_headline_scenario(reason: reason, lane: lane),
        "headline_label" => investigation_headline_label(reason: reason, lane: lane),
        "result_text" => investigation_result_text(reason: reason, classification: classification, sample_count: sample_count),
        "note" => classification["reporting_note"] || investigation_note(reason: reason, lane: lane)
      }
    else
      { "comparative" => true }
    end
  end

  def scenario_pair(scenario:, actions_cold:, boringcache_cold:, actions_warm:, boringcache_warm:, actions_run_total:, boringcache_run_total:)
    case scenario.to_s
    when "warm"
      [actions_warm, boringcache_warm]
    when "cold", "first_build"
      [actions_cold, boringcache_cold]
    when "run_total"
      [actions_run_total, boringcache_run_total]
    else
      [nil, nil]
    end
  end

  def rollup_classification(lane:, category:, classifications:)
    sample_count = classifications.length
    return nil if sample_count.zero?

    invalid_count = 0
    investigation_only_count = 0
    comparative_count = 0

    classifications.each do |classification|
      case reporting_mode(lane: lane, category: category, classification: classification)
      when "invalid"
        invalid_count += 1
      when "investigation_only"
        investigation_only_count += 1
      else
        comparative_count += 1
      end
    end

    {
      "sample_count" => sample_count,
      "sample_valid_count" => classifications.count { |classification| classification["sample_valid"] != false },
      "invalid_count" => invalid_count,
      "investigation_only_count" => investigation_only_count,
      "comparative_count" => comparative_count,
      "reporting_mode" => if invalid_count.positive?
        "invalid"
      elsif investigation_only_count.positive?
        "investigation_only"
      else
        "comparative"
      end,
      "reporting_reason" => most_common(classifications.map { |classification| classification["reporting_reason"] }),
      "reporting_note" => most_common(classifications.map { |classification| classification["reporting_note"] }),
      "validity_reason" => most_common(classifications.map { |classification| classification["validity_reason"] }),
      "cache_import_status" => most_common(classifications.map { |classification| classification["cache_import_status"] }),
      "rolling_reseed_count" => classifications.count { |classification| classification["rolling_reseed"] == true },
      "steady_state_candidate_count" => classifications.count { |classification| classification["steady_state_candidate"] == true }
    }
  end

  def invalid_headline_scenario(reason:, lane:)
    return "warm" if reason.to_s == "fresh_warm_cache_import_not_ok"

    lane.to_s == "rolling" ? "first_build" : "warm"
  end

  def invalid_headline_label(reason:, lane:)
    return "Warm Build" if invalid_headline_scenario(reason: reason, lane: lane) == "warm"

    "First Build"
  end

  def invalid_note(reason:, lane:)
    case reason.to_s
    when "fresh_warm_cache_import_not_ok"
      "Fresh BoringCache warm reruns require a usable cache import; this sample is diagnostic only."
    else
      lane.to_s == "rolling" ? "This rolling sample is invalid and should not be used for parity claims." : "This fresh sample is invalid and should not be used for parity claims."
    end
  end

  def investigation_headline_scenario(reason:, lane:)
    lane.to_s == "rolling" ? "first_build" : "cold"
  end

  def investigation_headline_label(reason:, lane:)
    lane.to_s == "rolling" ? "First Build" : "Cold Build"
  end

  def investigation_result_text(reason:, classification:, sample_count:)
    case reason.to_s
    when "rolling_reseed"
      reseed_count = rolling_reseed_count(classification)
      sample_count.to_i > 1 ? "reseeded #{reseed_count}/#{sample_count}" : "reseeded"
    when "rolling_cache_import_not_ok"
      status = classification["cache_import_status"] || "not ok"
      "cache import #{status}"
    else
      "investigation only"
    end
  end

  def investigation_note(reason:, lane:)
    case reason.to_s
    when "rolling_reseed"
      "Rolling Docker reseeds are first-build investigation samples, not steady-state parity."
    when "rolling_cache_import_not_ok"
      "Rolling BoringCache seed completed without a usable cache import; treat this as investigation-only."
    else
      lane.to_s == "rolling" ? "This rolling sample is investigation-only." : "This sample is investigation-only."
    end
  end
end
