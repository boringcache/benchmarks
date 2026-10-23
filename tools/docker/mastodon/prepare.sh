set -euo pipefail

sed 's/^COPY Gemfile\* /COPY .ruby-version Gemfile* /' upstream/Dockerfile > overlay/mastodon-ccache.Dockerfile
git apply --no-index --directory=overlay overlay/cache.patch
