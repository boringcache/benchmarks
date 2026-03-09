#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF' >&2
Usage: collect-bazel-remote-diagnostics.sh \
  --output-dir DIR \
  --phase PHASE \
  --cache-tag TAG \
  --remote-url URL \
  --container-name NAME \
  [--cache-root PATH] \
  [--cache-label LABEL]
EOF
  exit 1
}

output_dir=""
phase=""
cache_tag=""
remote_url=""
container_name=""
cache_root=""
cache_label=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      output_dir="${2:-}"
      shift 2
      ;;
    --phase)
      phase="${2:-}"
      shift 2
      ;;
    --cache-tag)
      cache_tag="${2:-}"
      shift 2
      ;;
    --remote-url)
      remote_url="${2:-}"
      shift 2
      ;;
    --container-name)
      container_name="${2:-}"
      shift 2
      ;;
    --cache-root)
      cache_root="${2:-}"
      shift 2
      ;;
    --cache-label)
      cache_label="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

if [[ -z "$output_dir" || -z "$phase" || -z "$cache_tag" || -z "$remote_url" || -z "$container_name" ]]; then
  usage
fi

if [[ -n "$cache_root" && -z "$cache_label" ]]; then
  cache_label="cache"
fi

mkdir -p "$output_dir"

{
  echo "run_id=${GITHUB_RUN_ID:-}"
  echo "run_attempt=${GITHUB_RUN_ATTEMPT:-}"
  echo "job=${GITHUB_JOB:-}"
  echo "phase=${phase}"
  echo "cache_tag=${cache_tag}"
  echo "remote_url=${remote_url}"
  echo "container_name=${container_name}"
  date -u +"timestamp=%Y-%m-%dT%H:%M:%SZ"
  echo "--- uname ---"
  uname -a
} > "${output_dir}/metadata.txt"

if [[ -f "$HOME/.bazelrc" ]]; then
  cp "$HOME/.bazelrc" "${output_dir}/bazelrc.txt"
fi

if [[ -n "$cache_root" && -d "$cache_root" ]]; then
  du -sh "$cache_root" > "${output_dir}/${cache_label}-size.txt" || true
  find "$cache_root" -maxdepth 3 -mindepth 1 -type d \
    | head -n 200 > "${output_dir}/${cache_label}-tree.txt" || true
fi

curl -fsSL "${remote_url}/status" > "${output_dir}/bazel-remote-status.json" || true
docker logs "$container_name" > "${output_dir}/bazel-remote.log" 2>&1 || true
