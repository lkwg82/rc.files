#!/bin/bash

if [[ -n $CI ]]; then
  env | sort
  set -x # for debugging in github actions
fi

# shellcheck disable=SC2034
architecture=$(uname -m)
platform='unknown'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  # shellcheck disable=SC2034
  platform='darwin'
fi

function exitAndShow() {
  echo "failed to pushd ... exiting"
  read -r -p
  exit 1
}

pushd ~/.bashrc.d > /dev/null || exitAndShow

# shellcheck disable=SC1091
source init_tools.sh

for file in tools/*.sh; do
  # shellcheck disable=SC1090
  source "$file"
done

set +o errexit # deactivate exit on error
set +o xtrace  # deactivate tracing

# shellcheck disable=SC2164
popd > /dev/null

function linkFile() {
  local file=$1

  if [ ! -f "$HOME/$file" ]; then
    echo "first time linked '$file'"
    ln -vfs "$HOME/.bashrc.d/$file" ~
  fi
}

linkFile .inputrc
linkFile .vimrc
