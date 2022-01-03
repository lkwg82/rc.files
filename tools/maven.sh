#!/bin/bash

export MAVEN_OPTS="-Xmx1800m -Dmaven.artifact.threads=30"

alias mvn_doxygen='mvn com.soebes.maven.plugins.dmg:doxygen-maven-plugin:report ' \
  '-Ddoxygen.alwaysDetailedSec=true ' \
  '-Ddoxygen.callerGraph=true ' \
  '-Ddoxygen.callGraph=true ' \
  '-Ddoxygen.createSubdirs=true ' \
  '-Ddoxygen.extractAll=true ' \
  '-Ddoxygen.extractAnonNspaces=true ' \
  '-Ddoxygen.extractLocalMethods=true ' \
  '-Ddoxygen.extractPrivate=true ' \
  '-Ddoxygen.extractStatic=true ' \
  '-Ddoxygen.fullPathNames=false ' \
  '-Ddoxygen.generateTreeview=NONE ' \
  '-Ddoxygen.hideScopeNames=true ' \
  '-Ddoxygen.htmlDynamicSections=false  ' \
  '-Ddoxygen.inlineInheritedMemb=true  ' \
  '-Ddoxygen.inlineSources=true  ' \
  '-Ddoxygen.optimizeOutputJava=true  ' \
  '-Ddoxygen.projectName=test  ' \
  '-Ddoxygen.quiet=false  ' \
  '-Ddoxygen.recursive=true ' \
  '-Ddoxygen.referencedByRelation=true ' \
  '-Ddoxygen.referencesRelation=true  ' \
  '-Ddoxygen.searchengine=true  ' \
  '-Ddoxygen.shortNames=true ' \
  '-Ddoxygen.showNamespaces=false  ' \
  '-Ddoxygen.sortBriefDocs=true ' \
  '-Ddoxygen.sortGroupNames=true   ' \
  '-Ddoxygen.stripCodeComments=false  ' \
  '-Ddoxygen.templateRelations=true  ' \
  '-Ddoxygen.umlLook=false ' \
  '-Ddoxygen.input=src/main/java/\ src/test/java/'

function __maven_bash_completion() {
  if [[ ! -f $BREW_PREFIX/etc/bash_completion.d/maven ]]; then
    echo "installing maven bash completion"
    brew install maven-completion
  fi

  # shellcheck disable=SC1091
  . "$BREW_PREFIX/etc/bash_completion.d/maven"
}

# this wrapper function uses local mvn wrapper command if exists
function mvn() {
  __maven_bash_completion

  if ! command -v mvnd >/dev/null; then
    sdk install mvnd
  fi

  bash -c "mvnd $*"

  #  if [[ -x 'mvnw' ]]; then
  #    ./mvnw "$@"
  #  elif [[ -x '../mvnw' ]]; then
  #    ../mvnw "$@"
  #  else
  #    bash -c "mvn $*"
  #  fi
}
export -f mvn

# continuously maven
function mvn_watch() {
  if ! command -v inotifywait >/dev/null; then
    echo "ERROR plz install inotifywait"
    return 1
  fi

  if [[ $# == 0 ]]; then
    echo "run '${FUNCNAME[0]}' like any maven command '${FUNCNAME[0]} clean compile'"
    return
  fi

  mvn "$*"
  while (true); do
    echo "Waiting for changes (invoking 'mvn $*')"
    inotifywait -q \
      -e close_write \
      -e create \
      -e delete \
      -e moved_from \
      -e moved_to \
      -r $(find . -maxdepth 1 -not -name "\.*" | xargs)
    mvn "$*"
    sleep 1
  done
}
export -f mvn_watch
