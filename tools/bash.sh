#!/bin/bash

set -o pipefail

export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # big big history
export HISTFILESIZE=100000              # big big history
shopt -s histappend                     # append to history, don't overwrite it

# create temp dir and cd
alias cdtmp='dir="$(mktemp -d)" && cd $dir'

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# create dir and cd
function cdmkdir() {
  local dir=$1 || echo "ERROR missing argument"
  # shellcheck disable=SC2164
  mkdir -p "${dir}" && cd "${dir}"
}

# personal binaries in $HOME
export PATH=~/bin:$PATH
# locally installed binary of npm
export PATH=node_modules/.bin:$PATH

# https://github.com/jbarlow83/OCRmyPDF
# https://medium.com/@thucnc/convert-a-scanned-pdf-to-text-with-linux-command-line-using-ocrmypdf-1a2e8d50277f
alias docker_ocrmypdf='docker run --rm  -i --user "$(id -u):$(id -g)" --workdir /data -v "$PWD:/data" jbarlow83/ocrmypdf'


if ! command -v exa >/dev/null; then
  brew install exa
fi

alias ls='exa -al'
alias ll='exa -alhg'

if ! command -v bat >/dev/null; then
  brew install bat
fi

alias cat='bat'
