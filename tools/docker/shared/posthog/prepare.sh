set -euo pipefail

mkdir -p overlay
cp upstream/Dockerfile overlay/PostHog.Dockerfile
git apply --no-index --directory=overlay "$(dirname "${BASH_SOURCE[0]}")/cache.patch"
