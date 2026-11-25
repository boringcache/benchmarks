#!/usr/bin/env bash
set -euo pipefail

run=$1
source_sha=$2
[[ "$run" =~ ^[1-9][0-9]{0,18}$ ]]

gh run view "$run" --repo "$GITHUB_REPOSITORY" --json conclusion,displayTitle,event,headBranch,workflowName |
  jq -e --arg branch "$GITHUB_REF_NAME" '
    .conclusion == "success" and .event == "workflow_dispatch"
    and .headBranch == $branch and .workflowName == "Project benchmark"
    and (.displayTitle | endswith("[cold auto]"))' > /dev/null

scope="boringcache-cargo-plus-mounted-github-$run"
tag="mounted-zed-$scope"
results="results-cargo-zed-$scope-cold-1"
diagnostics="diagnostics-cargo-zed-$scope-cold-1"
seed=$(mktemp -d)
trap 'rm -rf "$seed"' EXIT
gh run download "$run" --repo "$GITHUB_REPOSITORY" --name "$results" --name "$diagnostics" --dir "$seed" >&2

jq -e --arg sha "$source_sha" --arg scope "$scope" --arg candidate "$CANDIDATE_CLI_ARTIFACT" '
  .case == "zed" and .sha == $sha and .lane == "boringcache-cargo-plus-mounted"
  and .runner == "github" and .phase == "cold" and .cache_scope == $scope
  and .exit_status == 0 and .output_ok == true and .versions.boringcache_release == $candidate
' "$seed/$results/cargo/zed/$scope/boringcache-cargo-plus-mounted-github-cold.json" > /dev/null

root=$(jq -er --arg tag "$tag" '
  select(.published == true) | .entries[0]
  | select(.tag == $tag and .error_count == 0)
  | .archive_mount
  | select(.initial_root == null and .child_exit_code == 0)
  | .final_root | select(test("^sha256:[0-9a-f]{64}$"))
' "$seed/$diagnostics/archive-mount.json")

jq -e --arg root "$root" --arg tag "$tag" '
  .entries[0] | select(.tag == $tag and .error_count == 0)
  | .archive_mount
  | .read_only == true and .child_exit_code == 0 and .chunk_download_bytes > 0
    and .initial_root == $root and .final_root == $root
' "$seed/$diagnostics/archive-reopen.json" > /dev/null
printf '%s\n' "$root"
