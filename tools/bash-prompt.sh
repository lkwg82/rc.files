#!/bin/bash

set -o pipefail


if [[ ! -f $(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh ]]; then
  echo "installing first time bash-git-prompt"
  brew install bash-git-prompt
fi

if [[ -f $(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh ]]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  GIT_PROMPT_ONLY_IN_REPO=1
  GIT_PROMPT_THEME=Solarized
  GIT_PROMPT_SHOW_UPSTREAM=1
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi