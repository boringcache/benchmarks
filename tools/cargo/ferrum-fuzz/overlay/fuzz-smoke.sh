set -euo pipefail

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

CARGO_BUILD_JOBS=2 cargo_step restore no-save test --locked
for target in traceparent config_decode proxy_protocol mesh_udp_frame k8s_crd plugin_config; do
  cargo_step no-restore no-save fuzz run --codegen-units 16 "$target" -- -runs=512 -max_total_time=8 -max_len=4096 -timeout=2 -rss_limit_mb=1024
done
for target in ocsp_response jwt_svid tls_material; do
  cargo_step no-restore no-save fuzz run --codegen-units 16 "$target" -- -runs=512 -max_total_time=8 -max_len=65536 -timeout=2 -rss_limit_mb=1024
done
cargo_step no-restore save fuzz run --codegen-units 16 datagram_client_address -- -runs=512 -max_total_time=8 -max_len=65536 -timeout=2 -rss_limit_mb=1024
