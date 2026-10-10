#!/usr/bin/env zsh

builtin emulate -L zsh
setopt EXTENDED_GLOB
setopt PUSHD_SILENT
setopt ERR_EXIT
setopt ERR_RETURN
setopt NO_UNSET
setopt PIPE_FAIL
setopt NO_AUTO_PUSHD
setopt NO_PUSHD_IGNORE_DUPS

setup() {
  local project_root=${1:A}
  local target=${2}
  local host_os=${target%%-*}
  local -i debug=0
  local SCRIPT_HOME=${project_root}/.github/scripts

  fpath=(${SCRIPT_HOME}/utils.zsh ${fpath})
  autoload -Uz log_group log_error log_output check_${host_os}

  check_${host_os}

  if [[ ${host_os} == ubuntu ]] {
    autoload -Uz setup_ubuntu
    setup_ubuntu
  }
}

setup ${@}
