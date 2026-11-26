set -euo pipefail

manifest=upstream/codex-rs/Cargo.toml
version="0.0.0-bench.g$(git -C upstream rev-parse --short=12 HEAD)"
grep -qx 'version = "0.0.0"' "$manifest"
perl -0pi -e 's/^\[workspace\.package\]\nversion = "0\.0\.0"$/[workspace.package]\nversion = "'"$version"'"/m' "$manifest"
grep -qx "version = \"$version\"" "$manifest"
printf '%s\n' "$version" > release-version
