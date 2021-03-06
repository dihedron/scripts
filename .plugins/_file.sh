#! /bin/bash

pragma begin file

pragma import array

#
# file_exists() checks if a file exists.
#
file_exists() {
	array_has_exactly 1 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local file=$1
	if [ -f ${file} ]; then
		return 0
	fi
	return 1
}

#
# file_backup() performs the backup of the given file; if a backup already 
# exists or the original file does not exist, it does nothing an exits with 
# an error.
#
file_backup() {
	array_has_exactly 1 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local src="$1"
	local dst="${src}.orig"
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		return 2
	fi

	cp -p "${src}" "${dst}"
	return $?
}

#
# file_backup_to() performs the backup of the given file under the given name; if 
# the original file does not exist or the backup file exists already, it does nothing 
# and exits with an error.
#
file_backup_to() {
	array_has_exactly 2 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local src=$1
	local dst=$2
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		return 2
	fi

	cp -p "${src}" "${dst}"
	return $?
}


#
# file_backup_force() performs the backup of the given file; if the original file 
# does not exist, it does nothing an exits with an error.
#
file_backup_force() {
	array_has_exactly 1 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local src=$1
	local dst="${src}.orig"
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		# preserve owner, group, access bits
		cat "${src}" > "${dst}"
	else		
		cp -p "${src}" "${dst}"
	fi

	return $?
}

#
# file_backup_force_as() performs the backup of the given file under the given name; if 
# the original file does not exist, it does nothing an exits with an error.
#
file_backup_force_to() {
	array_has_exactly 2 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local src=$1
	local dst=$2
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		# preserve owner, group, access bits
		cat "${src}" > "${dst}"
	else	
		cp -p "${src}" "${dst}"
	fi
	
	return $?
}

#
# file_restore() restores a file from its backup copy; if the backup copy does not exist
# or the original file exists already, an error code is returned.
#
file_restore() {
	array_has_exactly 1 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local dst=$1
	local src="${dst}.orig"
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		return 2
	fi

	mv "${src}" "${dst}"
	return $?
}

#
# file_restore_from() restores a file from a backup copy, given both names; if the backup 
# copy does not exist or the original file exists already, an error code is returned.
#
file_restore_from() {
	array_has_exactly 2 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local dst=$1
	local src=$2
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		return 2
	fi

	mv "${src}" "${dst}"
	return $?
}

#
# file_restore_force() restores a file from its backup copy; if the backup copy does not
# exist, an error code is returned.
#
file_restore_force() {
	array_has_exactly 1 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local dst=$1
	local src="${dst}.orig"
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		# preserve owner, group, access bits
		cat "${src}" > "${dst}"
	else
		mv "${src}" "${dst}"
	fi	

	return $?
}

#
# file_restore_force_from() restores a file from a backup copy, given both names; if 
# the backup copy does not exist, an error code is returned.
#
file_restore_force_from() {
	array_has_exactly 2 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local dst=$1
	local src=$2
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		# preserve owner, group, access bits
		cat "${src}" > "${dst}"		
	else
		mv "${src}" "${dst}"
	fi
	return $?
}

#
# file_install_as() installs a file to a new name by copying its contents; the source 
# file must exist and the destination file must not, otherwise it will fail with an error.
#
file_install_as() {
	array_has_exactly 2 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local src=$1
	local dst=$2
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		return 2
	fi

	cp -p "${src}" "${dst}"
	return $?
}

#
# file_install_force_as() installs a file to a new name by copying its contents; 
# the source file must exist, otherwise it will fail with an error.
#
file_install_force_as() {
	array_has_exactly 2 $@
	if [ $? -ne 0 ]; then
		return 1
	fi
	
	local src=$1
	local dst=$2
	file_exists "${src}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	file_exists "${dst}"
	if [ $? -eq 0 ]; then
		cat "${src}" > "${dst}"
	else
		cp -p "${src}" "${dst}"
	fi
	
	return $?
}

pragma end file

