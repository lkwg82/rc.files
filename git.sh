#!/bin/bash

set -o pipefail

# https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion

if [ ! -f /usr/local/etc/bash_completion ]; then
    echo "installing first time git bash-completion"
    brew install git bash-completion
fi

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

if [ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
  . /usr/local/etc/bash_completion.d/git-prompt.sh
  export GIT_PS1_SHOWCOLORHINTS=true
  export GIT_PS1_SHOWDIRTYSTATE=true
  export PROMPT_COMMAND='__git_ps1 "\w" "\n\\\$ "'
  export PS1='[\u@mbp \w$(__git_ps1)]\$ '
fi
