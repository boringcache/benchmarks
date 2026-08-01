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
# Usage:
#   ./check-helpers-aligned.sh
#   ./check-helpers-aligned.sh --helper assert-boringcache-docker-product-run.sh
#   ./check-helpers-aligned.sh --helper assert-boringcache-docker-product-run.sh --only benchmark-hugo,benchmark-posthog
#
set -euo pipefail

helper_filter=""
only=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --helper)
      helper_filter="$2"
      shift 2
      ;;
    --only)
      only="$2"
      shift 2
      ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
canonical_dir="$script_dir/canonical"
helper_scopes_path="$canonical_dir/helper-scopes.tsv"
repos_dir_candidate="${BENCHMARK_REPOS_DIR:-$script_dir/../../benchmark-repos}"
if [[ -z "${BENCHMARK_REPOS_DIR:-}" && ! -d "$repos_dir_candidate" ]]; then
  repos_dir_candidate="$script_dir/../../benchmarks-repos"
fi
repos_dir="$(cd "$repos_dir_candidate" && pwd)"
repo_candidates=("$repos_dir"/benchmark-* "$repos_dir"/docker-cache-proofs)
if [[ -z "${BENCHMARK_REPOS_DIR:-}" ]]; then
  repo_candidates+=("$repos_dir"/../docker-cache-proofs)
fi

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

if [[ -n "$helper_filter" ]]; then
  helper_found=0
  selected_helpers=()
  for helper in "${helpers[@]}"; do
    if [[ "$helper" == "$helper_filter" ]]; then
      selected_helpers+=("$helper")
      helper_found=1
    fi
  done
  (( helper_found == 1 )) || { echo "Unknown canonical helper: $helper_filter" >&2; exit 2; }
  helpers=("${selected_helpers[@]}")
fi

if (( ${#helpers[@]} == 0 )); then
  echo "No canonical helpers found in $canonical_dir" >&2
  exit 2
fi

only_parts=()
if [[ -n "$only" ]]; then
  IFS=',' read -ra only_parts <<< "$only"
fi

selected_repo() {
  local repo_name="$1"
  local selected

  if (( ${#only_parts[@]} == 0 )); then
    return 0
  fi

  for selected in "${only_parts[@]}"; do
    if [[ "$repo_name" == "$selected" ]]; then
      return 0
    fi
  done

  return 1
}

helper_applies_to_repo() {
  local helper="$1"
  local repo_name="$2"
  local scope=""
  local scoped_repo
  local -a scoped_repos=()

  if [[ -f "$helper_scopes_path" ]]; then
    scope="$(awk -F '\t' -v helper="$helper" '$1 == helper { print $2; exit }' "$helper_scopes_path")"
  fi
  [[ -z "$scope" ]] && return 0

  IFS=',' read -ra scoped_repos <<< "$scope"
  for scoped_repo in "${scoped_repos[@]}"; do
    [[ "$repo_name" == "$scoped_repo" ]] && return 0
  done

  return 1
}

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

  for repo in "${repo_candidates[@]}"; do
    [[ -d "$repo" ]] || continue
    repo_name="$(basename "$repo")"
    selected_repo "$repo_name" || continue
    helper_applies_to_repo "$helper" "$repo_name" || continue
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
