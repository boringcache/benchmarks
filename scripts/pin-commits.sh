#!/usr/bin/env bash
# Pin all benchmark workflows to the latest commit of each target repo.
# Usage: ./scripts/pin-commits.sh

set -euo pipefail

declare -A REPOS=(
  [posthog]="PostHog/posthog"
  [mastodon]="mastodon/mastodon"
  [grpc]="grpc/grpc"
  [kafka]="apache/kafka"
  [zed]="zed-industries/zed"
  [bevy]="bevyengine/bevy"
  [discourse]="discourse/discourse"
  [n8n]="n8n-io/n8n"
  [calcom]="calcom/cal.com"
  [immich]="immich-app/immich"
)

for name in "${!REPOS[@]}"; do
  repo="${REPOS[$name]}"
  sha=$(gh api "repos/$repo/commits?per_page=1" --jq '.[0].sha' 2>/dev/null)
  if [ -n "$sha" ]; then
    echo "$name ($repo): $sha"
    # Update all workflow files for this project
    for f in .github/workflows/${name}*.yml; do
      if [ -f "$f" ]; then
        # macOS/Linux compatible sed
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i '' "s/PROJECT_REF: \".*\"/PROJECT_REF: \"$sha\"/" "$f"
        else
          sed -i "s/PROJECT_REF: \".*\"/PROJECT_REF: \"$sha\"/" "$f"
        fi
        echo "  Updated: $f"
      fi
    done
  else
    echo "$name ($repo): FAILED to fetch commit"
  fi
done

echo ""
echo "Done. Review changes with: git diff .github/workflows/"
