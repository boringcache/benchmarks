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

  entry_bytes="$(jq -r '
    def to_num:
      if type == "number" then .
      elif type == "string" then (try (capture("(?<n>[0-9]+)").n | tonumber) catch 0)
      else 0 end;

    def primary_sum:
      [
        .results[]? |
        (
          .compressed_size //
          .compressedSize //
          .size_bytes //
          .sizeBytes //
          .bytes //
          .size
        ) | to_num
      ] | add // 0;

    def fallback_sum:
      [
        paths(scalars) as $p
        | ($p[-1] | tostring) as $key
        | getpath($p) as $value
        | select($key | test("compressed.*size|size(_bytes)?|bytes"; "i"))
        | ($value | to_num)
      ] | add // 0;

    (primary_sum) as $primary
    | if $primary > 0 then $primary else fallback_sum end
    | floor
  ' "$tmp_file")"
  if [[ -z "$entry_bytes" ]]; then
    entry_bytes=0
  fi
  total=$((total + entry_bytes))
done

echo "$total"
