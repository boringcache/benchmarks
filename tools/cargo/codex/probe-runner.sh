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
ib_accel=/ib-workspace/incredibuild/ib-accel/bin
cd "$probe_dir"
{
  type -a cargo rustc ib_console || true
  printf 'sccache=%s\n' "$sccache"
  "$sccache" --version
  printf 'soft_nofile=%s\n' "$(ulimit -Sn)"
  ls -l "$ib_accel" 2>&1 || true
  file "$ib_accel/cargo" 2>&1 || true
  printf 'cargo shim names:\n'
  grep -aoE '\b(IB|INCREDIBUILD)_[A-Z0-9_]+' "$ib_accel/cargo" 2>/dev/null | sort -u || true
  printf 'environment names:\n'
  compgen -e | grep -E '^(IB|INCREDIBUILD|LD_PRELOAD)' || true
  printf 'ld.so.preload:\n'
  cat /etc/ld.so.preload 2>/dev/null || true
  printf 'cargo rustc-wrapper config:\n'
  grep -s -n 'rustc-wrapper' "$HOME/.cargo/config.toml" "$HOME/.cargo/config" || true
} > "$diagnostics/executables.txt"

mkdir src
printf '[package]\nname = "runner-probe"\nversion = "0.1.0"\nedition = "2024"\n' > Cargo.toml
printf 'version = 4\n\n[[package]]\nname = "runner-probe"\nversion = "0.1.0"\n' > Cargo.lock
printf 'fn main() {}\n' > src/main.rs

probe() (
  wrapper=$1 limit=$2 variant=${3:-}
  trial="$wrapper-$limit${variant:+-$variant}"
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
  if [[ "$variant" == clean ]]; then
    PATH=$(tr ':' '\n' <<< "$PATH" | grep -vxF "$ib_accel" | paste -sd: -)
    export PATH
    for name in $(compgen -e | grep -E '^(IB|INCREDIBUILD)_' || true); do unset "$name"; done
  fi
  if [[ "$variant" == console-skip-* ]]; then
    export IB_CONSOLE_SKIP=${variant#console-skip-}
  fi
  type -a cargo > "$diagnostics/$trial.cargo.txt" 2>&1 || true
  cargo --version > "$diagnostics/$trial.version.txt" 2>&1 || true
  if [[ "$variant" == server-first ]]; then
    "$sccache" --start-server > "$diagnostics/$trial.start.txt" 2>&1 || exit 1
  fi
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
  started=$SECONDS
  wait "$pid" || status=$?
  kill "$sampler" 2>/dev/null || true
  if [[ "$wrapper" == sccache ]]; then timeout --kill-after=2s 3s "$sccache" --stop-server >/dev/null 2>&1 || true; fi
  printf 'Cargo probe %s exited %s after %ss\n' "$trial" "$status" "$((SECONDS - started))" | tee -a "$diagnostics/outcomes.txt"
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
probe plain default clean || failed=1
probe sccache default clean || failed=1
probe sccache default server-first || failed=1
probe sccache default console-skip-1 || failed=1
probe sccache default console-skip-true || failed=1
exit "$failed"
