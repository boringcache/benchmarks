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

if ! boringcache check "$workspace" "$tags_csv" --no-git --json > "$tmp_file" 2>/dev/null; then
  echo "0"
  exit 0
fi

jq '[.results[] | (.compressed_size // .size // 0)] | add // 0' "$tmp_file"
