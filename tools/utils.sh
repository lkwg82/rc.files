#!/bin/bash

function __lazy_install() {
  local cmd=$1
  if ! command -v "$cmd" >/dev/null; then
    echo "installing '$cmd'"
    brew install "$cmd"
  fi
}

__lazy_install pre-commit
__lazy_install shellcheck
