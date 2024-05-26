#!/bin/bash

set -o pipefail

__lazy_install git

# https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion

# completion

if [ ! -f /usr/local/etc/bash_completion ]; then
  if [ ! -f "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash" ]; then
    echo "installing first time git "
    brew install git

    if [ -f "$BREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    __GIT_PROMPT_DIR="$BREW_PREFIX/opt/bash-git-prompt/share"
    source "$BREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh"
  fi
  fi
fi

# shellcheck disable=SC1091
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


function git_reset_with_submodules_recursivly(){
  # see: https://gist.github.com/nicktoumpelis/11214362?permalink_comment_id=3729225#gistcomment-3729225

  git reset --hard --recurse-submodule
}

function git_maintenance() {
	if [[ ! -d .git ]]; then
	   echo "need to be in git repository"
	   exit 1
	fi

	echo "-------------------------------"
	echo " git maintenance for $PWD"
	du -sh
	echo "--^^ before ... running ..."

	git maintenance run --task=gc
	git maintenance run --task=pack-refs
	git maintenance run --task=loose-objects

	echo "--  after ..."
	du -sh
	echo "-------------------------------"
	echo 
}
export -f git_maintenance
