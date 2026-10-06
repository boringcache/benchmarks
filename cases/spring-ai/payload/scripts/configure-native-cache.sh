#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == actions-cache ]]; then
  echo "MAVEN_OPTS=-Dmaven.build.cache.enabled=true -Dmaven.build.cache.remote.enabled=false -Dmaven.build.cache.location=${GITHUB_WORKSPACE}/.maven-build-cache" >> "$GITHUB_ENV"
fi
