#!/usr/bin/env bash
#
# bytepark release manager - view.sh
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Template method interface for the release ui
#
# The following variables have to be set with the callback function
# names by view implementations.
#
# VIEW_ERROR
# VIEW_INFO
# VIEW_LIST
# VIEW_MENU
# VIEW_YES_NO
# VIEW_WAITING
# VIEW_PROGRESS
#
# The view implentation have to reside in the view subdirectory
#

# Try dialog when view is not set
if [ -z ${concreteView} ]; then
    concreteView="dialog"
fi

# fallback to prompt, dialog is not available
if [ ! `command -v dialog` ]; then
    concreteView="prompt"
fi

. ${releaseIncludepath}/view/${concreteView}.sh

view_error() {
    $VIEW_ERROR "$1"
}

view_info() {
    $VIEW_INFO "$1"
}

view_list() {
    $VIEW_LIST "$1" "$2" "$3"
}

view_menu() {
    $VIEW_MENU "$1" "$2" "$3" "$4"
}

view_yes_no() {
    $VIEW_YES_NO "$1" "$2"
}

view_waiting() {
    $VIEW_WAITING "$1" "$2"
}

view_progress() {
    $VIEW_PROGRESS "$1" "$2"
}
