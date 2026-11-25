set -euo pipefail

mode=$1
diagnostics="$RUNNER_TEMP/diagnostics/cargo-probe"
mkdir -p "$diagnostics"
probe_dir=$(mktemp -d /tmp/bench-cargo.XXXXXXXX)
trap 'rm -rf "$probe_dir"' EXIT

if [[ "$mode" == preflight ]]; then
  cd "$probe_dir"
  cp "$BENCH_ROOT/tools/cargo/codex/mise.toml" mise.toml
  mise trust
  mise install
  rustup toolchain install 1.99.1 --profile minimal
  export RUSTUP_TOOLCHAIN=1.99.1
else
  RUSTUP_TOOLCHAIN=$(rustup show active-toolchain | awk 'NR == 1 { print $1 }')
  export RUSTUP_TOOLCHAIN
fi

sccache=$(mise which sccache)
cd "$probe_dir"
{
  type -a cargo rustc ib_console || true
  printf 'sccache=%s\n' "$sccache"
  "$sccache" --version
  printf 'soft_nofile=%s\n' "$(ulimit -Sn)"
} > "$diagnostics/executables.txt"

mkdir src
printf '[package]\nname = "runner-probe"\nversion = "0.1.0"\nedition = "2024"\n' > Cargo.toml
printf 'version = 4\n\n[[package]]\nname = "runner-probe"\nversion = "0.1.0"\n' > Cargo.lock
printf 'fn main() {}\n' > src/main.rs

probe() (
  wrapper=$1 limit=$2
  trial="$wrapper-$limit"
  if [[ "$limit" == limited ]]; then
    ulimit -Sn 10000 || exit 1
  fi
  unset SCCACHE_GHA_ENABLED SCCACHE_GHA_VERSION SCCACHE_MULTILEVEL_CHAIN
  export SCCACHE_DIR="$probe_dir/cache-$trial"
  export SCCACHE_SERVER_UDS="$probe_dir/$trial.sock"
  export SCCACHE_IDLE_TIMEOUT=15
  export SCCACHE_LOG=debug SCCACHE_ERROR_LOG="$diagnostics/$trial.sccache.log"
  export RUSTC_WRAPPER="" RUSTC_WORKSPACE_WRAPPER=""
  export CARGO_INCREMENTAL=0 CARGO_BUILD_INCREMENTAL=false
  if [[ "$wrapper" == sccache ]]; then export RUSTC_WRAPPER="$sccache"; fi
  export CARGO_TARGET_DIR="$probe_dir/target-$trial"
  timeout --kill-after=5s 60s cargo test --locked --offline --no-run &
  pid=$!
  (
    while kill -0 "$pid" 2>/dev/null; do
      ps -eo pid=,ppid=,stat=,comm=,wchan= | awk '$4 ~ /^(cargo|rustc|sccache|ib_console|timeout)$/'
      sleep 5
    done
  ) > "$diagnostics/$trial.processes.log" &
  sampler=$!
  status=0
  wait "$pid" || status=$?
  kill "$sampler" 2>/dev/null || true
  if [[ "$wrapper" == sccache ]]; then timeout --kill-after=2s 3s "$sccache" --stop-server >/dev/null 2>&1 || true; fi
  printf 'Cargo probe %s exited %s\n' "$trial" "$status" | tee -a "$diagnostics/outcomes.txt"
  exit "$status"
)

if [[ "$mode" != preflight ]]; then
  probe sccache default
  exit
fi

failed=0
for limit in default limited; do
  for wrapper in plain sccache; do
    probe "$wrapper" "$limit" || failed=1
  done
done
exit "$failed"
