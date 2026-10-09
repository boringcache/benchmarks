#!/usr/bin/env bash
set -euo pipefail

lockfile="$1/pnpm-lock.yaml"
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) target=x86_64-unknown-linux-musl ;;
  Linux-aarch64) target=aarch64-unknown-linux-musl ;;
  *) echo "stage-vscode-ripgrep: no prebuilt ripgrep target for $(uname -sm)" >&2; exit 1 ;;
esac

for version in $(grep -oE "^  '@vscode/ripgrep@[0-9][0-9.]*'" "$lockfile" | grep -oE '[0-9]+(\.[0-9]+)+' | sort -u); do
  package="$(mktemp -d)"
  tarball="$(curl -fsSL --retry 3 "https://registry.npmjs.org/@vscode/ripgrep/$version" | grep -oE '"tarball":"[^"]+"' | cut -d'"' -f4)"
  curl -fsSL --retry 3 "$tarball" | tar -xz -C "$package"
  ripgrep="$(sed -nE "s/^const VERSION = '([^']+)'.*/\1/p" "$package/package/lib/postinstall.js")"
  cache="${TMPDIR:-/tmp}/vscode-ripgrep-cache-$version"
  asset="ripgrep-$ripgrep-$target.tar.gz"
  mkdir -p "$cache"
  curl -fsSL --retry 3 -o "$cache/$asset" "https://github.com/microsoft/ripgrep-prebuilt/releases/download/$ripgrep/$asset"
  tar -tzf "$cache/$asset" >/dev/null
  rm -rf "$package"
  echo "Staged $asset for @vscode/ripgrep $version"
done
