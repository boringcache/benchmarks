#!/usr/bin/env bash
#
# sync-helpers.sh
#
# Copies canonical helper scripts from benchmarks/scripts/canonical/
# into every active benchmark checkout under the
# configured repository directory.
#
# Usage:
#   ./sync-helpers.sh                # dry-run; shows planned copies
#   ./sync-helpers.sh --apply        # actually write the files
#   ./sync-helpers.sh --apply --only benchmark-hugo,benchmark-zed
#                                    # restrict to listed repos
#   ./sync-helpers.sh --apply --helper assert-boringcache-docker-product-run.sh
#                                    # sync one canonical helper
#
# Exits 0 on success. The drift detector
# (check-helpers-aligned.sh) should be re-run after a sync to confirm
# alignment.
#
set -euo pipefail

apply=0
only=""
helper_filter=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      apply=1
      shift
      ;;
    --only)
      only="$2"
      shift 2
      ;;
    --helper)
      helper_filter="$2"
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
repo_candidates=("$repos_dir"/benchmark-*)

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

mode_label="dry-run"
if (( apply == 1 )); then
  mode_label="apply"
fi

echo "Syncing canonical helpers (mode=$mode_label)"
echo "  canonical: $canonical_dir"
echo "  repos:     $repos_dir"
echo ""

planned=0
written=0
skipped_unchanged=0
missing_target_dir=0

for helper in "${helpers[@]}"; do
  canonical_path="$canonical_dir/$helper"
  for repo in "${repo_candidates[@]}"; do
    [[ -d "$repo" ]] || continue
    repo_name="$(basename "$repo")"

    if ! selected_repo "$repo_name"; then
      continue
    fi
    helper_applies_to_repo "$helper" "$repo_name" || continue

    target_dir="$repo/scripts"
    target_path="$target_dir/$helper"

    if [[ ! -d "$target_dir" ]]; then
      echo "  skip $repo_name/$helper (no scripts/ directory)"
      missing_target_dir=$((missing_target_dir + 1))
      continue
    fi

    if [[ -f "$target_path" ]] && cmp -s "$canonical_path" "$target_path"; then
      skipped_unchanged=$((skipped_unchanged + 1))
      continue
    fi

    planned=$((planned + 1))
    echo "  plan $repo_name/$helper"

    if (( apply == 1 )); then
      cp "$canonical_path" "$target_path"
      chmod +x "$target_path"
      written=$((written + 1))
    fi
  done
done

echo ""
echo "Summary:"
echo "  planned changes:    $planned"
echo "  written:            $written"
echo "  unchanged (skipped): $skipped_unchanged"
echo "  missing scripts/:   $missing_target_dir"

if (( apply == 0 )) && (( planned > 0 )); then
  echo ""
  echo "Dry-run only. Re-run with --apply to write files."
fi
