set -euo pipefail

if [[ ${RUNNER_ENVIRONMENT:-} != github-hosted ]]; then exit 0; fi

storage="$BENCH_DIR/.bazel"
mkdir -p "$storage"
command -v mkfs.btrfs >/dev/null || sudo apt-get install -y --no-install-recommends btrfs-progs
available=$(df -B1 --output=avail "$RUNNER_TEMP" | tail -1)
size=$((available - 16 * 1024 * 1024 * 1024))
(( size > 0 ))
image=$(mktemp "$RUNNER_TEMP/bazel-storage.XXXXXXXX")
truncate -s "$size" "$image"
mkfs.btrfs --quiet --nodiscard "$image"
sudo mount -o loop,noatime,compress=zstd:1 "$image" "$storage"
sudo chown "$(id -u):$(id -g)" "$storage"
printf '%s\n' \
  "startup --output_user_root=$storage/build" \
  "common --repository_cache=$storage/repository-cache" \
  "common --repo_contents_cache=$storage/repo-contents" >> "$BENCH_DIR/bench.bazelrc"
df -hT "$storage" "$RUNNER_TEMP"
