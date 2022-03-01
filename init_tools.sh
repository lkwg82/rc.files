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

if command -v brew >/dev/null; then
  for p in wget htop curl; do
    command -v ${p} >/dev/null || brew install ${p}
  done
fi
