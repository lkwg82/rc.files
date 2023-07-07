#!/bin/bash

__lazy_install gum

function k8_eks_choose_cluster {
  gum spin --show-output --spinner dot --title 'aws eks list is loading...' -- aws eks list-clusters --no-paginate --output text \
    | awk '{ print $2 }' \
    | gum choose --height=20 \
    | xargs aws eks --region eu-central-1 update-kubeconfig --name
}
