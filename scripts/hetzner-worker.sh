set -euo pipefail

series="${HETZNER_SERIES:-posthog-runners}"
name="bench-${series}"
alias_name=bench-hetzner

worker() {
  SSH_WORKER_KEY="${HETZNER_SSH_KEY:?}" SSH_WORKER_HOST="${HETZNER_HOST:?}" SSH_WORKER_HOST_KEY="${HETZNER_HOST_KEY:?}" \
    bash "$(dirname "$0")/ssh-build-worker.sh" "$1" hetzner
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
    echo 'ssh_genkeytypes: [ed25519]'
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
  echo "$alias_name $(cut -d' ' -f1,2 "$keys/host_ed25519.pub")" > "$keys/known_hosts"
  for _ in $(seq 60); do
    if laptop_ssh true 2> /dev/null; then break; fi
    sleep 5
  done
  rotate
  gh secret set HETZNER_SSH_KEY --repo "$repo" < "$keys/id_ed25519"
  hcloud server ip "$name" | gh secret set HETZNER_HOST --repo "$repo"
}

laptop_ssh() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 -o "HostName=$(hcloud server ip "$name")" -o User=root \
    -o "IdentityFile=$keys/id_ed25519" -o IdentitiesOnly=yes -o "UserKnownHostsFile=$keys/known_hosts" \
    -o "HostKeyAlias=$alias_name" -o StrictHostKeyChecking=yes "$alias_name" "$@"
}

rotate() {
  keys="${HETZNER_KEY_DIR:-$HOME/.ssh/$name}"
  repo="${HETZNER_REPO:-boringcache/benchmarks}"
  laptop_ssh '{ cloud-init status --wait > /dev/null; test $? -ne 1; } && rm -f /etc/ssh/ssh_host_* && ssh-keygen -q -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key && systemctl restart ssh && cut -d" " -f1,2 /etc/ssh/ssh_host_ed25519_key.pub' > "$keys/host_ed25519.pub.new"
  grep -q '^ssh-ed25519 ' "$keys/host_ed25519.pub.new"
  mv "$keys/host_ed25519.pub.new" "$keys/host_ed25519.pub"
  echo "$alias_name $(cat "$keys/host_ed25519.pub")" > "$keys/known_hosts"
  laptop_ssh true
  gh secret set HETZNER_HOST_KEY --repo "$repo" < "$keys/host_ed25519.pub"
}

delete() {
  for kind in server ssh-key; do
    for id in $(hcloud "$kind" list --selector "benchmark=$series" -o noheader -o columns=id); do
      hcloud "$kind" delete "$id"
    done
  done
}

case "${1:-}" in
  probe|connect) worker "$1" ;;
  create) create ;;
  rotate) rotate ;;
  delete) delete ;;
  *) echo "usage: hetzner-worker.sh probe|connect|create|rotate|delete" >&2; exit 2 ;;
esac
