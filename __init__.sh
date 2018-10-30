#!/bin/bash

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='darwin'
fi

source ~/.bashrc.d/init_tools.sh
source ~/.bashrc.d/bash.sh
source ~/.bashrc.d/gradle.sh
source ~/.bashrc.d/git.sh
source ~/.bashrc.d/maven.sh
source ~/.bashrc.d/minishift.sh

function linkFile {
  local file=$1
     
  if [ ! -f "$HOME/$file" ]; then
    echo "first time linked '$file'"
    ln -vfs ~/.bashrc.d/$file ~
  fi
}

linkFile .inputrc
linkFile .vimrc
