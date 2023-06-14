#!/bin/bash

if [[ ! -d ~/.sdkman ]]; then
  echo "installing sdkman"
  curl -s "https://get.sdkman.io" | bash
  # see https://sdkman.io/usage#config
  sed -e 's#sdkman_auto_env=false#sdkman_auto_env=true#' -i ~/.sdkman/etc/config
fi

export SDKMAN_DIR="/home/lars/.sdkman"
# shellcheck disable=SC1090
if [[ -s "/home/lars/.sdkman/bin/sdkman-init.sh" ]]; then
  source ~/.sdkman/bin/sdkman-init.sh
fi
