#!/bin/bash

# if the array exists already, it is not modified,
# so just declare it here outside the function to 
# have ita accessible elsewhere; if we declared the 
# array within a function, it would be local and any 
# changes to it would be invisible to outer scripts, 
# even when this one is sourced.
declare -a _plugins

plugin() {

    local usage="usage: plugin <start|end|import|check|reset|list|help> [<name>]"

    # check if an operation was specified
    local operation=$1
    if [ -z "$operation" ]; then
        echo $usage
        return 1
    fi
    case $operation in
    "start")
        # validate input parameter: start requires the plugin name
        name=$2
        if [ -z "$2" ]; then
            echo $usage
            return 1        
        fi        
        # check that the PLUGINSLIB exists, or a directory named .plugins
        # under the current user's home directory (~/.plugins) 
        if [ "$PLUGINSLIB" != "" -a -d "$PLUGINSLIB" ]; then
            return 0
        elif [ -d ~/.plugins ]; then
            return 0
        else
            echo "no plugin directory defined" 
            return 1
        fi
        ;;
    "end")
        # validate input parameter: end requires the plugin name
        name=$2
        if [ -z "$2" ]; then
            echo $usage
            return 1        
        fi      
        # add the plugin to the registry
        _plugins[${#_plugins[@]}]="$name"
        return 0          
        ;;
    "import")
        # validate input parameter: import requires the plugin name
        name=$2
        if [ -z "$2" ]; then
            echo $usage
            return 1        
        fi
        # check if already loaded, if so skip and return success
        plugin check $2
        if [ $? -eq 0 ]; then
            echo "plugin $name already loaded"
            return 0
        fi
        # check if the file exists under the $PLUGINSLIB path or 
        # under ~/.plugins
        if [ -f "$PLUGINSLIB/_${name}.sh" ]; then    
            source "$PLUGINSLIB/_${name}.sh"
            return 0
        elif [ -f "~/.plugins/_${name}.sh" ]; then
            source "~/.plugins/_${name}.sh"
            return 0
        else
            echo "plugin $name is not available"
        fi
        return 1
        ;;
    "check")
        # validate input parameter: check requires the plugin name
        name=$2
        if [ -z "$2" ]; then
            echo $usage
            return 1
        fi
        for p in ${_plugins[@]}; do
            if [ "$p" == "$name" ]; then
                return 0
            fi
        done
        return 1
        ;;
    "reset")
        _plugins=()
        return 0
        ;;
    "list")
        # print out all the currently loaded plugins
        for p in ${_plugins[@]}; do
            echo $p
        done
        return 0            
        ;;
    "help")
        # TODO: write extensive usage!
        ;;
    esac
}

