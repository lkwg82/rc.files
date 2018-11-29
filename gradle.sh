#!/bin/bash

function __gradle_bash_completion {
    if [[ ! -f $(brew --prefix)/etc/bash_completion ]]; then
        echo "installing gradle bash completion"
        brew install gradle-completion;
    fi

    . $(brew --prefix)/etc/bash_completion
}

# this wrapper function uses local gradle wrapper command if exists
function gradle {
    __gradle_bash_completion

	if [[ -x 'gradlew' ]]; then
		./gradlew $@
	else
		bash -c "gradlew $*"
	fi
}
