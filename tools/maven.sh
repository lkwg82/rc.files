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
  if [[ ! -f $(brew --prefix)/etc/bash_completion.d/maven ]]; then
    echo "installing maven bash completion"
    brew install maven-completion
  fi

  # shellcheck disable=SC1090
  . "$(brew --prefix)/etc/bash_completion.d/maven"
}

# this wrapper function uses local mvn wrapper command if exists
function mvn() {
  __maven_bash_completion

  if [[ -x 'mvnw' ]]; then
    ./mvnw "$@"
  elif [[ -x '../mvnw' ]]; then
    ../mvnw "$@"
  else
    bash -c "mvn $*"
  fi
}
