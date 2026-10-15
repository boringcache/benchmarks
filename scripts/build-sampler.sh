#!/usr/bin/env bash
set -u

out=$1
interval=${2:-5}

while :; do
  {
    echo "=== $(date -u +%FT%T.%3NZ)"
    head -1 /proc/stat
    for kind in cpu memory io; do
      if [ -r "/proc/pressure/$kind" ]; then sed "s/^/psi.$kind /" "/proc/pressure/$kind"; fi
    done
    grep -E '^(MemTotal|MemAvailable|Cached|Dirty|SwapTotal|SwapFree):' /proc/meminfo | tr -s ' ' | tr '\n' ' '
    echo
    ps -eo pid=,ppid=,etimes=,times=,rss=,stat=,comm=,wchan= | awk '$7 ~ /^(boringcache|sccache|cargo|rustc|clang|cc|c\+\+|cmake|make|ninja|git|ld|ld\.lld|lld|mold|build-script-)/'
  } >> "$out"
  sleep "$interval"
done
