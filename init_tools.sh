#!/bin/bash

set -o pipefail

function initMacosX {
    ssh-add -K
}

if [ "${platform}" = "darwin" ]; then
   if ! command -v  brew > /dev/null; then
       echo "install brew -> https://brew.sh"
   fi
   initMacosX
fi

if [ ${platform} = "linux" ]; then
    export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
    if ! command -v  brew > /dev/null; then
       echo "install brew -> https://linuxbrew.sh/"
   fi
fi

if ! command -v  brew > /dev/null; then
    for p in wget htop curl; do
        command -v  ${p} > /dev/null || brew install ${p};
    done
fi
