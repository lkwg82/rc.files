#!/bin/bash

__lazy_install pre-commit
__lazy_install shellcheck

function to_clipboard {
  if [[ ${platform} == "darwin" ]]; then
        echo "ℹ️ copied to clipboard"
        pbcopy < /dev/stdin
  else
    echo "⚠️ no implemented ... copy urself"
    cat
  fi
}
