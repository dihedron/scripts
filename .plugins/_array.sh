#! /bin/bash

pragma begin array


#
# array_size() returns the size of the array passed as input;
# to pass in an array use:
# /> ARRAY=("one" "two" "three")
# /> array_size "${ARRAY[@]}"
#
array_size() {
	local array=("$@")
	echo "${#array[@]}"
}

#
# array_length() returns the size of the array passed as input;
# to pass in an array use:
# /> ARRAY=("one" "two" "three")
# /> array_length "${ARRAY[@]}"
#
array_length() {
	local array=("$@")
	echo "${#array[@]}"
}

#
# array_has_exactly() expects a number and an array; it checks if the
# array size is exactly the number given.
#
array_has_exactly() {
	local expected=$1
	shift
	local actual=$(array_size $@)
	if [ $expected -ne $actual ]; then
		return 1
	fi
}

#
# array_has_at_least() expects a number and an array; it checks if the
# array size is greater than or equal to the number given; usage:
# /> ARRAY=("one" "two" "three")
# /> array_has_at_least 2 "${ARRAY[@]}"
#
array_has_at_least() {
	local expected=$1
	shift
	local actual=$(array_size $@)
	if [ $actual -lt $expected ]; then
		return 1
	fi
}

#
# array_has_at_most() expects a number and an array; it checks if the
# array size is lesser than or equal to the number given; usage:
# /> ARRAY=("one" "two" "three")
# /> array_has_at_most 4 "${ARRAY[@]}"
#
array_has_at_most() {
	local expected=$1
	shift
	local actual=$(array_size $@)
	if [ $actual -gt $expected ]; then
		return 1
	fi
}

pragma end array

