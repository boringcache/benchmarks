#!/usr/bin/env bash
#
# check-helpers-aligned.sh
#
# Drift detector for shared helper scripts across benchmark repos.
#
# Compares the md5 of each canonical helper in benchmarks/scripts/canonical/
# against the same-named helper in every benchmark-* repo under
# benchmarks-repos/. Exits 0 if all repos match; exits non-zero with a
# per-repo summary if any drift exists.
#
# Designed to be runnable in CI as a periodic guard so the helpers
# cannot silently re-fork.
#
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
canonical_dir="$script_dir/canonical"
repos_dir_candidate="$script_dir/../../benchmark-repos"
if [[ ! -d "$repos_dir_candidate" ]]; then
  repos_dir_candidate="$script_dir/../../benchmarks-repos"
fi
repos_dir="$(cd "$repos_dir_candidate" && pwd)"

if [[ ! -d "$canonical_dir" ]]; then
  echo "Canonical directory missing: $canonical_dir" >&2
  exit 2
fi

if [[ ! -d "$repos_dir" ]]; then
  echo "Benchmark repos directory missing: $repos_dir" >&2
  exit 2
fi

helpers=()
while IFS= read -r path; do
  helpers+=("$(basename "$path")")
done < <(find "$canonical_dir" -maxdepth 1 -type f -name '*.sh' | sort)

if (( ${#helpers[@]} == 0 )); then
  echo "No canonical helpers found in $canonical_dir" >&2
  exit 2
fi

md5_of() {
  if command -v md5 >/dev/null 2>&1; then
    md5 -q "$1"
  else
    md5sum "$1" | awk '{print $1}'
  fi
}

drift_found=0
declare -a drift_lines=()

for helper in "${helpers[@]}"; do
  canonical_path="$canonical_dir/$helper"
  canonical_md5="$(md5_of "$canonical_path")"

  for repo in "$repos_dir"/benchmark-*; do
    [[ -d "$repo" ]] || continue
    repo_name="$(basename "$repo")"
    target_path="$repo/scripts/$helper"

    if [[ ! -f "$target_path" ]]; then
      drift_lines+=("$repo_name/$helper: MISSING (canonical=$canonical_md5)")
      drift_found=1
      continue
    fi

    target_md5="$(md5_of "$target_path")"
    if [[ "$target_md5" != "$canonical_md5" ]]; then
      drift_lines+=("$repo_name/$helper: drift (canonical=$canonical_md5 actual=$target_md5)")
      drift_found=1
    fi
  done
done

if (( drift_found == 0 )); then
  echo "All helpers aligned with canonical versions:"
  for helper in "${helpers[@]}"; do
    echo "  - $helper"
  done
  exit 0
fi

echo "Helper drift detected:" >&2
for line in "${drift_lines[@]}"; do
  echo "  $line" >&2
done
echo "" >&2
echo "Run scripts/sync-helpers.sh to copy canonical versions into each repo." >&2
exit 1
