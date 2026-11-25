#!/usr/bin/env bash
set -uo pipefail

cgroup() {
  local pid=$1 relative mount root dir field
  relative=$(awk -F: '$1 == 0 { print $3; exit }' "/proc/$pid/cgroup" 2>/dev/null) || return 0
  read -r mount root < <(findmnt -rn --first-only -t cgroup2 -o TARGET,FSROOT) || return 0
  case "$relative/" in
    "${root%/}/"*) dir="$mount/${relative#"${root%/}/"}" ;;
    *) return 0 ;;
  esac
  dir=${dir%/}
  while [[ -d "$dir" ]]; do
    for field in cpu.max cpuset.cpus.effective cpu.stat cpu.pressure memory.max memory.current memory.peak memory.events memory.swap.max memory.swap.current memory.pressure io.pressure; do
      if [[ -r "$dir/$field" ]]; then
        sed "s|^|cgroup pid=$pid path=${dir#"$mount"} $field |" "$dir/$field"
      fi
    done
    [[ "$dir" == "$mount" ]] && break
    dir=${dir%/*}
  done
}

mounts() {
  local path target
  for path in "$@"; do
    [[ -n "$path" ]] || continue
    target=$path
    while [[ ! -e "$target" && "$target" == */* ]]; do target=${target%/*}; done
    target=${target:-/}
    printf 'storage path=%s\n' "$path"
    findmnt -n -T "$target" -o TARGET,SOURCE,FSTYPE
    df -PT "$target"
  done
}

case "$1" in
  cgroup) cgroup "$2" ;;
  mounts) shift; mounts "$@" ;;
  docker)
    docker_root=$(timeout --kill-after=2s 5s docker info --format '{{.DockerRootDir}}') || exit
    if [[ -e "$docker_root" ]]; then mounts "$docker_root"; else printf 'Docker data path is outside the job mount namespace: %s\n' "$docker_root"; fi
    while read -r id; do
      [[ -n "$id" ]] || continue
      while read -r source; do
        if [[ -e "$source" ]]; then mounts "$source"; else printf 'BuildKit volume is outside the job mount namespace: %s\n' "$source"; fi
      done < <(timeout --kill-after=2s 5s docker inspect --format '{{range .Mounts}}{{println .Source}}{{end}}' "$id" | awk 'NF')
    done < <(timeout --kill-after=2s 5s docker ps -q --filter name=buildx_buildkit_)
    ;;
  *) exit 2 ;;
esac
