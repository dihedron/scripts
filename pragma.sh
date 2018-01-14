#!/bin/bash

# if the array exists already, it is not modified,
# so just declare it here outside the function to 
# have ita accessible elsewhere; if we declared the 
# array within a function, it would be local and any 
# changes to it would be invisible to outer scripts, 
# even when this one is sourced.
declare -a _plugins
declare -a _directories

readonly EOK=0		# Success: everything ok!
readonly ENOPE=35	# Generic, business-logic error
readonly EPERM=1	# Operation not permitted 
readonly ENOENT=2  	# No such file or directory 
readonly EAGAIN=11  # Try again 
readonly EACCES=13  # Permission denied 
readonly EEXIST=17  # File exists 
readonly ENOTDIR=20 # Not a directory 
readonly EISDIR=21  # Is a directory 
readonly EINVAL=22  # Invalid argument 

#
# _pragma_confirm asks for user confirmation; accepts an optional message, and 
# returns 0 (yes) or 1 (no), looping until the user provides a valid answer.
#
_pragma_confirm() {
	message=$1
	if  [ "$message" == "" ]; then
		message="Are you sure?"
	fi

	while true; do
		read -p "$message [yes|no]: " answer
		case $answer in
		[Yy]* ) return $EOK; break;;
		[Nn]* ) return $ENOPE; break;;
		*	 ) echo "Please answer yes or no."
		esac
	done
}

#
# _pragma_locate echoes the directory where a specific plugins is located to STDOUT.
#
_pragma_locate() {
	# validate input parameter: locate requires the plugin name
	local name=$1
	if [ -z "$name" ]; then
		return $EINVAL
	fi	 

	for directory in "${_directories[@]}"; do
		if [ -f "${directory}/_${name}.sh" ]; then
    		echo "$directory"
			return $EOK
		fi
	done
	return $ENOENT
}

#
# _pragma_path echoes the list of directories from which plugins 
# will be loaded to STDOUT; it gets them from $PLUGINSPATH if defined, or
# from ~/.plugins and ./.plugins if not, in this order.
#
_pragma_path() {
	for directory in "${_directories[@]}"; do
    	echo "$directory"
	done		
}

# _pragma_begin requires the name of the plugin; it marks the beginning of
# the a plugin implementation and performs some sanity checks on the environment.
_pragma_begin() {
	# validate input parameter: begin requires the plugin name
	local name=$1
	if [ -z "$name" ]; then
		return $EINVAL
	fi	 

	# plugins directory not found!
	return $ENOPE
}

