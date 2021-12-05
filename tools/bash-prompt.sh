#!/bin/bash

set -o pipefail
# Save and reload the history after each command finishes
save_reload_history='history -a; history -c; history -r'
if [[ -z $PROMPT_COMMAND ]]; then
  export PROMPT_COMMAND="${save_reload_history}"
else
  export PROMPT_COMMAND="${save_reload_history}; ${PROMPT_COMMAND}"
fi
export PROMPT_DIRTRIM=1

GREEN='\e[1;32m\]'
red='\e[0;31m\]'
BLUE='\[\e[1;34m\]'

# shellcheck disable=SC2155
export PS1="\[\e\]0\]${GREEN}\u${red}@${GREEN}\h: ${BLUE}\w ${BLUE}$(date +%H:%M)\e[0m\] \$ "

if [[ ! -f $BREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh ]]; then
  echo "installing first time bash-git-prompt"
  brew install bash-git-prompt
fi

if [[ -f $BREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh ]]; then
  export __GIT_PROMPT_DIR=$BREW_PREFIX/opt/bash-git-prompt/share

  # configs
  # see https://github.com/magicmonty/bash-git-prompt#all-configs-for-bashrc
  export GIT_PROMPT_ONLY_IN_REPO=1
  export GIT_PROMPT_THEME=Solarized
  export GIT_PROMPT_SHOW_UPSTREAM=1

  function prompt_callback() {
    # combine with terraform
    if command -v terraform >/dev/null && [ -d .terraform ]; then
      echo " [\[\e[1m\]workspace\e[0m:$(cat .terraform/environment 2>/dev/null || echo "default")]"
    fi
  }

  source "$BREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh"
fi

# terraform workspace
if command -v terraform >/dev/null; then

  function terraform_prompt() {
    if [ -d .terraform ]; then
      # consider git-prompt
      if type -t git_prompt_config >/dev/null; then
        repo=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -e $repo ]]; then
          # inside of git repository and with git-prompt we do nothing
          return
        fi
      fi

      # save old prompt
      if [[ -z $OLD_PS1 ]]; then
        OLD_PS1=${PS1}
      fi

      # shellcheck disable=SC2025
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\e[38;5;99m\]\[\e[1m\]\n\[\033[1;34m\]$(date +%H:%M)\[\033[0;0m\] [workspace:$(terraform workspace show 2>/dev/null || echo "<error>")]\e[0m \$ '
    else
      # recover old prompt
      if [[ -n $OLD_PS1 ]]; then
        PS1=${OLD_PS1}
      fi
    fi
  }

  PROMPT_COMMAND="terraform_prompt; $PROMPT_COMMAND"
fi
