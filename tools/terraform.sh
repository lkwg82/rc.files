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
    return
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

  terraform init # since terraform v0.13
}

function tf_pin_provider_versions {

local versions="versions.tf"
  if [[ -f $versions ]]; then
    echo "WARN file '$versions' already existing ... skip"
    return
  fi

cat <<EOF > $versions.tmp
terraform {
  required_providers {
EOF

  for url in $(terraform providers \
    | grep registry.terraform \
    | sed -e 's#.*provider\[\(.*\)\].*#\1#' \
    | sort -u \
    | sed -e 's#\(registry.terraform.io\)/\(.*\)#https://\1/v1/providers/\2/versions#' ); do
    provider=$(echo -n "$url" | sed -e 's#.*/providers/##; s#/versions##')
    latestVersion=$(curl "$url" | jq  -r '.versions[] | .version' | sort | tail -n1)

    echo "$url"
    echo "provider $provider"
    echo "version: $latestVersion"

    cat <<EOF >> $versions.tmp
    $(echo -n "$provider" | cut -d/ -f2) = {
      source  = "$provider"
      version = "$latestVersion"
    }
EOF
  done

cat <<EOF >> $versions.tmp
   }
}
EOF
  mv -v $versions.tmp $versions
}

# this fixes the output of ansi colors
# see https://github.com/hashicorp/terraform/issues/21779
alias tf_state_show='terraform state show -no-color'
