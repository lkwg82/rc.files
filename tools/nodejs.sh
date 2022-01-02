#!/bin/bash

if [ ! -f /home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh ]; then
  brew install nvm
fi

mkdir -p "$HOME"/.nvm
export NVM_DIR="$HOME/.nvm"

function __setup_nvm(){
  local path=$1
  if [ ! -d "$path" ]; then
    echo "ERROR did not find nvm path '$path'"
    return
  fi
  # shellcheck disable=SC1091
  [ -s "$path/opt/nvm/nvm.sh" ] && \. "$path/opt/nvm/nvm.sh"  # This loads nvm
  # shellcheck disable=SC1091
  [ -s "$path/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$path/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
}
# shellcheck disable=SC2154
[[ ${platform} == "linux" ]] &&  __setup_nvm "/home/linuxbrew/.linuxbrew/"
[[ ${platform} == "darwin" ]] &&  __setup_nvm "/usr/local/"

(
  if ! cd "$OLDPWD"; then
    echo "ERROR could not 'cd $OLDPWD'"
    return
  fi
  if [ -f ".nvmrc" ]; then
    if ! nvm use; then
      if ! nvm install "$(cat .nvmrc)"; then
        echo
        echo "WARNING sth is wrong with your '.nvmrc', see https://github.com/nvm-sh/nvm#nvmrc"
        echo "-- your nvmrc --"
        cat .nvmrc
        echo "-- /your nvmrc --"
      fi
    fi
  fi
)
