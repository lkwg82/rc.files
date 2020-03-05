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

function commitAndPush() {
  local changedFile=$1
  local branch=$(git rev-parse --abbrev-ref HEAD)

  echo "-- handle event "
  git commit -m 'auto commit' "$changedFile" &&
    git push --set-upstream origin "$branch"
}

export -f commitAndPush
set -x
if [[ ${platform} == "darwin" ]]; then
  if ! command -v fswatch >/dev/null; then
    echo "install fswatch"
    brew install fswatch
  fi

  fswatch -0 -r . |
    xargs -0 -n1 -I{} git diff --name-only |
    xargs -n1 -I{} bash -c 'commitAndPush {}'
fi
