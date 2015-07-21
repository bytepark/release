#!/usr/bin/env bash
#
# bytepark release manager
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Started 07/2011 as a rsync wrapper script ;-)
#

SCRIPT_VERSION="3.0.0-alpha-1"

# where are we located
SCRIPT_FILEPATH=`realpath $0`
SCRIPT_PATH=`dirname ${SCRIPT_FILEPATH}`
if [ "${SCRIPT_PATH}" = "/usr/bin" ]; then
        SCRIPT_PATH=/var/release
fi
if [ "${SCRIPT_PATH}" = "/usr/local/bin" ]; then
        SCRIPT_PATH=/opt/release
fi
SCRIPT_INCLUDEPATH="${SCRIPT_PATH}/include"

# bootstrap and base sourcing
. ${SCRIPT_INCLUDEPATH}/bootstrap.sh

if [ "${BATCHMODE}" = "1" ]; then
    BATCH_CONFIG_TO_USE="${METHOD_NAME}.${TARGET_NAME}.conf"
    if [ ! -f ${CONFIG_DIR}/${BATCH_CONFIG_TO_USE} ]; then
        echo "Release configuration ${BATCH_CONFIG_TO_USE} not found. Aborting."
        exit 12
    fi

    . ${CONFIG_DIR}/${BATCH_CONFIG_TO_USE}
#else
## determine configured methods
#    function_determine_available_configs
#
## function what to do (method)
#    function_whattodo
#
## function where to go (target)
#    function_wheretogo
#
## source the specific config (from .release)
#    function_source_config
fi
#
## function for git setup (tag/branch)
#    function_setup_git
#
## source the needed method file (from include)
#    function_source_method
#
## ask whether to make a mysql dump (question will only be asked if MYSQL_* config parameters are given)
#    function_ask_for_mysql_dump
#
## show summary
#if [ $FORCE = 0 ]; then
#    function_summary
#fi
#
## run mysql dump/import if DO_MYSQL_DUMP=1
#if [ ${DO_MYSQL_DUMP} -eq 1 ]; then
#    function_mysql_dump
#fi
#
## and of we go (dispatch of sourced method)
#function_exists function_dispatch && function_dispatch
#
## check if $ERRORLOG file exists and show it's content if it does.
## exit process with a non-succesful return code.
#function_show_errorlog ${BATCHMODE}
#
#fn_dialog_info "Release completed.${METHOD_CUSTOM_COMPLETE}"
#sleep 3
#clear

exit 0