# _pragma_end requires the name of the plugin, marks the end of its implementation 
# and commits it to the shared plugins registry by adding it to the array.
_pragma_end() {
	# validate input parameter: end requires the plugin name
	local name=$1
	if [ -z "$name" ]; then
		return $EINVAL 
	fi	  
	#
	# TODO: may want to check if it has already been sourced???
	#	

	# add the plugin to the registry
	_plugins[${#_plugins[@]}]="$name"
	return $EOK		  
}

# _pragma_exists requires the name of the plugin; it checks if a file with 
# the proper name exists under the $PLUGINSPATH.
_pragma_exists() {
	# validate input parameter: exists requires the plugin name
	local name=$1
	if [ -z "$name" ]; then
		return $EINVAL
	fi

	for directory in "${_directories[@]}"; do
		if [ -f "${directory}/_${name}.sh" ]; then
			return $EOK
		fi
	done		

	return $ENOENT
}

# _pragma_loaded requires the name of the plugin; it checks if a 
# plugin with the given name is already in the registry, in which
# case it returns 0; otherwise it will return 1
_pragma_loaded() {
	# validate input parameter: check requires the plugin name
	local name=$1
	if [ -z "$name" ]; then
		return $EINVAL
	fi
	for p in ${_plugins[@]}; do
		if [ "$p" == "$name" ]; then
			return $EOK
		fi
	done
	return $ENOPE
}

# _pragma_import requires the name of the plugin; it loads it from
# the $PLUGINSPATH or from ~/.plugins if not already loaded, and 
# returns the result of sourcing it into the current shell
_pragma_import() {
	# validate input parameter: import requires the plugin name
	local name=$1
	if [ -z "$name" ]; then
		return $EINVAL
	fi
	# check if already loaded, if so skip and return success
	_pragma_loaded $name
	if [ $? -eq 0 ]; then
		# plugin is already loaded
		return $EOK
	fi

	# load it from the first directory under the PLUGINSPATH
	for directory in "${_directories[@]}"; do
		if [ -f "${directory}/_${name}.sh" ]; then
			source "${directory}/_${name}.sh"
			return $?
		fi	
	done	
	# no supporting file in known locations
	return $ENOENT
}

# _pragma_stub requires the name of the plugin; it creates the stub of
# an empty plugin with a single dummy function; it also shows how to import
# other plugins by pragma import'ing the log module.
_pragma_stub() {
	local name=$1
	if [ -z "$name" ]; then
		return $EINVAL
	fi

	# get the target directory
	for directory in "${_directories[@]}"; do
		_pragma_confirm "Do you want to create the plugin under ${directory}?"
		if [ $? -eq $ENOPE ]; then
			continue
		fi
		# ok, let's try to create it here; check if it exists already
		if [ -f "${directory}/_${name}.sh" ]; then
			_pragma_confirm "A file named _${name}.sh already exists under ${directory} and will be overwritten; are you sure?"
			if [ $? -eq $ENOPE ]; then
				continue
			fi
		fi
		# ok, so we can proceed now
		cat <<EOF > "${directory}/_${name}.sh"
#! /bin/bash

pragma begin ${name}

pragma import log

#
# ${name}_test() is an example function.
#
${name}_test() {
	log_i "hallo from ${name}!"
}

pragma end ${name}

EOF

		# set file as executable
		chmod 755 "${directory}/_${name}.sh"
		return $EOK
	done	

	return $ENOPE
}

_pragma_help() {
	local arg=$1
	case $arg in
	"begin")
		echo "  pragma begin <name> is used at the top of a plugin, right before"
		echo "  declaring constants, variables and functions, to ensure that it"
		echo "  will never be sourced more than once; this makes it safe to import"
		echo "  the plugin as necessary, in each script or plugin that needs it."
		echo ""
		echo "  EXAMPLE:"
		echo "	#!/bin/bash"
		echo "	pragma begin mylib"
		echo "	function myfunc() {"
		echo "		# do something..."
		echo "	}"
		echo "	pragma end mylib"
		echo ""
		;;
	"end")
		echo "  pragma end <name> is used at the very bottom of a plugin, to actually"
		echo "  register it as an active plugin."
		echo ""
		echo "  EXAMPLE:"
		echo "	#!/bin/bash"
		echo "	pragma begin mylib"
		echo "	function myfunc() {"
		echo "		# do something..."
		echo "	}"
		echo "	pragma end mylib"
		echo ""
		;;
	"import")
		echo "  pragma import <name> is used by the plugin client, in order to"
		echo "  import the plugin variables, contants and function definitions into"
		echo "  its namespace; plugins are bash scripts located under \$PLUGINSPATH "
		echo "  (if defined) or under the user's home directory (\$HOME/.plugins)"
		echo "  or a subdirectory of the current directory (./.plugins); each plugin"
		echo "  has a name such as \"_log.sh\" for the \"log\" plugin; it is safe to"
		echo "  import the same plugin multiple times thanks to the plugin registration"
		echo "  mechanism."
		echo ""
		echo "  EXAMPLE:"
		echo "	#!/bin/bash"
		echo "	pragma import mylib"
		echo "	myfunc ARG1 ARG2"
		echo ""
		;;
	"loaded")
		echo "  pragma loaded <name> checks if the given plugin has already been loaded."
		echo ""
		;;
	"exists")
		echo "  pragma exists <name> checks if an implementation for the given plugin"
		echo "  exists under one of the supported paths."
		echo ""
		;;
	"locate")
		echo "  pragma locate <name> checks if an implementation for the given plugin"
		echo "  exists under one of the supported paths, and prints the path where it"
		echo "  was found."
		echo ""
		;;
	"list")
		echo "  pragma list prints the list of registered plugins to STDOUT."
		echo ""
		;;
	"path")
		echo "  pragma path prints the list of directories from which plugins are loaded."
		echo ""
		;;
	"reset")
		echo "  pragma reset resets the contents of the plugins registry, effectively"
		echo "  allowing for hot swapping of function defitions by reloading plugins."
		echo ""
		;;
	"stub")
		echo "  pragma stub <name> creates the stub of a new plugin."
		echo ""
		;;
	*)
		echo "usage: "
		echo "  pragma help [<arg>]"
		echo "	  prints an help message for the given sub-command"
		echo "  pragma path"
		echo "	  prints the list of directories for plugins"
		echo "  pragma reset"
		echo "	  resets the plugin registry, allowing to reload plugins"
		echo "  pragma list"
		echo "	  prints the list of all loaded plugins"
		echo "  pragma <begin|end|import|loaded|exists|locate|stub> [<name>]"
		echo "	  perfoms the given sub-command on plugin <name>"
		echo ""
		;;	
	esac
	return $EOK
}

