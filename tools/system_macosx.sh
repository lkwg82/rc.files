#!/bin/bash

if [[ ${platform} != "darwin" ]]; then
  return
fi


function init_installed_programs(){
  local DEBUG_LAZY_INSTALL=1

  brew install bash # use more uptodate version than v3

  # window placement
  brew install rectangle

  # icon placement
  brew install jordanbaird-ice


  brew install --cask jetbrains-toolbox

  # System monitor for the menu bar
  brew install --cask stats
}
