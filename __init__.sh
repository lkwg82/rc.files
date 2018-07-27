#!/bin/bash


source ~/.bashrc.d/bash.sh
source ~/.bashrc.d/gradle.sh
source ~/.bashrc.d/maven.sh

function linkFile {
  local file=$1
     
  if [ ! -f "$HOME/$file" ]; then
    echo "first time linked '$file'"
    ln -vfs ~/.bashrc.d/$file ~
  fi
}

linkFile .inputrc
linkFile .vimrc
