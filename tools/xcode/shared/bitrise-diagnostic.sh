#!/bin/bash
set -euo pipefail

out="$RUNNER_TEMP/bitrise-diagnostic"
mkdir -p "$out"
git clone https://github.com/obsproject/obs-studio.git "$RUNNER_TEMP/bitrise-obs"
cd "$RUNNER_TEMP/bitrise-obs"
git checkout --detach a8b04ac5e15115591d8a184701e1670fb5dc00af
git submodule update --init --recursive
bitrise-build-cache --no-update-check activate xcode --cache --cache-push=false

set +e
.github/scripts/build-macos --config RelWithDebInfo --target macos-arm64 > "$out/initial.log" 2>&1
printf 'initial: %s\n' "$?" | tee "$out/status.txt"
set -e

cd build_macos
for variant in default no-prefix no-integrated no-detached no-builtin-prefix no-modules no-remote no-plugin; do
  args=(build)
  case "$variant" in
    no-prefix) args+=(--no-prefix-map) ;;
    no-integrated) args+=(COMPILATION_CACHE_ENABLE_INTEGRATED_QUERIES=NO) ;;
    no-detached) args+=(COMPILATION_CACHE_ENABLE_DETACHED_KEY_QUERIES=NO) ;;
    no-builtin-prefix) args+=(CLANG_ENABLE_PREFIX_MAPPING=NO) ;;
    no-modules) args+=(CLANG_ENABLE_MODULES=NO) ;;
    no-remote) args+=(COMPILATION_CACHE_REMOTE_SERVICE_PATH=) ;;
    no-plugin) args+=(COMPILATION_CACHE_ENABLE_PLUGIN=NO) ;;
  esac
  /usr/bin/xcodebuild -project obs-studio.xcodeproj -target obsglad -configuration RelWithDebInfo clean > "$out/clean-$variant.log" 2>&1
  set +e
  bitrise-build-cache xcelerate xcodebuild --no-xcresult -project obs-studio.xcodeproj -target obsglad -configuration RelWithDebInfo "COMPILATION_CACHE_CAS_PATH=$RUNNER_TEMP/cas-$variant" "${args[@]}" > "$out/$variant.log" 2>&1
  printf '%s: %s\n' "$variant" "$?" | tee -a "$out/status.txt"
  set -e
done

cp "$HOME"/.local/state/xcelerate/logs/xcelerate-*.log "$out/"
python3 - "$out" <<'PY'
import os
import pathlib
import sys

for path in pathlib.Path(sys.argv[1]).glob('*.log'):
    text = path.read_text(errors='replace')
    for name in ('BITRISE_BUILD_CACHE_AUTH_TOKEN', 'BITRISE_BUILD_CACHE_WORKSPACE_ID'):
        value = os.environ.get(name)
        if value:
            text = text.replace(value, '[REDACTED]')
    path.write_text(text)
PY
