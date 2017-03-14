#! /bin/bash

pragma start DISTRO

pragma import LOG

#
# distro_print_name retrieves the name of the distribution from /etc/issue
#
distro_print_name() {
    array=(`cat /etc/issue`)
    echo ${array[0]}
}

#
# distro_print_version retrieves the version of the distribution from /etc/issue
#
distro_print_version() {
    array=(`cat /etc/issue`)
    echo ${array[1]}
}

#
# distro_print_lts retrieves the LTS string of the distribution from /etc/issue
#
distro_print_lts() {
    array=(`cat /etc/issue`)
    echo ${array[2]}
}

#
# distro_check_name checks if the script is currently running on 
# one of the given distributions (passed in as function arguments); if
# the function is called without arguments, it checks against "Ubuntu"
#
distro_check_name() {
    name=$(distro_print_name)
    if [ $# -eq 0 ]; then
        arg="Ubuntu.*"
        if [[ "$name" =~ "$arg" ]]; then
            return 0
        fi
    else
        if [ "$1" == "--help" -o "$1" == "-h" ]; then
            echo "usage: distro_check_name \"Ubuntu.*\" [\"Mint\" <regex>\...]"
            return 0
        else 
            for arg in "$@"; do
                if [[ "$name" =~ "$arg" ]]; then
                    return 0
                fi
            done
        fi
    fi
    return 1
}

#
# distro_check_version checks if the script is currently running on 
# one of the given versions (passed in as function arguments) of the
# current distribution; if the function is called without arguments, 
# it checks against "16.04*"
#
distro_check_version() {
    version=$(distro_print_version)
    if [ $# -eq 0 ]; then
        arg="16.04.*"
        if [[ "$version" =~ $arg ]]; then
            return 0
        fi
    else
        if [ "$1" == "--help" -o "$1" == "-h" ]; then
            echo "usage: distro_check_version \"16.04.*\" [\"14.04\" <regex>...]"
            return 0
        else 
            for arg in "$@"; do
                if [[ "$version" =~ $arg ]]; then
                    return 0
                fi
            done
        fi
    fi
    return 1
}

#
# distro_check_lts checks if the script is currently running on an LTS
# version of the distribution; it requires no parameters.
#
distro_check_lts() {
    lts=$(distro_print_lts)
    if [ "$lts" == "LTS" ]; then
        return 0
    fi
    return 1
}

pragma end DISTRO

#distro_check_name "Mint" "Ubuntu" "RedHat"
#echo "distro_name: $?"
#distro_check_version "16.06" "16.04.*" "17.10"
#echo "distro_version: $?"
#distro_check_lts 
#echo "distro_is_lts: $?"

#NAME=$(distro_print_name)
#echo "NAME: $NAME"
#VERSION=$(distro_print_version)
#echo "VERSION: $VERSION"
#LTS=$(distro_print_lts)
#echo "LTS: $LTS"


