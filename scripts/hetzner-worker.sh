set -euo pipefail

series="${HETZNER_SERIES:-posthog-runners}"
name="bench-${series}"
alias_name=bench-hetzner
state_dir=/var/cache/boringcache/buildkit-state

configure() {
  dir="${RUNNER_TEMP:?}/hetzner-worker"
  mkdir -p "$dir" "$HOME/.ssh"
  chmod 700 "$dir" "$HOME/.ssh"
  printf '%s\n' "${HETZNER_SSH_KEY:?}" > "$dir/id_ed25519"
  chmod 600 "$dir/id_ed25519"
  echo "$alias_name ${HETZNER_HOST_KEY:?}" > "$dir/known_hosts"
  {
    echo "Host $alias_name"
    echo "  HostName ${HETZNER_HOST:?}"
    echo "  User root"
    echo "  IdentityFile $dir/id_ed25519"
    echo "  IdentitiesOnly yes"
    echo "  UserKnownHostsFile $dir/known_hosts"
    echo "  HostKeyAlias $alias_name"
    echo "  StrictHostKeyChecking yes"
  } >> "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  ssh -o BatchMode=yes -o ConnectTimeout=15 "$alias_name" true
}

connect() {
  configure
  ssh -o BatchMode=yes "$alias_name" "pkill -x buildkitd || true; rm -rf $state_dir /tmp/bc-buildkit-*; test ! -e $state_dir"
  ssh -o BatchMode=yes "$alias_name" 'lscpu | grep -E "^(Model name|CPU\(s\)):"; free -m | sed -n 2p; df -BG --output=size,avail / | tail -1' \
    | ruby -rjson -e '
      text = STDIN.read
      size, avail = text.lines.last.split.map { it.delete_suffix("G").to_i }
      machine = { "provider" => "hetzner", "server_type" => ENV.fetch("HETZNER_SERVER_TYPE", "ccx33"), "fresh_state" => true,
                  "cpu" => text[/^Model name:\s*(.+)$/, 1]&.strip, "cores" => text[/^CPU\(s\):\s*(\d+)/, 1]&.to_i,
                  "memory_mb" => text[/^Mem:\s+(\d+)/, 1]&.to_i, "disk_gb" => size, "disk_free_gb" => avail }.compact
      File.write(ARGV[0], JSON.generate(machine))
      puts JSON.pretty_generate(machine)
    ' "$dir/worker.json"
  if [ -n "${GITHUB_ENV:-}" ]; then echo "BENCH_REMOTE_MACHINE=$dir/worker.json" >> "$GITHUB_ENV"; fi
}

create() {
  keys="${HETZNER_KEY_DIR:-$HOME/.ssh/$name}"
  repo="${HETZNER_REPO:-boringcache/benchmarks}"
  mkdir -p "$keys"
  chmod 700 "$keys"
  ssh-keygen -q -t ed25519 -N '' -C "$name" -f "$keys/id_ed25519"
  ssh-keygen -q -t ed25519 -N '' -C "$name-host" -f "$keys/host_ed25519"
  {
    echo '#cloud-config'
    echo 'ssh_deletekeys: true'
    echo 'ssh_genkeytypes: []'
    echo 'ssh_keys:'
    echo '  ed25519_private: |'
    sed 's/^/    /' "$keys/host_ed25519"
    echo "  ed25519_public: $(cut -d' ' -f1,2 "$keys/host_ed25519.pub")"
  } > "$keys/user-data.yml"
  rm "$keys/host_ed25519"
  hcloud ssh-key create --name "$name" --public-key-from-file "$keys/id_ed25519.pub" \
    --label purpose=benchmark --label "benchmark=$series" > /dev/null
  hcloud server create --name "$name" --type "${HETZNER_SERVER_TYPE:-ccx33}" --image ubuntu-24.04 \
    --location "${HETZNER_LOCATION:-ash}" --ssh-key "$name" --user-data-from-file "$keys/user-data.yml" \
    --label purpose=benchmark --label "benchmark=$series" > /dev/null
  rm "$keys/user-data.yml"
  gh secret set HETZNER_SSH_KEY --repo "$repo" < "$keys/id_ed25519"
  hcloud server ip "$name" | gh secret set HETZNER_HOST --repo "$repo"
  cut -d' ' -f1,2 "$keys/host_ed25519.pub" | gh secret set HETZNER_HOST_KEY --repo "$repo"
}

delete() {
  for kind in server ssh-key; do
    for id in $(hcloud "$kind" list --selector "benchmark=$series" -o noheader -o columns=id); do
      hcloud "$kind" delete "$id"
    done
  done
}

case "${1:-}" in
  probe) configure ;;
  connect) connect ;;
  create) create ;;
  delete) delete ;;
  *) echo "usage: hetzner-worker.sh probe|connect|create|delete" >&2; exit 2 ;;
esac
