#!/bin/bash

#
# this script implements the bytepark release manager
#
VERSION="%VERSION%"

#
# bytepark release manager
#
# (c) bytepark GmbH
# started 07/2011
#
# some vars
DATE=`/bin/date +"%d.%m.%Y %H:%M"`
DATESHORT=`/bin/date +"%Y%m%d%H%M"`
BASE=`dirname $0`
BATCHMODE=0
FORCE=0
DO_MYSQL_DUMP=0
ERRORLOG="$(pwd)/release.errors.log"

rm -f ${ERRORLOG}

if [ "$BASE" = "/usr/bin" ]; then
        BASE=/var/release
fi
if [ "$BASE" = "/usr/local/bin" ]; then
        BASE=/opt/bytepark-release
fi

# include functions and dialog methods as well as getopts
source ${BASE}/include/functions.sh
source ${BASE}/include/getopts.sh
source ${BASE}/include/dialog.sh

# determine OS, project folder and path settings
function_determine_os
function_determine_projectname_and_paths
# check that all needed tools are available
function_check_tools

if [ "${BATCHMODE}" = "1" ]; then
    BATCH_CONFIG_TO_USE="${METHOD_NAME}.${TARGET_NAME}.conf"
    if [ ! -f ${CONFIG_DIR}/${BATCH_CONFIG_TO_USE} ]; then
        echo "Release configuration ${BATCH_CONFIG_TO_USE} not found. Aborting."
        exit
    fi

    source ${CONFIG_DIR}/${BATCH_CONFIG_TO_USE}
else
# determine project type - do we really need this????
    function_determine_projecttype

# determine configured methods
    function_determine_available_configs

# function what to do (method)
    function_whattodo

# function where to go (target)
    function_wheretogo

# source the specific config (from .release)
    function_source_config
fi

# function for git setup (tag/branch)
    function_setup_git

# source the needed method file (from include)
    function_source_method

# ask whether to make a mysql dump (question will only be asked if MYSQL_* config parameters are given)
    function_ask_for_mysql_dump

# show summary
if [ $FORCE = 0 ]; then
    function_summary
fi

# run mysql dump/import if DO_MYSQL_DUMP=1
if [ ${DO_MYSQL_DUMP} -eq 1 ]; then
    function_mysql_dump
fi

# and of we go (dispatch of sourced method)
function_exists function_dispatch && function_dispatch

# check if $ERRORLOG file exists and show it's content if it does.
# exit process with a non-succesful return code.
function_show_errorlog ${BATCHMODE}

fn_dialog_info "Release completed.${METHOD_CUSTOM_COMPLETE}"
sleep 3
clear
exit 0
