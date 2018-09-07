#!/bin/bash

set -o pipefail

function initMacosX {
    for p in wget htop curl; do
        which ${p} > /dev/null || brew install ${p};
    done
    ssh-add -K
}

if [ ${platform} = "darwin" ]; then
   initMacosX
fi


