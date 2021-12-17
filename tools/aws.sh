#!/bin/bash

if command -v aws >/dev/null; then
  complete -C '/usr/local/bin/aws_completer' aws
fi


function aws_ssm_help(){
  cat <<EOF
  examples

  aws ssm start-session --target i-0463a3cdb38933426 # start shell
  aws ssm start-session --target i-0463a3cdb38933426 --document-name AWS-StartInteractiveCommand --parameter command='tail -n1000 -F /opt/control/log'

  # more documents: https://eu-central-1.console.aws.amazon.com/systems-manager/documents?region=eu-central-1
EOF
}
