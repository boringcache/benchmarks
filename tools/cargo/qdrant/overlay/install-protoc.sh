#!/usr/bin/env bash
set -euo pipefail

version=34.1
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)
    platform=linux-x86_64
    checksum=af27ea66cd26938fe48587804ca7d4817457a08350021a1c6e23a27ccc8c6904
    ;;
  Linux-aarch64)
    platform=linux-aarch_64
    checksum=31c5e9e3c7bf013cf41fb97765ee255c140024a6b175b6cc9b64beddd7c23ba7
    ;;
  *)
    echo "Qdrant benchmark: no pinned protoc archive for $(uname -s)-$(uname -m)" >&2
    exit 1
    ;;
esac

archive=$(mktemp)
trap 'rm -f "$archive"' EXIT
curl -fsSL --retry 3 -o "$archive" "https://github.com/protocolbuffers/protobuf/releases/download/v${version}/protoc-${version}-${platform}.zip"
printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check
unzip -oq "$archive" -d overlay/protoc
