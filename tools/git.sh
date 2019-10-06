#!/bin/bash

set -o pipefail
# https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion

# completion

if [ ! -f /usr/local/etc/bash_completion ]; then
  if [ ! -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
    echo "installing first time git bash-completion"
    brew install git bash-completion
  fi
fi

if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
  . "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
fi

if [ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
  . /usr/local/etc/bash_completion.d/git-prompt.sh
fi

# prompt

if [[ ! -f $(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh ]]; then
    brew install bash-git-prompt
fi

if [[ -f $(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh ]]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  GIT_PROMPT_ONLY_IN_REPO=1
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi
