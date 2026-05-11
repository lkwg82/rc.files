#!/usr/bin/env bash

YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # NC stands for "No Color"

print_color() {
  local color=$1
  local status=$2
  local message=$3

  # Wenn nur zwei Argumente, dann ist status INFO
  if [ -z "$message" ]; then
    message=$2
    status="INFO"
  fi

  printf >&2 "\033[1;37m[\033[0m%b%s\033[1;37m]\033[0m %b%s%b\n" "$color" "$status" "\033[1;37m" "$message" "$NC"
}
log_info(){
  print_color "$CYAN" "INFO" "$1"
}
log_hint(){
  print_color "$YELLOW" "$1"
}

log_error(){
  print_color "$RED" "FAILED" "$1"
}
