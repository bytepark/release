#!/usr/bin/env bash
#
# bytepark release manager - guard.sh
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Global guarding functions for the release script

#
# Checks the first parameter for emptyness and exits with the given
# error code and message on failing
#
guardEmptyOrExitWithError() {
    if [ ! -z "${1}" ]; then
        view_error "${3}"
        exit $2
    fi

    return 0
}

#
# Checks the first parameter for non-emptyness and exits with the given
# error code and message on failing
#
guardNonEmptyOrExitWithError() {
    if [ -z "${1}" ]; then
        view_error "${3}"
        exit $2
    fi

    return 0
}

#
# Executes the first parameter and exits with the given
# error code and message on failing
#
guardSuccessfulCallOrExitWithError() {
   `${1} > /dev/null 2>&1`

   if [ $? -ne 0 ]; then
        view_error "${3}"
        exit $2
    fi

    return 0
}
