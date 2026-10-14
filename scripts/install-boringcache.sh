#!/bin/bash
set -euo pipefail

if [ -z "$VERSION" ]; then VERSION="v$(bundle exec ruby -rtoml-rb -e 'puts TomlRB.load_file("versions.toml").fetch("boringcache")')"; fi
if [ -n "$CLI_RELEASE" ]; then echo "BENCH_CLI_RELEASE=$CLI_RELEASE" >> "$GITHUB_ENV"; fi
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) assets=(boringcache-linux-amd64) ;;
  Linux-aarch64) assets=(boringcache-linux-arm64) ;;
  Darwin-*) assets=(boringcache-macos-universal libboringcache_xcode_cas-macos-universal.dylib) ;;
esac
dir="$RUNNER_TEMP/boringcache-cli"
base="https://github.com/boringcache/cli/releases/download/$VERSION"
mkdir -p "$dir"
cd "$dir"
curl --fail --silent --show-error --location --retry 3 --remote-name-all "$base/SHA256SUMS" "${assets[@]/#/$base/}"
for asset in "${assets[@]}"; do grep " $asset\$" SHA256SUMS; done | shasum -a 256 --check
install -m 0755 "${assets[0]}" "$dir/boringcache"
if [ "${#assets[@]}" -gt 1 ]; then install -m 0644 "${assets[1]}" "$dir/libboringcache_xcode_cas.dylib"; fi
echo "$dir" >> "$GITHUB_PATH"
