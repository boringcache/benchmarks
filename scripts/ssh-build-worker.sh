set -euo pipefail

operation="${1:?}"
provider="${2:?}"
alias_name="bench-$provider"
dir="${RUNNER_TEMP:?}/$provider-worker"
state_dir=/var/cache/boringcache/buildkit-state

mkdir -p "$dir" "$HOME/.ssh"
chmod 700 "$dir" "$HOME/.ssh"
printf '%s\n' "${SSH_WORKER_KEY:?}" > "$dir/id_ed25519"
chmod 600 "$dir/id_ed25519"
echo "$alias_name ${SSH_WORKER_HOST_KEY:?}" > "$dir/known_hosts"
{
  echo "Host $alias_name"
  echo "  HostName ${SSH_WORKER_HOST:?}"
  echo "  User root"
  echo "  IdentityFile $dir/id_ed25519"
  echo "  IdentitiesOnly yes"
  echo "  UserKnownHostsFile $dir/known_hosts"
  echo "  HostKeyAlias $alias_name"
  echo "  StrictHostKeyChecking yes"
} >> "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"

case "$operation" in
  connect)
    ssh -o BatchMode=yes -o ConnectTimeout=15 "$alias_name" "if pgrep -x 'boringcache|buildkitd' > /dev/null; then echo 'The SSH worker is running another build' >&2; exit 1; fi; rm -rf $state_dir /tmp/bc-buildkit-*; test ! -e $state_dir"
    ;;
  probe) ;;
  *) echo 'usage: ssh-build-worker.sh probe|connect provider' >&2; exit 2 ;;
esac

ssh -o BatchMode=yes -o ConnectTimeout=15 "$alias_name" 'LC_ALL=C lscpu | grep -E "^(Model name|CPU family|Model|CPU\(s\)):"; free -m | sed -n 2p; df -BG --output=size,avail / | tail -1' \
  | ruby -rjson -e '
    text = STDIN.read
    size, avail = text.lines.last.split.map { it.delete_suffix("G").to_i }
    machine = { "provider" => ARGV[1], "fresh_state" => ARGV[2] == "connect",
                "cpu" => text[/^Model name:\s*(.+)$/, 1]&.strip,
                "cpu_family" => text[/^CPU family:\s*(\d+)/, 1]&.to_i,
                "cpu_model_id" => text[/^Model:\s*(\d+)/, 1]&.to_i,
                "cores" => text[/^CPU\(s\):\s*(\d+)/, 1]&.to_i,
                "memory_mb" => text[/^Mem:\s+(\d+)/, 1]&.to_i, "disk_gb" => size, "disk_free_gb" => avail }.compact
    File.write(ARGV[0], JSON.generate(machine))
    puts JSON.pretty_generate(machine)
  ' "$dir/worker.json" "$provider" "$operation"

if [ -n "${GITHUB_ENV:-}" ]; then echo "BENCH_REMOTE_MACHINE=$dir/worker.json" >> "$GITHUB_ENV"; fi
