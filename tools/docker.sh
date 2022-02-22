#!/bin/bash

function docker_build_run(){
  local image="test-$RANDOM"
  docker build -t "$image" .

  if [ $# -eq 0 ]; then
    docker run --rm -ti $image
  else
    # shellcheck disable=SC2068
    docker run --rm -ti $image $@
  fi
}
