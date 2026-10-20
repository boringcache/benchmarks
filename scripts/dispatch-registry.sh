#!/usr/bin/env bash
set -euo pipefail

has_source=$(gh api "repos/$GITHUB_REPOSITORY/actions/runs/$RUN_ID/artifacts" --jq 'any(.artifacts[]; .name == "registry-source" and .expired == false)')
if [ "$has_source" != true ]; then
  exit 0
fi

state=$(gh api "repos/$GITHUB_REPOSITORY/actions/workflows/registry.yml" --jq '.state')
if [ "$state" != active ]; then
  echo "Registry transfers skipped: registry.yml is $state."
  exit 0
fi

gh workflow run registry.yml --ref main -f provider=all -f source_run="$RUN_ID"
