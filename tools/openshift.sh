#!/bin/bash

# minishift

if command -v minishift >/dev/null; then
  minishift completion bash >~/.minishift-completion
  # shellcheck disable=SC2154
  if [[ ${platform} == "darwin" ]]; then
    sed -e 's|__ltrim|#__ltrim|' -i '.bak' ~/.minishift-completion
  fi
  # shellcheck disable=SC1090
  source ~/.minishift-completion

  function minishift_init() {
    eval "$(minishift docker-env)"
    eval "$(minishift oc-env)"
    docker login -u developer -p "$(oc whoami -t)" docker-registry-default."$(minishift ip)".nip.io
  }

  function minishift_start() {
    minishift start --vm-driver virtualbox --memory "4GB" --cpus 4
    minishift addons enable registry-route
    minishift_init
  }
fi

# openshift client
if command -v oc >/dev/null; then
  oc completion bash >~/.openshift-client-completion
  # shellcheck disable=SC1090
  source ~/.openshift-client-completion
fi
