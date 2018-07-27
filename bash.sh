#!/bin/bash

set -o pipefail

# create temp dir and cd
alias cdtmp='dir="$(tempfile).d" && mkdir -p $dir && cd $dir'

alias ll='ls -al'


# create dir and cd
function cdmkdir {
	local dir=$1 || echo "ERROR missing argument"
	mkdir -p $dir && cd $dir
}