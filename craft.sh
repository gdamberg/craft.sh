#!/usr/bin/env bash
set -euo pipefail

readonly VERSION="0.0.1"
readonly SOURCE_REPO="https://github.com/gdamberg/craft.sh/"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/${SCRIPT_NAME}"
CONFIG_FILE="${CONFIG_DIR}/config"

### functions ###
dependency_check() {
  local missing_deps=0
  for cmd in "curl" "gum"; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      echo "Required command '${cmd}' not found." >&2
      missing_deps=1
    fi
  done
  if [[ ${missing_deps} -eq 1 ]]; then
      echo "Missing required dependencies. See ${SOURCE_REPO} for installation instructions."
      exit 1
  fi
}


### main ###
dependency_check
