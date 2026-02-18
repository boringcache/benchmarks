#!/usr/bin/env bash
set -euo pipefail

workspace="${1:-}"
tags_csv="${2:-}"

if [[ -z "$workspace" || -z "$tags_csv" ]]; then
  echo "0"
  exit 0
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

total=0
IFS=',' read -r -a raw_tags <<< "$tags_csv"

for tag in "${raw_tags[@]}"; do
  clean_tag="$(echo "$tag" | xargs)"
  if [[ -z "$clean_tag" ]]; then
    continue
  fi

  if ! boringcache check "$workspace" "$clean_tag" --no-git --json > "$tmp_file" 2>/dev/null; then
    continue
  fi

  entry_bytes="$(jq '[.results[] | (.compressed_size // .size // 0)] | add // 0' "$tmp_file")"
  total=$((total + entry_bytes))
done

echo "$total"
