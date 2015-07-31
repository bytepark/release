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
inBatchMode=0
inSilentMode=0
DO_MYSQL_DUMP=0
ERRORLOG="$(pwd)/release.errors.log"
PROJECT=""
PROJECT_PATH=""
PROJECT_CONFIG_DIR=""

REQUIRED_TOOLS="basename clear cut dirname expr find git getopts grep ls mkdir rm rsync sed ssh tr tac"

# source the base functionality
. ${releaseIncludepath}/util.sh
. ${releaseIncludepath}/view.sh
. ${releaseIncludepath}/functions.sh

checkForTools $REQUIRED_TOOLS
initializeProject

. ${releaseIncludepath}/getopts.sh

parseForOptions $@

. ${releaseIncludepath}/method.sh
. ${releaseIncludepath}/origin.sh
