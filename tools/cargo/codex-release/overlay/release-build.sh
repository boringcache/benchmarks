set -euo pipefail

STABLE_GIT_COMMIT="$(git rev-parse HEAD)"
export STABLE_GIT_COMMIT
args=(build --target aarch64-apple-darwin --release --timings --bin codex --bin codex-code-mode-host --bin codex-exec-server --bin codex-responses-api-proxy)
if [ -n "${BENCH_BORINGCACHE:-}" ]; then
  $BENCH_BORINGCACHE "${args[@]}"
else
  cargo "${args[@]}"
fi
