#!/bin/bash

if ! test -d ~/.sdkman; then
  echo "installing sdkman"
  curl -s "https://get.sdkman.io" | bash
  # see https://sdkman.io/usage#config
  sed -e 's#sdkman_auto_env=false#sdkman_auto_env=true#' -i ~/.sdkman/etc/config
fi

# shellcheck disable=SC1090
. ~/.sdkman/bin/sdkman-init.sh
