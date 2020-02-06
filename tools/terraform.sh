#!/bin/bash

if command -v  terraform > /dev/null; then
  alias tf_apply='terraform apply -auto-approve'

  # this fixes the output of ansi colors
  # see https://github.com/hashicorp/terraform/issues/21779
  alias tf_state_show='terraform state show -no-color'
fi