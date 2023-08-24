#!/bin/bash

__lazy_install gum

function k8_eks_choose_cluster {
  gum spin --show-output --spinner dot --title 'aws eks list is loading...' -- aws eks list-clusters --no-paginate --output text \
    | awk '{ print $2 }' \
    | gum choose --height=20 \
    | xargs aws eks --region eu-central-1 update-kubeconfig --name
}

function k8_kubectl_find {

    if [[ -z $1 ]]; then
      echo "missing argument"
    else
      kubectl get -A crds --no-headers --ignore-not-found 2>/dev/null | awk '{ print $1 }' |xargs -I{} /bin/bash -c "echo '> searching in {}' && kubectl get -A {} 2>/dev/null | grep $1"
      kubectl api-resources --verbs=list -o name 2>/dev/null | xargs -I{} -n 1 /bin/bash -c "echo '> searching in {}' && kubectl get {} --show-kind 2>/dev/null | grep $1"
    fi
}
