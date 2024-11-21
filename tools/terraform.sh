#!/bin/bash

if ! command -v terraform >/dev/null; then
  echo "install terraform via tenv"
  brew install tenv
  # install latest
  tenv tf install latest && tenv tf use latest
fi

if [[ -d ~/.config/topgrade ]] && ! [[ -f ~/.config/topgrade/tenv.toml ]] && ! command -v topgrade >/dev/null; then
  cat << EOF > ~/.config/topgrade/tenv.toml
    [commands]
    "Terraform: tenv" = "tenv tf install latest && tfenv tf use latest"
EOF
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

alias tf_destroy='terraform destroy'
alias tf_init='terraform init'
alias tf_output='terraform output'
alias tf_providers='terraform providers'

alias tf_state_ls='terraform state list'
alias tf_state_mv='terraform state mv'
alias tf_state_rm='terraform state rm'
alias tf_taint='terraform taint'
alias tf_validate='terraform validate'



# terraform apply -auto-approve ...
#  catches missing 'terraform init'
function tf_apply {
  local tmp_err=$(mktemp)
  # redirect stderr to file and stderr
  # to grep error message
  (
    # shellcheck disable=SC2068
    terraform apply -auto-approve $@
  ) 2> >(tee "$tmp_err" 2>&2)

  local exit_code=$?
  if [[ $exit_code -gt 0 ]]; then
    if grep -q "Module not installed" "$tmp_err"; then
      echo "ℹ️ HINT: missing 'terraform init' ... I'll do it 🚕"
      tf_init
      echo "ℹ️ HINT: retry 'terraform apply --auto-approve $*' ... I'll do it 🚕"
      # shellcheck disable=SC2068
      terraform apply -auto-approve $@
    fi
  fi
#  echo "✏️reformat (if needed)"
#  terraform fmt
}

function tf_import {
  local resource=$1
  local aws_address=$2

  if terraform import "${resource}" "${aws_address}"; then
    gum spin \
        --show-output \
        --title "Loading imported '${resource}' ..." \
        terraform state show "${resource}" | tee >(to_clipboard)
  fi
}

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

  if [[ $HOSTNAME =~ "bwpm-"* ]]; then
    export CI=true
    # shellcheck disable=SC2155
    export CI_COMMIT_REF_NAME=$(git branch --show-current)
    # shellcheck disable=SC2155
    # shellcheck disable=SC2046
    local remote=$(git config get branch.$(git branch --show-current).remote)
    # shellcheck disable=SC2155
    export CI_PROJECT_URL=$(git remote get-url "$remote" | sed -e 's|.*@ssh.||; s|:|/|; s|^|https://|; s|.git$||')
    # shellcheck disable=SC2155
    export CI_PROJECT_DIR=$(git rev-parse --show-toplevel)
  fi

  # shellcheck disable=SC2086
  # shellcheck disable=SC2048
  terraform plan -detailed-exitcode -out "$output.plan" $* | tee "$output";
  exitCode=$?
  #  -detailed-exitcode         Return detailed exit codes when the command exits.
  #                             This will change the meaning of exit codes to:
  #                             0 - Succeeded, diff is empty (no changes)
  #                             1 - Errored
  #                             2 - Succeeded, there is a diff

  if [[ $exitCode == 2 ]]; then
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
  fi
}

tf_graph() {
  local plan=$(mktemp)
  local graph=$(mktemp)
  local image=$(mktemp)

  terraform plan -out "$plan" $*
  terraform graph -plan="$plan" -draw-cycles > "$graph"

  dot -Tpng -o "${image}.png" "$graph"
  open "${image}.png"
}

function tf_state_show {
  if [ "$*" == "" ]; then
    tf_state_show $(gum spin --title "listing ... " --show-output terraform state list | gum filter)
  else
    terraform state show $* | tee >(to_clipboard)
  fi
}

function tf_test {

  if [[ $(find . -type f -name "*.tftest.hcl" | wc -c | xargs) != "0" ]]; then
    HAS_TF_TESTS=1
  fi

  if [[ -z $HAS_TF_TESTS ]] && [[ ! -d tests ]]; then
    read -r -p "Want to create a tests directory? (y/n) : " -n 1 reply
    echo "reply: $reply"
    if [[ $reply == "y" ]]; then

      function defined_vars {
        # need `find` command,
        # else missing newline at the end of files would merge lines
        # and break `grep` pattern
        find . -maxdepth 1 -type f -name "*.tf" -exec cat {} \; \
              | grep ^variable \
              | awk '{print $2}' \
              | xargs -n 1 \
              | sort
      }

      mkdir -p tests/setup
      cat << EOF > tests/setup/main.tf
# variables for propagation
$(defined_vars | sed -e 's|^\(.*\)|# variable "\1" {}|')

module "sut" {
  depends = [ ... ]

  source = "../.."
  $(defined_vars | sed -e 's|^\(.*\)|# \1 = var.\1|')
}

# add what you need for your tests
EOF
      terraform fmt tests/setup/main.tf

      cat << EOF > tests/all.tftest.hcl
variables{ # should be from module
  $(defined_vars | sed -e 's|^\(.*\)|# \1 = ...|')
}

run "simple"{
  # command = plan # default is 'apply'

  #variables{ # should be from module
    $(defined_vars | sed -e 's|^\(.*\)|# \1 = ...|')
  #}

  assert {
    # condition must contain a resource from module
    condition     = length(data.docker_logs.short_live_stderr.logs_list_string) == 0
    error_message = "test"
  }
}

  run "complex"{
    #variables{ # should be from setup-module (needs propation to original module)
      $(defined_vars | sed -e 's|^\(.*\)|# \1 = ...|')
    #}

    module {
      source = "./tests/setup"
    }

    assert {
      # condition must contain a resource from module
      # cannot access original module (only proxy module)
      condition     = length(data.docker_logs.short_live_stderr.logs_list_string) == 0
      error_message = "test"
    }
  }
EOF
    fi
    terraform fmt tests/all.tftest.hcl

    terraform init
  fi
  terraform test $@
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
