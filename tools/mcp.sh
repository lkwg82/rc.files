#!/bin/bash

function mcp_kubectl {
  # see https://github.com/rohitg00/kubectl-mcp-server
  echo "starts and install in temp dir"
  cdtmp
  uv venv .venv
  source .venv/bin/activate
  uv pip install kubectl-mcp-server

  local cmd=(kubectl-mcp-serve serve --transport http --port 8000 --disable-destructive "$@")
  echo "Running: ${cmd[*]}"
  "${cmd[@]}"
}
