#!/bin/bash

if ! command -v tfenv >/dev/null; then
  echo "install tfenv"
  brew install tfenv
  tfenv install latest
fi

if ! command -v tflint >/dev/null; then
  echo "installint tflint"
  brew install tflint
fi

# enable completion
complete -C "$(command -v terraform)" terraform

alias tf_apply='terraform apply -auto-approve'

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

function tf_plan {
  # shellcheck disable=SC2155
  local output=$(mktemp)
  terraform plan -out "$output.plan" | tee "$output"
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

  echo " try to select workspace '$workspace' ... "
  if terraform workspace select "$workspace" 2>/dev/null; then
    echo -n ""
  else
    if ! terraform workspace new "$workspace"; then
      echo "failed"
    fi
  fi

  terraform init -upgrade # since terraform v0.13
}

function tf___list_empty_workspaces {
  local currentWorkspace=$(terraform workspace show)

  if [[ -f __empty_workspaces ]]; then
      echo "plz remove old '__empty_workspaces' before proceeding"
      exit 1
  fi

  for w in $(terraform workspace list | grep -vE "$currentWorkspace$" | grep -v default); do
    if [[ $w == $currentWorkspace ]]; then
      echo "skipping current workspace"
      continue
    fi

    echo "checking '$w' ... "
    terraform workspace select "$w"
    local resourceCount=$(terraform state list | wc -l)
    if [[ 0 -eq $resourceCount ]]; then
      echo " ... is empty"
      echo "$w" >> __empty_workspaces
    else
      echo " ... used: $resourceCount resources"
    fi
  done

  terraform workspace select "$currentWorkspace"

  if [[ -f __empty_workspaces ]]; then
    echo "--- empty workspaces --- "
    sort __empty_workspaces
    echo "-- /empty workspaces --- "
    echo "execute the following command to remove them"
    echo 'for w in $(cat __empty_workspaces); do echo terraform workspace delete $w; done'
  fi
}

# this fixes the output of ansi colors
# see https://github.com/hashicorp/terraform/issues/21779
alias tf_state_show='terraform state show -no-color'
