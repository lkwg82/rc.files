#!/bin/bash

if ! command -v terraform >/dev/null; then
  return
fi

if ! command -v tflint >/dev/null; then
  echo "installint tflint"
  brew install tflint
fi

# enable completion
complete -C "$(command -v terraform)" terraform

alias tf_apply='terraform apply -auto-approve'

function tf_plan {
  # shellcheck disable=SC2155
  local output=$(mktemp)
  terraform plan | tee "$output"
  echo ""
  echo ""
  echo " --- reformatting plan ---"
  echo ""
  echo ""
  grep -E "\~|\-|\+\s" "$output"
  echo "----- summary: ----";
  grep '  #' "$output"
}

function tf_workspace {
  local workspace="$1"

  if [[ -z $workspace ]]; then
    echo "missing workspace name"
    exit 1
  fi

  echo "... check workspaces"
  if ! terraform workspace list > /dev/null; then
    echo "... need to init"
    terraform init
  fi

  echo "... try to select workspace '$workspace'"
  if ! terraform workspace select "$workspace"; then
    echo "... need to create workspace '$workspace'"
    terraform workspace new "$workspace"
  fi
}

# this fixes the output of ansi colors
# see https://github.com/hashicorp/terraform/issues/21779
alias tf_state_show='terraform state show -no-color'
