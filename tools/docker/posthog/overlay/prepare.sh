set -euo pipefail

cp upstream/Dockerfile overlay/PostHog.Dockerfile
git apply --no-index --directory=overlay overlay/cache.patch
