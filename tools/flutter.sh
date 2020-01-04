#!/bin/bash

# https://flutter.dev/docs/get-started/install/linux

set -x

function flutter_install() {
  mkdir -p "$HOME/development/tools/"
  if [[ ${platform} = "darwin" ]]; then
    local url="https://storage.googleapis.com/flutter_infra/releases/stable/macos/flutter_macos_v1.12.13+hotfix.5-stable.zip"
  else
    local url="https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.12.13+hotfix.5-stable.tar.xz"
  fi

  pushd "$HOME/development/tools" || return

  read -n1 -p "clean flutter dir and redownload and extract fresh install [y/n]? " yn
    case $yn in
        [Yy]* )
          wget -c ${url}
          if [[ -d flutter ]]; then
            rm -rf flutter
          fi

          local file=$(basename ${url})
          if [[ ${platform} = "darwin" ]]; then
            unzip ${file}
          else
            tar -xvJf ${file}
          fi
          ;;
        [Nn]* ) echo "";;
        * ) echo "Please answer yes or no.";;
    esac

  popd

  flutter precache
}

if [[ -d $HOME/development/tools/flutter/bin ]]; then
  export PATH=$PATH:$HOME/development/tools/flutter/bin
fi

set +x
