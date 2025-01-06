#!/bin/bash

set -o pipefail

function initMacosX() {
  ssh-add --apple-use-keychain
}

# shellcheck disable=SC2154
if [[ ${platform} == "darwin" ]]; then
  if [[ ${architecture} == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  if ! command -v brew >/dev/null; then
    echo "install brew -> https://brew.sh/"
    echo "skipping further init ... needs brew"
    return
  fi
  initMacosX
fi

if [[ ${platform} == "linux" ]]; then
  export PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

  if ! command -v brew >/dev/null; then
    echo "install brew -> https://brew.sh/"
    echo "skipping further init ... needs brew"
    return
  fi
fi

# shellcheck disable=SC2155
export BREW_PREFIX=$(brew --prefix)

alias _info='echo -n "🐛"; echo'
function __lazy_install() {
  local cmd=$1

  if [[ -n ${DEBUG_LAZY_INSTALL:-} ]]; then
    _info "check '${cmd}' installed?"
  fi

  if ! command -v "$cmd" >/dev/null; then
    if [[ -n ${DEBUG_LAZY_INSTALL:-} ]]; then
      _info " '${cmd}' missing 🔜 installed"
    fi
    echo "installing '$cmd'"
    brew install "$cmd"
  fi
  if [[ -n ${DEBUG_LAZY_INSTALL:-} ]]; then
    _info " '${cmd}' installed ✅ "
  fi
}

__lazy_install wget
__lazy_install htop
__lazy_install curl
