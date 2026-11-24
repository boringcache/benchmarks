set -euo pipefail

cp "$BENCH_ROOT/tools/cargo/codex/mise.toml" mise.toml
mise trust
mise install
rustup toolchain install 1.99.1 --profile minimal
export RUSTUP_TOOLCHAIN=1.99.1
command -v cargo rustc sccache

mkdir -p src
printf '[package]\nname = "runner-probe"\nversion = "0.1.0"\nedition = "2024"\n' > Cargo.toml
printf 'version = 4\n\n[[package]]\nname = "runner-probe"\nversion = "0.1.0"\n' > Cargo.lock
printf 'fn main() {}\n' > src/main.rs

probe() (
  trial=$1
  if [ "$trial" != default ]; then ulimit -S -n 10000; fi
  if [ "$trial" = without-sccache ]; then export RUSTC_WRAPPER=""; fi
  export CARGO_TARGET_DIR="$PWD/target-$trial"
  printf 'Cargo probe %s (open-file limit %s)\n' "$trial" "$(ulimit -Sn)"
  timeout --kill-after=5s 45s cargo test --locked --offline --no-run
)

default_status=0
probe default || default_status=$?
timeout --kill-after=5s 5s sccache --stop-server >/dev/null 2>&1 || true
limited_status=0
probe limited || limited_status=$?
printf 'Cargo probe exit status default=%s limited=%s\n' "$default_status" "$limited_status"
if [ "$limited_status" -ne 0 ]; then
  timeout --kill-after=5s 5s sccache --stop-server >/dev/null 2>&1 || true
  probe without-sccache
fi
exit "$limited_status"
