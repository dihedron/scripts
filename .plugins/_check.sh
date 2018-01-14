#! /bin/bash

pragma begin check

#
# check_is_bash() checks if the script is running under bash.
#
check_is_bash() {
	if [ ! "$BASH_VERSION" ]; then
		return 1
	fi 
}

#
# check_is_root checks() if the script is running under root.
#
check_is_root() {
	if [[ $EUID -ne 0 ]]; then
		return 1
	fi
}

pragma end check

