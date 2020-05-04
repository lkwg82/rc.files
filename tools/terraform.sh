#!/bin/bash

if ! command -v terraform >/dev/null; then
  return
fi

if ! command -v tflint >/dev/null; then
  echo "installint tflint"
  brew install tflint
fi

# enable completion
complete -C $(command -v terraform) terraform

alias tf_apply='terraform apply -auto-approve'

# this fixes the output of ansi colors
# see https://github.com/hashicorp/terraform/issues/21779
alias tf_state_show='terraform state show -no-color'
