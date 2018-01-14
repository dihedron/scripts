#!/bin/bash

# if the array exists already, it is not modified,
# so just declare it here outside the function to 
# have ita accessible elsewhere; if we declared the 
# array within a function, it would be local and any 
# changes to it would be invisible to outer scripts, 
# even when this one is sourced.
declare -a _plugins

plugin() {
    local usage="usage: plugin <start|end|import|load|check|reset|list|help> [<name>]"

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
    "import"|"load")
        # validate input parameter: import requires the plugin name
        name=$2
        if [ -z "$2" ]; then
            echo $usage
            return 1        
        fi
        # check if already loaded, if so skip and return success
        plugin check $2
        if [ $? -eq 0 ]; then
            # plugin is already loaded
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
        echo "  +----------------------------------------------------------+"
        echo "  |                     PLUGIN HELP                          |"
        echo "  +----------------------------------------------------------+"
        echo "  plugin start <name> is used at the top of a library file,"
        echo "  right before declaring library variables and functions,"
        echo "  to ensure that any declaration doesn't happen more than once"
        echo "  should the library be sourced multiple times; this situation may"
        echo "  occur when the library is used by other libraries, and each"
        echo "  of those attempts to load it. The actual registration is only"
        echo "  performed by the plugin end <name> command, which must be added"
        echo "  at the end of the file."
        echo ""
        echo "  EXAMPLE:"
        echo "    #!/bin/bash"
        echo "    plugin start mylib"
        echo "    function myfunc() {"
        echo "        # do something..."
        echo "    }"
        echo "    plugin end mylib"
        echo ""
        echo "  plugin import <name> is used by the library client, in order to"
        echo "  import the library definition into their namespaces; an alternative"
        echo "  form is plugin load <name>:"
        echo ""
        echo "  EXAMPLE:"
        echo "    #!/bin/bash"
        echo "    plugin import mylib"
        echo "    myfunc ARG1 ARG2"
        echo ""
        echo "  plugin check <name> checks if the giben plugin has already been"
        echo "  loaded."
        echo ""
        echo "  plugin import will try to locate a file named _mylib.sh"
        echo "  under the \$SCRIPTLIB or under ~/scripts/lib and will"
        echo "  source it into the importing script's namespace."
        echo ""
        echo "  plugin list returns a list of registered plugins, as an array."
        echo ""
        echo "  plgin reset resets the contents of the plugins rgistry, effectively"
        echo "  allowing for hot swapping function defitions by reloading plugins."
        echo ""
        ;;
    *)
	echo $usage
	return 1
	;;
    esac
}

