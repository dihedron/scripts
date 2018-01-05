#! /bin/bash

pragma begin log

if [ "$_level" == "" ]; then
    _level=3
fi

#
# log_set_level initialises the log to the given value; accepted values
# are in the 0 (mute) to 5 (debug), with the following values: 
# - 0: no logging
# - 1: error messages only
# - 2: error and warning messages
# - 3: error, warning and informational messages 
# - 4: all messages, inluding debugging messages 
# if no value is provided, it will initialise to the default level
# ("info").
#
log_set_level() {
    echo "defining log set level"
    case $1 in 
        [0-4]) _level=$1;;
        *    ) _level=3 ;;
    esac
    export _level=$_level
}

#
# log_get_level returns the current logging level
#
log_get_level() {
    return $_level
}

#
# log_print prints a message only if its level is at least that of the 
# current logging level; requires a numerica value as the first argument, 
# plus a set of optional arguments which make up the message and which will
# be printed out separated by a blank space.
#
log_print() {
    if [ $# -eq 0 ]; then
        return 1
    fi    

    if [ $1 -le $_level -a $1 -gt 0 ]; then
        local now=$(date +"%d%m%Y@%T")
        case $1 in
            1) echo -n "$now [E]" ;;
            2) echo -n "$now [W]" ;;
            3) echo -n "$now [I]" ;;
            4) echo -n "$now [D]" ;;
        esac 
        shift
        for arg in "$@"; do
            echo -n " $arg"
        done
        echo ""
    fi
}

#
# log_d prints a debug message
#
log_d() {
    log_print 4 $@
}

#
# log_i prints an informational message
#
log_i() {
    log_print 3 $@
}

#
# log_w prints a warning message
#
log_w() {
    log_print 2 $@
}

#
# log_e prints an error message
#
log_e() {
    log_print 1 $@
}

pragma end log
