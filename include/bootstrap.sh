#!/usr/bin/env bash
#
# bytepark release manager - bootstrap.sh
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Bootstrapping of the release manager

# Some global variables
DATE=`/bin/date +"%d.%m.%Y %H:%M"`
DATESHORT=`/bin/date +"%Y%m%d%H%M"`
BATCHMODE=0
FORCE=0
DO_MYSQL_DUMP=0
ERRORLOG="$(pwd)/release.errors.log"

REQUIRED_TOOLS="basename clear cut dirname expr find git getopts grep ls mkdir rm rsync sed ssh tr tac"

# source the base functionality
. ${SCRIPT_INCLUDEPATH}/view.sh
. ${SCRIPT_INCLUDEPATH}/functions.sh

checkTools $REQUIRED_TOOLS
function_determine_projectname_and_paths

. ${SCRIPT_INCLUDEPATH}/getopts.sh
. ${SCRIPT_INCLUDEPATH}/method.sh
. ${SCRIPT_INCLUDEPATH}/origin.sh
