#!/bin/bash

set -o pipefail

if ! command -v git >/dev/null; then
  return
fi

# https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion

# completion

if [ ! -f /usr/local/etc/bash_completion ]; then
  if [ ! -f "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash" ]; then
    echo "installing first time git bash-completion"
    brew install git bash-completion
  fi
fi

if [ -f "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash" ]; then
  # shellcheck disable=SC1091
  . "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash"
fi

# HINT: for prompt see bash-prompt.sh

function commitAndPush() {
  local changedFile="$1"
  # shellcheck disable=SC2155
  local branch=$(git rev-parse --abbrev-ref HEAD)

  echo "-- handle event "

  if [[ $branch == 'master' ]]; then
    echo "skipping, because on master"
  else
    git commit -m "auto commit: $changedFile" "$changedFile"
  fi
}

export -f commitAndPush

# shellcheck disable=SC2154
if [[ ${platform} == "darwin" ]]; then
  if ! command -v fswatch >/dev/null; then
    echo "install fswatch"
    brew install fswatch
  fi

  function auto-commit-and-push() {
    # shellcheck disable=SC2155
    local branch=$(git rev-parse --abbrev-ref HEAD)

    echo "waiting for changes (on branch '$branch') ... "
    while (true); do
      fswatch --latency 0.2 --one-event --print0 --recursive . |
        xargs -0 -I{} git diff --name-only |
        sort -u |
        xargs |
        xargs -n1 -I{} bash -c 'commitAndPush {}'

      if [[ $branch == 'master' ]]; then
        echo "skipping, because on master"
      else
        git push --set-upstream origin "$branch"
      fi
    done
  }
  export -f auto-commit-and-push
fi
