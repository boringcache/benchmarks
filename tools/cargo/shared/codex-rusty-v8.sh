set -euo pipefail

target=$1
version=$(cd upstream && python3 .github/scripts/rusty_v8_bazel.py resolved-v8-crate-version)
profile=ptrcomp_sandbox_release
base="https://github.com/openai/codex/releases/download/rusty-v8-v$version"
manifest="rusty_v8_${profile}_${target}.sha256"
trusted="$BENCH_DIR/upstream/third_party/v8/rusty_v8_${version//./_}_release_manifests.sha256"
mkdir -p v8
cd v8
curl -fsSL --retry 3 "$base/$manifest" -o "$manifest"
expected=$(grep -F "  $manifest" "$trusted" | cut -d ' ' -f 1)
test -n "$expected"
test "$(shasum -a 256 "$manifest" | cut -d ' ' -f 1)" = "$expected"
test "$(wc -l < "$manifest" | tr -d ' ')" -eq 2
for file in "librusty_v8_${profile}_${target}.a.gz" "src_binding_${profile}_${target}.rs"; do
  curl -fsSL --retry 3 "$base/$file" -o "$file"
done
tr -d '\r' < "$manifest" | shasum -a 256 --check --strict -