pragma() {
	# check if an operation was specified
	local operation=$1
	if [ -z "$operation" ]; then
		_pragma_help
		return $EINVAL
	fi
	case $operation in
	"begin")
		_pragma_begin $2
		case $? in		
		$EOK	) return $OK;;
		$ENOPE  ) echo "no plugin directory defined"; return $ENOPE ;;
		$EINVAL ) _pragma_help; return $EINVAL ;;
		*	   ) return $? ;;
		esac
		;;
	"end")
		_pragma_end $2
		case $? in
		$EOK	) return $OK;;
		#$ENOPE  ) <do something>; return $ENOPE ;;
		$EINVAL ) _pragma_help; return $EINVAL ;;
		*	   ) return $? ;;
		esac
		;;
	"exists")
		_pragma_exists $2
		case $? in  
		$EOK	) return $EOK ;;
		$ENOENT ) echo "no such plugin: \"$2\""; return $ENOENT ;;
		$EINVAL ) _pragma_help; return $EINVAL ;;
		*	   ) return $? ;;
		esac
		;;
	"locate")
		_pragma_locate $2
		case $? in  
		$EOK	) return $EOK ;;
		$ENOENT ) echo "no such plugin: \"$2\""; return $ENOENT ;;
		$EINVAL ) _pragma_help; return $EINVAL ;;
		*	   ) return $? ;;
		esac
		;;
		
	"import")
		_pragma_import $2
		local ERR=$?
		case $ERR in
		$EOK	) return $OK;;
		$ENOPE  ) echo "generic error importing plugin"; return $ENOPE ;;
		$ENOENT ) echo "no such plugin: \"$2\""; return $ENOENT ;;
		$EINVAL ) _pragma_help; return $EINVAL ;;
		*	   ) echo "error sourcing plugin: $ERR"; return $ERR ;;
		esac
		;;
	"loaded")
		_pragma_loaded $2
		case $? in 
		$EOK	) return $OK;;
		$EINVAL ) _pragma_help; return $EINVAL ;;
		*	   ) return $? ;;
		esac
		;;
	"reset")
		_plugins=()
		return $EOK
		;;
	"list")
		# print out all the currently loaded plugins
		for p in ${_plugins[@]}; do
			echo $p
		done
		return $EOK			
		;;
	"path")
		_pragma_path
		return $?
		;;
	"stub")
		_pragma_stub $2
		return $?
		;;
	"help")
		_pragma_help $2
		return $?
		;;
	*)
		_pragma_help $2
		return $?
		;;
	esac
}

#
# library initialisation
#
if [ "${#_directories[@]}" -eq 0 ]; then
	# directories not initialised yet
	if [ -z "$PLUGINSPATH" ]; then
#		echo "will load from defaults" 
		if [ -d "$HOME/.plugins" ]; then
			_directories+=("$HOME/.plugins")
		fi
		if [ -d "$PWD/.plugins" ]; then
			_directories+=("$PWD/.plugins")
		fi
	else
#		echo "will load from $PLUGINSPATH"
 		while IFS=':' read -ra _tmp; do
			for d in "${_tmp[@]}"; do
          		if [ -d "$d" ]; then
					_directories+=("$d")
				fi
			done
 		done <<< "$PLUGINSPATH"
	fi
#	_pragma_path
fi