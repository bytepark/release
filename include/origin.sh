#!/usr/bin/env bash
#
# bytepark release manager - origin.sh
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Template interface for the release origin
#
# The following variables have to be set with the callback function
# names by view implementations.
#
# ORIGIN_SETUP
#
# The origin implentations have to reside in the origin subdirectory
#

setupOrigin () {
    local origin=$1
    if [ ! -f "${releaseIncludepath}/origin/${origin}.sh" ]; then
        view_error "The origin '${origin}' is not available"
        exit 60
    fi

    . ${releaseIncludepath}/origin/${origin}.sh

    $ORIGIN_SETUP
}
