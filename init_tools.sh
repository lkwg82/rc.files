#!/bin/bash

set -o pipefail

function initMacosX {
    ssh-add -K
}

if [ ${platform} = "darwin" ]; then
   which brew > /dev/null
   if [ $? -eq 1 ]; then
       echo "install brew -> https://brew.sh"
   fi
   initMacosX
fi

if [ ${platform} = "linux" ]; then
    export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
    which brew > /dev/null
    if [ $? -eq 1 ]; then
       echo "install brew -> https://linuxbrew.sh/"
   fi
fi

which brew > /dev/null
if [ $? -eq 0 ]; then
    for p in wget htop curl; do
        which ${p} > /dev/null || brew install ${p};
    done
fi
