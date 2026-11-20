set -euo pipefail

version=$(cd upstream && python3 .github/scripts/rusty_v8_bazel.py resolved-v8-crate-version)
checksums="$BENCH_DIR/upstream/third_party/v8/rusty_v8_${version//./_}.sha256"
mkdir -p v8
cd v8
for file in "${RUSTY_V8_ARCHIVE##*/}" "${RUSTY_V8_SRC_BINDING_PATH##*/}"; do
  curl -fsSL --retry 3 "https://github.com/openai/codex/releases/download/rusty-v8-v$version/$file" -o "$file"
  awk -v name="$file" '$2 == name' "$checksums" | sha256sum --check --strict -
done
