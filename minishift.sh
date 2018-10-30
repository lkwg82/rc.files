#!/bin/bash

which minishift > /dev/null
if [ $? -eq 0 ]; then
    minishift completion bash > ~/.minishift-completion
    if [ ${platform} = "darwin" ]; then
        sed -e 's|__ltrim|#__ltrim|' -i '.bak' ~/.minishift-completion
    fi
    source ~/.minishift-completion
fi