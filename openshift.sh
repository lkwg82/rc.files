#!/bin/bash

# minishift

which minishift > /dev/null
if [ $? -eq 0 ]; then
    minishift completion bash > ~/.minishift-completion
    if [ ${platform} = "darwin" ]; then
        sed -e 's|__ltrim|#__ltrim|' -i '.bak' ~/.minishift-completion
    fi
    source ~/.minishift-completion
fi

# openshift client
which oc > /dev/null
if [ $? -eq 0 ]; then
    oc completion bash > ~/.openshift-client-completion
    source ~/.openshift-client-completion
fi