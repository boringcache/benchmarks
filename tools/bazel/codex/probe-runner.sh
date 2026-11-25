set -euo pipefail

command -v bwrap >/dev/null || {
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends bubblewrap
}
if [[ $(id -u) == 0 ]] ||
  ! timeout --kill-after=2s 10s unshare --user --map-root-user --mount --pid --fork /bin/true ||
  ! timeout --kill-after=2s 10s bwrap --unshare-user --unshare-pid --ro-bind / / /bin/true; then
  echo "::error::Codex Bazel needs unprivileged user, mount and PID namespaces on this runner."
  exit 1
fi
mkdir -p "$1"
bash "$BENCH_ROOT/tools/bazel/codex/storage.sh" check "$1"
