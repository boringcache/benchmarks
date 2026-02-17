#!/usr/bin/env bash
set -euo pipefail

key_fragment="${1:-}"
repo="${GITHUB_REPOSITORY:-}"

if [[ -z "$key_fragment" || -z "$repo" ]]; then
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

while true; do
  response="$(gh api "/repos/${repo}/actions/caches?per_page=100&page=${page}" 2>/dev/null || true)"
  if [[ -z "$response" ]]; then
    break
  fi

  page_sum="$(jq --arg frag "$key_fragment" '[.actions_caches[] | select(.key | contains($frag)) | .size_in_bytes] | add // 0' <<< "$response")"
  total=$((total + page_sum))

  count="$(jq '.actions_caches | length' <<< "$response")"
  if [[ "$count" -lt 100 ]]; then
    break
  fi
  page=$((page + 1))
done

echo "$total"
