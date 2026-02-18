#!/usr/bin/env bash
set -euo pipefail

benchmark_or_prefix="${1:-}"
window_started_at="${2:-}"
window_ended_at="${3:-}"
repo="${GITHUB_REPOSITORY:-}"

if [[ -z "$benchmark_or_prefix" || -z "$repo" ]]; then
  echo "0"
  exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "0"
  exit 0
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "0"
  exit 0
fi

if [[ "$benchmark_or_prefix" == index-* ]]; then
  index_prefix="$benchmark_or_prefix"
else
  index_prefix="index-${benchmark_or_prefix}"
fi

if [[ -z "$window_ended_at" ]]; then
  window_ended_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
fi

sum_for_query() {
  local key_filter="$1"
  local jq_filter="$2"

  local total=0
  local page=1
  local key_encoded
  key_encoded="$(jq -nr --arg v "$key_filter" '$v|@uri')"

  while true; do
    local response
    response="$(gh api "/repos/${repo}/actions/caches?per_page=100&page=${page}&key=${key_encoded}" 2>/dev/null || true)"
    if [[ -z "$response" ]]; then
      break
    fi
    if ! jq -e '.actions_caches | type == "array"' <<<"$response" >/dev/null 2>&1; then
      break
    fi

    local page_sum
    page_sum="$(
      jq -r \
        --arg since "${window_started_at}" \
        --arg until "${window_ended_at}" \
        "$jq_filter" <<<"$response"
    )"

    if [[ -n "$page_sum" && "$page_sum" =~ ^[0-9]+$ ]]; then
      total=$((total + page_sum))
    fi

    local count
    count="$(jq '.actions_caches | length' <<<"$response")"
    if [[ "$count" -lt 100 ]]; then
      break
    fi
    page=$((page + 1))
  done

  echo "$total"
}

timestamp_filter='
  def parse_ts($v):
    if ($v // "") == "" then 0
    else (($v | sub("\\.[0-9]+Z$"; "Z")) | fromdateiso8601)
    end;
  def in_window($ts):
    if ($since // "") == "" then true
    else (parse_ts($ts) >= parse_ts($since))
    end and (parse_ts($ts) <= parse_ts($until));
'

index_sum="$(
  sum_for_query \
    "${index_prefix}" \
    "${timestamp_filter}
    [
      .actions_caches[]
      | select(.key | startswith(\"${index_prefix}\"))
      | select(in_window(.last_accessed_at))
      | .size_in_bytes
    ] | add // 0
    "
)"

# BuildKit layer blobs do not include benchmark ids in keys. Use last_accessed_at
# time window as the best available per-run approximation.
blob_sum="0"
if [[ -n "$window_started_at" ]]; then
  blob_sum="$(
    sum_for_query \
      "buildkit-blob-" \
      "${timestamp_filter}
      [
        .actions_caches[]
        | select(.key | startswith(\"buildkit-blob-\"))
        | select(in_window(.last_accessed_at))
        | .size_in_bytes
      ] | add // 0
      "
  )"
fi

if [[ ! "$index_sum" =~ ^[0-9]+$ ]]; then
  index_sum=0
fi
if [[ ! "$blob_sum" =~ ^[0-9]+$ ]]; then
  blob_sum=0
fi

echo $((index_sum + blob_sum))
