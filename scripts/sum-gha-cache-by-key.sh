#!/usr/bin/env bash
set -euo pipefail

key_prefix="${1:-}"
created_after="${2:-}"
repo="${GITHUB_REPOSITORY:-}"

if [[ -z "$key_prefix" || -z "$repo" ]]; then
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

total=0
page=1
key_encoded="$(jq -nr --arg v "$key_prefix" '$v|@uri')"

while true; do
  response="$(gh api "/repos/${repo}/actions/caches?per_page=100&page=${page}&key=${key_encoded}" 2>/dev/null || true)"
  if [[ -z "$response" ]]; then
    break
  fi
  if ! jq -e '.actions_caches | type == "array"' <<< "$response" >/dev/null 2>&1; then
    break
  fi

  if [[ -n "$created_after" ]]; then
    page_sum="$(
      jq --arg ts "$created_after" '
        [
          .actions_caches[]
          | select(
              ((.created_at | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) >= ($ts | fromdateiso8601))
            )
          | .size_in_bytes
        ]
        | add // 0
      ' <<< "$response"
    )"
  else
    page_sum="$(jq '[.actions_caches[] | .size_in_bytes] | add // 0' <<< "$response")"
  fi
  total=$((total + page_sum))

  count="$(jq '.actions_caches | length' <<< "$response")"
  if [[ "$count" -lt 100 ]]; then
    break
  fi
  page=$((page + 1))
done

echo "$total"
