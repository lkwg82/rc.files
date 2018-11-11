#!/bin/bash

# minishift

which minishift > /dev/null
if [ $? -eq 0 ]; then
    minishift completion bash > ~/.minishift-completion
    if [ ${platform} = "darwin" ]; then
        sed -e 's|__ltrim|#__ltrim|' -i '.bak' ~/.minishift-completion
    fi
    source ~/.minishift-completion

    function minishift_init {
        eval $(minishift docker-env)
        eval $(minishift oc-env)
        docker login -u developer -p `oc whoami -t` docker-registry-default.$(minishift ip).nip.io
    }

    function minishift_start {
        minishift start --vm-driver virtualbox --memory "4GB" --cpus 4
        minishift_init
    }
fi

# openshift client
which oc > /dev/null
if [ $? -eq 0 ]; then
    oc completion bash > ~/.openshift-client-completion
    source ~/.openshift-client-completion
fi