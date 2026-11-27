set -euo pipefail

temp="${RUNNER_TEMP:?}"
if [[ ${1:-} == preflight ]]; then
  swap_file=$(mktemp "$temp/bench-swap-check.XXXXXXXX")
  size=16M
else
  swap_file="$temp/bench-docker.swap"
  size=4G
fi

if swapon --show=NAME --noheadings | grep -Fx "$swap_file" > /dev/null; then
  exit 0
fi

if ! sudo fallocate -l "$size" "$swap_file" ||
  ! sudo chmod 0600 "$swap_file" ||
  ! sudo mkswap "$swap_file" ||
  ! sudo swapon "$swap_file"; then
  sudo rm -f -- "$swap_file"
  exit 1
fi

if [[ ${1:-} == preflight ]]; then
  sudo swapoff "$swap_file"
  sudo rm -f -- "$swap_file"
else
  swapon --show
fi
