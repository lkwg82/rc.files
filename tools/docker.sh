#!/bin/bash

alias dc='docker compose'

__lazy_install lazydocker
__lazy_install docker-compose

function docker_build_mounted_run(){
  local image="test-$RANDOM"
  docker build -t "$image" .

  if [ $# -eq 0 ]; then
    docker run --rm -ti -v "$PWD":/src -w /src $image
  else
    # shellcheck disable=SC2068
    docker run --rm -ti -v "$PWD":/src -w /src $image $@
  fi
}

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

function __docker_containers() {
  gum spin --show-output --spinner dot --title 'list containers ...' -- \
    "$SHELL" -c "docker ps --format '{{.Names}} {{.ID}}' | sort "

  local cid=""
  cid=$( \
    printf "%-30s %s\n"  \
      $(gum spin --show-output --spinner dot --title 'list containers ...' -- \
      "$SHELL" -c "docker ps --format '{{.Names}} {{.ID}}' | sort ") \
    | gum filter --no-fuzzy \
    | awk '{print $2}'
  )
  export CONTAINER_ID=$cid
}

function docker_inspect() {

  ( # keep env clean
    __docker_containers
    docker inspect $* "$CONTAINER_ID" | jq
  )
}

function docker_logs() {
  ( # keep env clean
    __docker_containers
    docker logs --timestamps $* "$CONTAINER_ID"
  )
}
