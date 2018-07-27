#!/bin/bash

# this wrapper function uses local gradle wrapper command if exists
function gradle {
	if [ -x 'gradlew' ]; then
		./gradlew $@
	else
		bash -c "gradlew $*"
	fi
}
