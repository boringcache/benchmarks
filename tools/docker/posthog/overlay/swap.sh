set -euo pipefail

swap_file="${RUNNER_TEMP:?}/posthog-benchmark.swap"
if swapon --show=NAME --noheadings | grep -Fx "$swap_file" > /dev/null; then
  exit 0
fi

sudo fallocate -l 4G "$swap_file"
sudo chmod 0600 "$swap_file"
sudo mkswap "$swap_file"
sudo swapon "$swap_file"
swapon --show
