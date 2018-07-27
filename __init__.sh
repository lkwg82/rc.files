#!/bin/bash


source ~/.bashrc.d/bash.sh
source ~/.bashrc.d/gradle.sh
source ~/.bashrc.d/maven.sh

if [ ! -f "$HOME/.inputrc" ]; then
  echo "first time linked .inputrc"
  ln -vfs ~/.bashrc.d/.inputrc ~
fi
