#!/bin/bash

#alias dc='docker compose'

__lazy_install lazydocker
__lazy_install docker-compose

function dc(){
  if command podman-compose --help 2>&1 >/dev/null; then
	podman-compose $*
  else
	docker compose $*
  fi
}

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

# shellcheck disable=SC2154
if [[ ${platform} == "linux" ]]; then
  systemctl --user start podman.socket >&2 2> /dev/null
  export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
fi
