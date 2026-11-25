set -euo pipefail

gib=$((1024 * 1024 * 1024))
reserve=$((120 * gib))

free_bytes() {
  df -B1 --output=avail "$1" | tail -1 | tr -d ' '
}

case "${1:-prepare}" in
  check)
    available=$(free_bytes "$2")
    if (( available < 128 * gib )); then
      echo "::error::Codex Bazel needs 128 GiB free on the trial workspace at preflight. Available bytes: $available."
      exit 1
    fi
    exit
    ;;
  read-cache)
    storage="$BENCH_DIR/.bazel"
    available=$(free_bytes "$storage")
    budget=$((available - reserve))
    if (( budget <= 0 )); then
      echo "::error::Codex Bazel needs more than 120 GiB free before starting the BoringCache build. Available bytes: $available."
      exit 1
    fi
    if (( budget > 8 * gib )); then budget=$((8 * gib)); fi
    {
      printf 'BORINGCACHE_BLOB_READ_CACHE_DIR=%s\n' "$storage/boringcache-read-cache"
      printf 'BORINGCACHE_BLOB_READ_CACHE_MAX_BYTES=%s\n' "$budget"
    } >> "$GITHUB_ENV"
    printf 'Bazel workspace has %s free bytes, with a blob read cache budget of %s bytes.\n' "$available" "$budget"
    exit
    ;;
esac

storage="$BENCH_DIR/.bazel"
mkdir -p "$storage"

if [[ ${RUNNER_ENVIRONMENT:-} == github-hosted ]]; then
  command -v mkfs.btrfs >/dev/null || sudo apt-get install -y --no-install-recommends btrfs-progs
  available=$(free_bytes "$RUNNER_TEMP")
  size=$((available - 16 * gib))
  (( size > 0 ))
  image=$(mktemp "$RUNNER_TEMP/bazel-storage.XXXXXXXX")
  truncate -s "$size" "$image"
  mkfs.btrfs --quiet --nodiscard "$image"
  sudo mount -o loop,noatime,compress=zstd:1 "$image" "$storage"
  sudo chown "$(id -u):$(id -g)" "$storage"
  printf 'BENCH_BAZEL_IMAGE=%s\n' "$image" >> "$GITHUB_ENV"
fi

printf '%s\n' \
  "startup --output_user_root=$storage/build" \
  "common --repository_cache=$storage/repository-cache" \
  "common --repo_contents_cache=$storage/repo-contents" >> "$BENCH_DIR/bench.bazelrc"
df -hT "$storage" "$RUNNER_TEMP"
