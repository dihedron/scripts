#! /bin/bash

pragma begin check

#
# check() tests whether the given value means success or failure,
# prints an OK/KO message and returns the very code it checked.
#
check() {
	if [ $1 -ne 0 ]; then
		echo "KO: $1"
		return $1
	else
		echo "OK!"
	fi
}

#
# check_or_die() tests whether the given value means success or
# failure and in the latter case exist the current program with
# the given error code; in both cases it prints an OK/KO message.
#
check_or_die() {
	if [ $1 -ne 0 ]; then
		echo "KO: 1"
		exit $1
	else
		echo "OK!"
	fi
}

#
# check_is_bash() checks if the script is running under bash.
#
check_is_bash() {
	if [ ! "$BASH_VERSION" ]; then
		echo "Please run this script under bash."
		return 1
	fi 
}

#
# check_is_bash_or_die() checks if the script is running under
# bash; if not, it exits the current script with 1.
#
check_is_bash_or_die() {
	if [ ! "$BASH_VERSION" ]; then
		echo "Please run this script under bash."
		exit 1
	fi 
}

#
# check_is_root checks() if the script is running under root.
#
check_is_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root."
		return 1
	fi
}

#
# check_is_root_or_die() checks if the script is running under 
# root; if not, it exits the current script with 1.
#
check_is_root_or_die() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root."
		exit 1
	fi
}

pragma end check

