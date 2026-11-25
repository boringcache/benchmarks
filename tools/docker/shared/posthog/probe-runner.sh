set -euo pipefail

gib=$((1024 * 1024 * 1024))
cgroup=$(bash "$BENCH_ROOT/scripts/linux-resources.sh" cgroup "$$")
if [[ $(uname -m) != x86_64 ]] ||
  ! awk -v cores="$(nproc)" '$(NF-2) == "cpu.max" && $(NF-1) != "max" && $NF > 0 && $(NF-1) / $NF < cores { cores = $(NF-1) / $NF } END { exit (cores < 8) }' <<< "$cgroup"; then
  echo "::error::PostHog Docker needs eight effective x86-64 CPUs on the trial runner."
  exit 1
fi
memory=$(awk '/^MemTotal:/ { print $2 * 1024 }' /proc/meminfo)
memory=$(printf 'memory.max %.0f\n' "$memory" |
  cat - <(printf '%s\n' "$cgroup") |
  awk '$(NF-1) == "memory.max" && $NF ~ /^[0-9]+$/ && (!minimum || $NF + 0 < minimum) { minimum = $NF + 0 } END { printf "%.0f\n", minimum }')
if (( memory < 30 * gib )); then
  echo "::error::PostHog Docker needs at least 30 GiB of effective RAM on the trial runner. Available bytes: $memory."
  exit 1
fi

docker_root=$(timeout --kill-after=2s 15s docker info --format '{{.DockerRootDir}}')
if [[ ! -d "$docker_root" ]]; then
  echo "::error::Cannot inspect local Docker scratch capacity at $docker_root."
  exit 1
fi
free=$(df -B1 --output=avail "$docker_root" | tail -1 | tr -d ' ')
if (( free < 120 * gib )); then
  echo "::error::PostHog Docker needs 120 GiB free on the Docker data filesystem at preflight. Available bytes: $free."
  exit 1
fi
