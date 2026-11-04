set -euo pipefail

binary=upstream/target/ci/nu
if [ -f "$binary.exe" ]; then binary="$binary.exe"; fi
"$binary" --version
test -z "$(git -C upstream status --porcelain=v1 --untracked-files=all)"
