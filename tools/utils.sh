#!/bin/bash

__lazy_install pre-commit
__lazy_install shellcheck

function to_clipboard {
  if [[ ${platform} == "darwin" ]]; then
        echo "ℹ️ copied to clipboard"
        pbcopy < /dev/stdin
  else
    echo "⚠️ no implemented ... copy urself"
    # uses bat https://github.com/sharkdp/bat
    cat --paging=never --language "terraform" --plain
  fi
}

function install_or_update_ghostty {
  # see https://github.com/mkasberg/ghostty-ubuntu

  source /etc/os-release
  local ARCH=$(dpkg --print-architecture)
  local GHOSTTY_DEB_URL=$(
     curl -s https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest | \
     grep -oP "https://github.com/mkasberg/ghostty-ubuntu/releases/download/[^\s/]+/ghostty_[^\s/_]+_${ARCH}_${VERSION_ID}.deb"
  )
  local GHOSTTY_DEB_FILE=$(basename "$GHOSTTY_DEB_URL")
  curl -LO "$GHOSTTY_DEB_URL"
  sudo dpkg -i "$GHOSTTY_DEB_FILE"
  rm -v "$GHOSTTY_DEB_FILE"
}