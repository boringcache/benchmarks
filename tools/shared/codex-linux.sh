set -euo pipefail

df -h "$BENCH_DIR"
if [[ ${RUNNER_ENVIRONMENT:-} == github-hosted ]]; then
  sudo rm -rf /usr/local/lib/android /usr/share/dotnet /opt/ghc /opt/hostedtoolcache/CodeQL
fi
df -h "$BENCH_DIR"

archive=dotslash-ubuntu-22.04.x86_64.v0.5.9.tar.gz
curl -fsSL --retry 3 "https://github.com/meta/dotslash/releases/download/v0.5.9/$archive" -o "$archive"
echo "ba6b6908c69db8264efdb8ee32f4906284ea3b77247c611339b5f60160cc5691  $archive" | sha256sum --check
tar xzf "$archive" dotslash
sudo install -m 0755 dotslash /usr/local/bin/dotslash
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends bubblewrap libcap-dev
if [[ -f /proc/sys/kernel/apparmor_restrict_unprivileged_userns && ${RUNNER_ENVIRONMENT:-} == github-hosted ]]; then
  sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
fi
