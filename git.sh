#!/bin/bash

set -o pipefail

# https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi
