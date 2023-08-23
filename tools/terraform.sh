#!/bin/bash

if command -v tfenv >/dev/null; then
  echo "deinstall tfenv"
  brew remove tfenv
fi

if ! command -v terraform >/dev/null; then
  echo "install terraform"
  brew install terraform
fi

if ! command -v tflint >/dev/null; then
  echo "install tflint"
  brew install tflint
fi

# see https://developer.hashicorp.com/terraform/cli/config/config-file#provider-plugin-cache
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p "$TF_PLUGIN_CACHE_DIR"

# enable completion
complete -C "$(command -v terraform)" terraform

alias tf_apply='terraform apply -auto-approve'
alias tf_destroy='terraform destroy'
alias tf_init='terraform init'
alias tf_import='terraform import'
alias tf_output='terraform output'
alias tf_providers='terraform providers'

# this fixes the output of ansi colors
# see https://github.com/hashicorp/terraform/issues/21779
alias tf_state_show='terraform state show -no-color'
alias tf_state_ls='terraform state list'
alias tf_state_mv='terraform state mv'
alias tf_state_rm='terraform state rm'
alias tf_validate='terraform validate'

function tf_pin_provider_versions {

  local versions="versions.tf"
  if [[ -f $versions ]]; then
    echo "WARN file '$versions' already existing ... skip"
    return
  fi

  # just check we did not fail later on
  if ! terraform providers > /dev/null; then
    echo "cannot pin versions"
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

  terraform init -upgrade
}

function tf_plan {
  # shellcheck disable=SC2155
  local output=$(mktemp)

  if ! terraform validate; then
    echo "stopped on error"
    return
  fi

  if ! terraform plan -out "$output.plan" $* | tee "$output"; then
    echo "error"
    return
  fi


  echo "... transforming into json ..."
  terraform show -json "$output.plan" > "$output.json"


  jq < "$output.json" '.resource_changes[] | select(.change.actions[] == "create") | .address' -r | sort > "$output.create"
  # shellcheck disable=SC1083
  if [[ $(wc -l "$output".create | awk {'print $1'} ) -gt 0 ]]; then
    printf "\e[92m\e[1mElements to be created .\e[0m\n"
    sed -e 's#^#+ #' "$output.create"
  fi

  jq < "$output.json" '.resource_changes[] | select(.change.actions[] == "delete") | .address' -r | sort > "$output.delete"
  # shellcheck disable=SC1083
  if [[ $(wc -l "$output".delete | awk {'print $1'} ) -gt 0 ]]; then
    printf "\e[91m\e[1mElements to be deleted (or recreated).\e[0m\n"
    sed -e 's#^#- #'  "$output.delete"
  fi

  jq < "$output.json" '.resource_changes[] | select(.change.actions[] == "update") | .address' -r | sort > "$output.update"
  # shellcheck disable=SC1083
  if [[ $(wc -l "$output".update | awk {'print $1'} ) -gt 0 ]]; then
    printf "\e[93m\e[1mElements to be updated .\e[0m\n"
    sed -e 's#^# #'  "$output.update"
  fi
}

function tf_update_latest_terraform_version {
  # shellcheck disable=SC2155
  local lastVersion=$(tfenv list-remote | grep -E "\.[0-9]+$" | head -n1)
  tfenv install "$lastVersion"
  tfenv use "$lastVersion"
}

function tf_workspace {
  local workspace="$1"

  if [[ -z $workspace ]]; then
    terraform workspace list
    return
  fi

  # suppress verbose outputs
  if [[ -z $TF_IN_AUTOMATION ]]; then
    export TF_IN_AUTOMATION="true"
  fi

  if [[ $(terraform workspace show) == "$workspace" ]]; then
    echo "already on '$workspace'"
    return
  fi

  echo " try to select workspace '$workspace' ... "
  if terraform workspace select "$workspace" 2>/dev/null; then
    echo -n ""
  else
    read -r -p "Want to create new workspace? (y/n) : " -n 1
    echo
    if [[ $REPLY != "y" ]]; then
      echo "skipping"
      return
    fi
    if ! terraform workspace new "$workspace"; then
      echo "failed"
    fi
  fi

  terraform init -upgrade # since terraform v0.13
}

function tf___clean_empty_workspaces {
  # shellcheck disable=SC2155
  local currentWorkspace=$(terraform workspace show)

  for w in $(terraform workspace list | grep -vE "$currentWorkspace$" | grep -v default); do
    if [[ $w == "$currentWorkspace" ]]; then
      echo "skipping current workspace"
      continue
    fi

    echo "checking '$w' ... "
    terraform workspace select "$w"
    # shellcheck disable=SC2155
    local resourceCount=$(terraform state list | wc -l)
    if [[ 0 -eq $resourceCount ]]; then
      echo " ... is empty"
      echo "deleting $w"
      terraform workspace select $currentWorkspace
      terraform workspace delete $w
    else
      echo " ... used: $resourceCount resources"
    fi
  done

  terraform workspace select "$currentWorkspace"
}
