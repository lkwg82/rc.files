#!/bin/bash

function __gradle_bash_completion() {
  # shellcheck disable=SC1091
  if [[ ! -f $BREW_PREFIX/etc/bash_completion.d/gradle ]]; then
    echo "installing gradle bash completion"
    brew install gradle-completion
  fi
  # shellcheck disable=SC1091
  . "$BREW_PREFIX/etc/bash_completion.d/gradle"
}

_gradle_path=$(command -v gradle)

# this wrapper function uses local gradle wrapper command if exists
function gradle() {
  __gradle_bash_completion

  if [[ -x 'gradlew' ]]; then
    ./gradlew "$@"
  else
    if command -v gradlew > /dev/null; then
      gradlew "$@"
    elif [[ -n $_gradle_path ]]; then
      $_gradle_path "$@"
    else
      echo "missing gradle :/"
      exit 1
    fi
  fi
}
