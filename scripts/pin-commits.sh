#!/usr/bin/env bash
# Pin all benchmark workflows to the latest commit of each target repo.
# Usage: ./scripts/pin-commits.sh

set -euo pipefail

repo_pairs=(
  "posthog PostHog/posthog"
  "mastodon mastodon/mastodon"
  "grpc grpc/grpc"
  "kafka apache/kafka"
  "zed zed-industries/zed"
  "bevy bevyengine/bevy"
  "discourse discourse/discourse"
  "n8n n8n-io/n8n"
  "calcom calcom/cal.com"
  "immich immich-app/immich"
)

for pair in "${repo_pairs[@]}"; do
  name="${pair%% *}"
  repo="${pair#* }"
  sha=$(gh api "repos/$repo/commits?per_page=1" --jq '.[0].sha' 2>/dev/null || true)
  if [ -z "$sha" ]; then
    echo "$name ($repo): FAILED to fetch commit"
    continue
  fi

  echo "$name ($repo): $sha"
  matched=0
  for f in .github/workflows/${name}*.yml; do
    [ -f "$f" ] || continue
    matched=1
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/PROJECT_REF: \".*\"/PROJECT_REF: \"$sha\"/" "$f"
    else
      sed -i "s/PROJECT_REF: \".*\"/PROJECT_REF: \"$sha\"/" "$f"
    fi
    echo "  Updated: $f"
  done

  if [ "$matched" -eq 0 ]; then
    echo "  No workflow files matched .github/workflows/${name}*.yml"
  fi
done

echo ""
echo "Done. Review changes with: git diff .github/workflows/"
