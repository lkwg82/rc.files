#!/bin/bash

if ! command -v pre-commit > /dev/null; then
  echo "installing pre-commit"
  brew install pre-commit
fi