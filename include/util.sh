#!/usr/bin/env bash
#
# bytepark release manager - functions.sh
#
# (c) 2011-2016 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Global utility functions for the release script

#
# Checks the given function name for existance
#
# @return 1 on non existance, 0 otherwise
#
functionExists() {
    if [ "$(type -t $1)" == "function" ]; then
        return 0
    fi

    return 1
}

#
# Converts the given parameter to upper case
#
# @param The string to convert to upper case
#
# @return The string in upper case
#
toUpper() {
    echo -n "$(echo ${1} | tr '[:lower:]' '[:upper:]')"
}

#
# Checks if the given needle is in the given array
#
# To call one must echo the array into a local variable before, i.e.
#
# local haystack=$(echo ${theArray}[@])
# inArray "$needle" "$haystack"
#
# @param The value to look for
# @param The array to look in
#
# @return 0 when needle is in haystack, 1 otherwise
#
inArray() {
    local needle=$1
    local haystack=( $(echo "$2") )
    local element

    for element in ${haystack[@]}; do
        if [ "${element}" == "${needle}" ]; then
            return 0
        fi
    done

    return 1
}
