#!/bin/bash

function __gradle_bash_completion() {
  if [[ ! -f $(brew --prefix)/etc/bash_completion ]]; then
    echo "installing gradle bash completion"
    brew install gradle-completion
  fi

  # shellcheck disable=SC1090
  . "$(brew --prefix)/etc/bash_completion"
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
