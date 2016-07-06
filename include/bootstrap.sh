#!/usr/bin/env bash
#
# bytepark release manager - bootstrap.sh
#
# (c) 2011-2016 bytepark GmbH
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
#concreteView="prompt"
REQUIRED_TOOLS="basename clear cut dirname expr find git getopts grep ls mkdir rm rsync sed ssh tr tac"

# source the base functionality
. ${releaseIncludePath}/util.sh
. ${releaseIncludePath}/view.sh
. ${releaseIncludePath}/guard.sh
. ${releaseIncludePath}/functions.sh

checkForTools $REQUIRED_TOOLS
initializeProject

. ${releaseIncludePath}/getopts.sh

parseForOptions $@

. ${releaseIncludePath}/method.sh
. ${releaseIncludePath}/origin.sh
