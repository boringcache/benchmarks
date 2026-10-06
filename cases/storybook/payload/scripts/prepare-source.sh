#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scenario="${1:-base}"

git -C "${repo_root}/upstream" reset --hard
git -C "${repo_root}/upstream" clean -fdx

nx_json="${repo_root}/upstream/nx.json"
if [[ -f "${nx_json}" ]]; then
  (cd "${repo_root}" && ruby scripts/configure-nx-cache.rb)
fi

case "${scenario}" in
  base|warm1)
    ;;
  *)
    echo "Unknown scenario: ${scenario}" >&2
    exit 1
    ;;
esac

git -C "${repo_root}/upstream" status --short
