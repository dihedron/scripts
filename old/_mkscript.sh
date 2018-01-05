#! /bin/bash


pragma start mkscript

pragma import log
pragma import askuser

#
# mkscript creates a new script adding the necessary preamble and 
# configuring it with logging and a dummy function
#
mkscript() {
    local libname=$1
    if [ -z "$libname" ]; then
        echo "usage: mkscript <lib-name>"
        return 1
    fi

    if [ -f "_${libname}.sh" ]; then
        ask_yes_no "The file $_${libname}.sh already exists and will be overwiritte; are you sure?"
        if [ $? -eq 1 ]; then
            return 1
        fi
    fi

    sudo cat <<EOF > "_${libname}.sh"
#! /bin/bash

pragma start $libname

pragma import log

#
# dummy_function is an example function 
#
dummy_function() {
    log_i "hallo, world!"
}

pragma end $libname

EOF
    chmod 755 "_${libname}.sh"
    return 0
}

pragma end mkscript
