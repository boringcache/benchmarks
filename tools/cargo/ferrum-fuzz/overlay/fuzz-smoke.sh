set -euo pipefail

verified="${BENCH_DIR:?}/fuzz-verified"
release="${CARGO_TARGET_DIR:?}/x86_64-unknown-linux-gnu/release"
rm -f "$verified"

cargo_step() {
  local restore=$1 save=$2
  shift 2
  if [ -z "${BENCH_BORINGCACHE:-}" ]; then
    cargo "$@"
    return
  fi
  local flags=(--target-scope "fuzz-smoke-${GITHUB_RUN_ID:-$$}-${GITHUB_RUN_ATTEMPT:-1}")
  [ "$restore" = restore ] || flags+=(--skip-restore)
  [ "$save" = save ] || flags+=(--skip-save)
  $BENCH_BORINGCACHE "${flags[@]}" "$@"
}

run_fuzz() {
  local target=$1 max_len=$2 save=$3
  cargo_step no-restore "$save" fuzz run --codegen-units 16 "$target" -- -runs=512 -max_total_time=8 -max_len="$max_len" -timeout=2 -rss_limit_mb=1024
  test -x "$release/$target"
  printf '%s\n' "$target" >> "$verified"
  rm -f -- "$release/$target" "$release/deps/$target-"*
  rm -rf -- "$release/build/ferrum-edge-fuzz"
}

CARGO_BUILD_JOBS=2 cargo_step restore no-save test --locked
for target in traceparent config_decode proxy_protocol mesh_udp_frame k8s_crd plugin_config; do
  run_fuzz "$target" 4096 no-save
done
for target in ocsp_response jwt_svid tls_material; do
  run_fuzz "$target" 65536 no-save
done
run_fuzz datagram_client_address 65536 save
