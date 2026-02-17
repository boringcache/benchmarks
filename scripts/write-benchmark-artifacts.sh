#!/usr/bin/env bash
set -euo pipefail

benchmark=""
strategy=""
project_repo=""
project_ref=""
cold_seconds=""
warm1_seconds=""
warm2_seconds=""
cache_storage_bytes="0"
cache_storage_source=""
bytes_uploaded=""
bytes_downloaded=""
hit_behavior_note=""
output_dir="benchmark-results"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --benchmark)
      benchmark="$2"
      shift 2
      ;;
    --strategy)
      strategy="$2"
      shift 2
      ;;
    --project-repo)
      project_repo="$2"
      shift 2
      ;;
    --project-ref)
      project_ref="$2"
      shift 2
      ;;
    --cold-seconds)
      cold_seconds="$2"
      shift 2
      ;;
    --warm1-seconds)
      warm1_seconds="$2"
      shift 2
      ;;
    --warm2-seconds)
      warm2_seconds="$2"
      shift 2
      ;;
    --cache-storage-bytes)
      cache_storage_bytes="$2"
      shift 2
      ;;
    --cache-storage-source)
      cache_storage_source="$2"
      shift 2
      ;;
    --bytes-uploaded)
      bytes_uploaded="$2"
      shift 2
      ;;
    --bytes-downloaded)
      bytes_downloaded="$2"
      shift 2
      ;;
    --hit-behavior-note)
      hit_behavior_note="$2"
      shift 2
      ;;
    --output-dir)
      output_dir="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$benchmark" || -z "$strategy" || -z "$project_repo" || -z "$project_ref" || -z "$cold_seconds" ]]; then
  echo "Missing required arguments" >&2
  exit 1
fi

if [[ -z "$cache_storage_source" ]]; then
  cache_storage_source="unspecified"
fi

if ! [[ "$cache_storage_bytes" =~ ^[0-9]+$ ]]; then
  cache_storage_bytes="0"
fi

json_num_or_null() {
  local v="$1"
  if [[ -z "$v" ]]; then
    echo "null"
  else
    echo "$v"
  fi
}

if [[ -n "$bytes_uploaded" ]] && ! [[ "$bytes_uploaded" =~ ^[0-9]+$ ]]; then
  bytes_uploaded=""
fi
if [[ -n "$bytes_downloaded" ]] && ! [[ "$bytes_downloaded" =~ ^[0-9]+$ ]]; then
  bytes_downloaded=""
fi

warm_count=0
warm_total=0
if [[ -n "$warm1_seconds" ]]; then
  warm_count=$((warm_count + 1))
  warm_total=$((warm_total + warm1_seconds))
fi
if [[ -n "$warm2_seconds" ]]; then
  warm_count=$((warm_count + 1))
  warm_total=$((warm_total + warm2_seconds))
fi

if [[ $warm_count -gt 0 ]]; then
  warm_avg=$(awk -v total="$warm_total" -v count="$warm_count" 'BEGIN { printf "%.2f", total / count }')
  improvement_pct=$(awk -v cold="$cold_seconds" -v warm="$warm_avg" 'BEGIN { if (cold <= 0) { print "0.00" } else { printf "%.2f", ((cold - warm) / cold) * 100 } }')
else
  warm_avg="null"
  improvement_pct="null"
fi

cache_storage_mib=$(awk -v bytes="$cache_storage_bytes" 'BEGIN { printf "%.2f", bytes / 1048576 }')

mkdir -p "$output_dir"
json_path="$output_dir/${benchmark}-${strategy}.json"
md_path="$output_dir/${benchmark}-${strategy}.md"
generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat > "$json_path" <<JSON
{
  "benchmark": "$benchmark",
  "strategy": "$strategy",
  "project": {
    "repo": "$project_repo",
    "ref": "$project_ref"
  },
  "generated_at": "$generated_at",
  "runs": {
    "cold_seconds": $(json_num_or_null "$cold_seconds"),
    "warm1_seconds": $(json_num_or_null "$warm1_seconds"),
    "warm2_seconds": $(json_num_or_null "$warm2_seconds")
  },
  "speed": {
    "warm_average_seconds": $warm_avg,
    "warm_vs_cold_improvement_pct": $improvement_pct
  },
  "cache": {
    "storage_bytes": $cache_storage_bytes,
    "storage_mib": $cache_storage_mib,
    "storage_source": "$cache_storage_source"
  },
  "transfer": {
    "bytes_uploaded": $(json_num_or_null "$bytes_uploaded"),
    "bytes_downloaded": $(json_num_or_null "$bytes_downloaded")
  },
  "hit_behavior": {
    "two_consecutive_warm_runs_succeeded": $([[ -n "$warm1_seconds" && -n "$warm2_seconds" ]] && echo true || echo false),
    "note": "$hit_behavior_note"
  }
}
JSON

cat > "$md_path" <<MD
## ${benchmark} (${strategy})

| Metric | Value |
|---|---|
| Project | \`${project_repo}\` |
| Commit | \`${project_ref}\` |
| Cold build | ${cold_seconds}s |
| Warm build #1 | ${warm1_seconds:-n/a}s |
| Warm build #2 | ${warm2_seconds:-n/a}s |
| Warm avg | ${warm_avg} |
| Warm vs cold | ${improvement_pct}% |
| Bytes uploaded | ${bytes_uploaded:-n/a} |
| Bytes downloaded | ${bytes_downloaded:-n/a} |
| Cache storage | ${cache_storage_mib} MiB (${cache_storage_bytes} bytes) |
| Storage source | ${cache_storage_source} |
| Hit behavior note | ${hit_behavior_note:-n/a} |
| Two warm runs succeeded | $([[ -n "$warm1_seconds" && -n "$warm2_seconds" ]] && echo "yes" || echo "no") |
MD

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "json_path=$json_path" >> "$GITHUB_OUTPUT"
  echo "md_path=$md_path" >> "$GITHUB_OUTPUT"
fi
