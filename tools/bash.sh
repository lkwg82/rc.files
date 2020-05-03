#!/bin/bash

set -o pipefail

# create temp dir and cd
alias cdtmp='dir="$(mktemp -d)" && cd $dir'

alias ll='ls -al'

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls -GFh'

# create dir and cd
function cdmkdir {
	local dir=$1 || echo "ERROR missing argument"
	mkdir -p "${dir}" && cd "${dir}"
}

export PATH=~/bin:$PATH

# https://github.com/jbarlow83/OCRmyPDF
# https://medium.com/@thucnc/convert-a-scanned-pdf-to-text-with-linux-command-line-using-ocrmypdf-1a2e8d50277f
alias docker_ocrmypdf='docker run --rm  -i --user "$(id -u):$(id -g)" --workdir /data -v "$PWD:/data" jbarlow83/ocrmypdf'
