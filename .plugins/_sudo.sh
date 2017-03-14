#! /bin/bash

plugin start sudo

plugin import log

#
# Check whether the user is a sudoer
#
sudo_enabled() {
    log_d "checking sudo"
    sudo true
    return $?
}

plugin end sudo



