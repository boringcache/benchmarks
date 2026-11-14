set -euo pipefail

overlay=$(cd "$(dirname "$0")" && pwd)

cargo_step() {
  local restore=$1 save=$2
  shift 2
  if [ -z "${BENCH_BORINGCACHE:-}" ]; then
    cargo --config .cargo/ci.toml "$@"
    return
  fi
  local flags=(--target-scope "nushell-ci-${GITHUB_RUN_ID:-$$}-${GITHUB_RUN_ATTEMPT:-1}")
  [ "$restore" = restore ] || flags+=(--skip-restore)
  [ "$save" = save ] || flags+=(--skip-save)
  $BENCH_BORINGCACHE "${flags[@]}" -- --config .cargo/ci.toml "$@"
}

cargo_step restore no-save build --workspace --all-targets --profile ci
cargo_step no-restore no-save test --workspace --all-targets --profile ci
mkdir -p ../out
for binary in target/ci/nu target/ci/nu.exe; do
  [ ! -f "$binary" ] || cp "$binary" ../out/
done
ruby "$overlay/prune.rb" target/ci
cargo_step no-restore save test --workspace --doc --profile ci
