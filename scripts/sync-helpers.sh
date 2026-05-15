#!/usr/bin/env bash
#
# sync-helpers.sh
#
# Copies canonical helper scripts from benchmarks/scripts/canonical/
# into every benchmark-*/scripts/ directory under benchmarks-repos/.
#
# Usage:
#   ./sync-helpers.sh                # dry-run; shows planned copies
#   ./sync-helpers.sh --apply        # actually write the files
#   ./sync-helpers.sh --apply --only benchmark-hugo,benchmark-zed
#                                    # restrict to listed repos
#
# Exits 0 on success. The drift detector
# (check-helpers-aligned.sh) should be re-run after a sync to confirm
# alignment.
#
set -euo pipefail

apply=0
only=""

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
repos_dir="$(cd "$script_dir/../../benchmarks-repos" && pwd)"

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
  for repo in "$repos_dir"/benchmark-*; do
    [[ -d "$repo" ]] || continue
    repo_name="$(basename "$repo")"

    if ! selected_repo "$repo_name"; then
      continue
    fi

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
