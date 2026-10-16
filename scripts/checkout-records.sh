#!/usr/bin/env bash
set -euo pipefail

path=${1:-results}
git fetch --quiet --depth=1 origin main
rm -rf results
git cat-file -e "FETCH_HEAD:$path" 2>/dev/null || exit 0
blobs=$(git ls-tree -r FETCH_HEAD -- "$path" | awk -F '\t' '$2 ~ /\.json$/ { split($1, entry, " "); print entry[3] }')
[ -n "$blobs" ] || exit 0
printf '%s\n' "$blobs" | git -c fetch.negotiationAlgorithm=noop fetch --quiet --no-tags --no-write-fetch-head --recurse-submodules=no --filter=blob:none --stdin origin
git checkout --ignore-skip-worktree-bits FETCH_HEAD -- ":(glob)$path/**/*.json"
