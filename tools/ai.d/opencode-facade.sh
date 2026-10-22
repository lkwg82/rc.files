#!/usr/bin/env bash

set -eu

if [[ -n ${DEBUG:-} ]]; then
  set -x
fi

unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  platform='darwin'
fi

# OpenCode Facade Script

# see https://nono.sh/
  if [[ ${platform} == "darwin" ]]; then
    original_path="/opt/homebrew/bin/opencode"
  else
    original_path="/home/linuxbrew/.linuxbrew/bin/opencode"
    nono_extra_args='--read /home/linuxbrew/.linuxbrew/ --read $HOME/.sdkman --allow $HOME/.m2'
  fi

  if version_output=$("$original_path" --version 2>/dev/null); then
    if [[ "$version_output" =~ v?([0-9]+)(\.|$) ]]; then
      opencode_major_version="${BASH_REMATCH[1]}"
    else
      opencode_major_version="unknown"
    fi
  else
    opencode_major_version="unknown"
  fi

  echo "DEBUG parameters $*"
  if [[ "$opencode_major_version" == "2" ]]; then
    alias nono_opencode_ide='nono run --profile opencode       --allow-cwd '"${nono_extra_args:-}"' -- '${original_path}' '$@
  else
    alias nono_opencode_ide='nono run --profile opencode-local --allow-cwd '"${nono_extra_args:-}"' -- '${original_path}' '$@
  fi

shopt -s expand_aliases

if [[ -n "${NO__NONO:-}" ]]; then
    ${original_path} "$@"
else
    echo "🔧 Setze NO__NONO=1 um originales opencode zu nutzen"
    echo "📍 Quelle: ~/.bashrc.d/tools/ai.sh"
    echo "🔒 Nutze nono für sicheren opencode-Aufruf:"
    alias nono_opencode_ide
    echo " -------------- delay ------"
    sleep 1
    nono_opencode_ide

fi
