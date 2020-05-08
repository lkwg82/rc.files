#!/bin/bash

if ! test -d ~/.sdkman >/dev/null; then
  echo "installing sdkman"
  curl -s "https://get.sdkman.io" | bash
  # see https://sdkman.io/usage#config
  sed -e 's#sdkman_auto_env=false#sdkman_auto_env=true#' -i ~/.sdkman/etc/config
fi

. ~/.sdkman/bin/sdkman-init.sh

# enable automatic env
sdkman_auto_env=true