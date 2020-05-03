#!/bin/bash

platform='unknown'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
   platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
   # shellcheck disable=SC2034
   platform='darwin'
fi

function exitAndShow {
  echo "failed to pushd ... exiting"
  read -p "exiting"
  exit 1
}

pushd ~/.bashrc.d || exitAndShow

source init_tools.sh

for file in tools/*.sh; do
  source "$file"
done
set +x

# shellcheck disable=SC2164
popd

function linkFile {
  local file=$1

  if [ ! -f "$HOME/$file" ]; then
    echo "first time linked '$file'"
    ln -vfs "$HOME/.bashrc.d/$file" ~
  fi
}

linkFile .inputrc
linkFile .vimrc

