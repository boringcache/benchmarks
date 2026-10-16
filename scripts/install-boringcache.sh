#!/usr/bin/env bash
set -euo pipefail

version=$(sed -n 's/^boringcache = "\(.*\)"$/\1/p' versions.toml)
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) asset=boringcache-linux-amd64 ;;
  Linux-aarch64) asset=boringcache-linux-arm64 ;;
  *) echo "no BoringCache CLI asset for $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac
dir="$RUNNER_TEMP/boringcache-cli"
base="https://github.com/boringcache/cli/releases/download/v$version"
mkdir -p "$dir"
cd "$dir"
curl --fail --silent --show-error --location --retry 3 --remote-name-all "$base/SHA256SUMS" "$base/$asset"
grep " $asset\$" SHA256SUMS | sha256sum --check
install -m 0755 "$asset" "$dir/boringcache"
echo "$dir" >> "$GITHUB_PATH"
