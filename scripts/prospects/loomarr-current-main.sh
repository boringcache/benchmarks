#!/usr/bin/env bash
set -euo pipefail

evidence="$RUNNER_TEMP/prospect-evidence"
mkdir -p "$evidence"
test "$(git rev-parse HEAD)" = "$SOURCE_SHA"
git merge-base --is-ancestor "$UPSTREAM_SHA" HEAD
git diff "$UPSTREAM_SHA" -- .github/workflows/ci-android.yml .github/workflows/android-beta.yml \
  scripts/build-android-beta.sh scripts/sign-android-ci-artifact.sh \
  scripts/download-android-ci-artifact.sh web/scripts/verify-shield-aab.sh > "$evidence/release-contract.diff"
test ! -s "$evidence/release-contract.diff"
git diff "$UPSTREAM_SHA" > "$evidence/fork.diff"

{
  git rev-parse HEAD
  node --version
  pnpm --version
  java -version
  uname -a
  lscpu
  free -h
  df -h
  printf 'image=%s image_version=%s\n' "${ImageOS:-unknown}" "${ImageVersion:-unknown}"
  printf 'native_workers=%s gradle_workers=1 heap=1280m\n' "$LOOMARR_ANDROID_NATIVE_JOBS"
} > "$evidence/runner.txt" 2>&1

if [[ "$PROVIDER" != baseline ]]; then
  export CMAKE_C_COMPILER_LAUNCHER=ccache CMAKE_CXX_COMPILER_LAUNCHER=ccache
  export CCACHE_COMPILERCHECK=content CCACHE_SLOPPINESS=''
  ccache --zero-stats
  ccache --show-config > "$evidence/ccache-config.txt"
  ccache --print-stats > "$evidence/ccache-before.txt"
fi

measure="$GITHUB_WORKSPACE/harness/scripts/prospects/measure-command.py"
command=(python3 "$measure" make-android -- /usr/bin/time -v -o "$evidence/make-resource-usage.txt" make android)
if [[ "$PROVIDER" == boringcache ]]; then
  # Unique per seed and its warm trials; historical entries cannot satisfy a cold run.
  export LOOMARR_ANDROID_GRADLE_CACHE=boringcache
  write_mode=--write
  if [[ "$PHASE" != cold ]]; then
    export LOOMARR_ANDROID_GRADLE_CACHE=boringcache-restore
    write_mode=--read-only
  fi
  python3 - <<'PY'
import os
from pathlib import Path
scope = os.environ['CACHE_SCOPE']
Path('.boringcache.toml').write_text(f'''workspace = "boringcache/benchmarks"
[proxy]
metadata-hints = ["project=loomarr", "experiment=current-main"]
[adapters.gradle]
tag = "{scope}-gradle"
fail-on-cache-error = true
[adapters.ccache]
tag = "{scope}-ccache"
fail-on-cache-error = true
''')
PY
  command=(boringcache ci run --oidc-provider github-actions -- boringcache ccache "$write_mode" --fail-on-cache-error -- "${command[@]}")
fi

vmstat -t 1 > "$evidence/vmstat.txt" &
memory_pid=$!
trap 'kill "$memory_pid" 2>/dev/null || true' EXIT
set +e
python3 "$measure" cache-and-build -- "${command[@]}"
build_status=$?
set -e
kill "$memory_pid" 2>/dev/null || true
wait "$memory_pid" 2>/dev/null || true
trap - EXIT

if [[ "$PROVIDER" != baseline ]]; then
  ccache --show-stats --verbose > "$evidence/ccache-stats.txt"
  ccache --print-stats > "$evidence/ccache-after.txt"
fi
exit "$build_status"
