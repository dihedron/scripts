#! /bin/bash

plugin start askuser

plugin import log

#
# ask_yes_no askis for user confirmation; accepts an optiional message, and 
# returns 0 (yes) or 1 (no), looping until the user provides a valid answer.
#
ask_yes_no() {
    message=$1
    if  [ "$message" == "" ]; then
        message="Are you sure?"
    fi

    while true; do
        read -p "$message [yes|no]: " answer
        case $answer in
        [Yy]* ) return 0; break;;
        [Nn]* ) return 1; break;;
        *     ) echo "Please answer yes or no."
        esac
    done
}

plugin end askuser

