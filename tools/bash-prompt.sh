#!/bin/bash

set -o pipefail

function terraform_prompt() {
  if [ -d .terraform ]; then
    workspace="$(command terraform workspace show 2>/dev/null)"
    echo "${workspace}"
  fi
}

if [[ ! -f $(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh ]]; then
  echo "installing first time bash-git-prompt"
  brew install bash-git-prompt
fi

if [[ -f $(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh ]]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share

  # configs
  # see https://github.com/magicmonty/bash-git-prompt#all-configs-for-bashrc
  GIT_PROMPT_ONLY_IN_REPO=1
  GIT_PROMPT_THEME=Solarized
  GIT_PROMPT_SHOW_UPSTREAM=1

  function prompt_callback() {
    # combine with terraform
    if command -v terraform >/dev/null; then
      echo " [\[\e[1m\]workspace\e[0m:$(terraform_prompt)]"
    fi
  }

  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

# terraform workspace
if ! type -t git_prompt_config >/dev/null && command -v terraform >/dev/null; then
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\e[38;5;99m\]\[\e[1m\]\n\[\033[1;34m\]$(date +%H:%M)\[\033[0;0m\] [workspace:$(terraform_prompt)]\e[0m \$ '
fi
