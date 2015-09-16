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

RELEASE_VERSION="3.0.0-alpha-1"

normalizedPath() {
if [ -h $1 ]; then
    echo $(cd $(dirname $(readlink $1)); pwd)
else
    echo $(cd $(dirname $1); pwd)
fi
}

release() {
    # where are we located
    local releasePath=$(normalizedPath "$0")
    if [ "${releasePath}" = "/usr/bin" ]; then
            releasePath=/var/release
    fi
    if [ "${releasePath}" = "/usr/local/bin" ]; then
            releasePath=/opt/release
    fi
    local releaseIncludepath="${releasePath}/include"
    local releaseMethod
    local releaseTarget

    # bootstrap and base sourcing
    . ${releaseIncludepath}/bootstrap.sh

    # Not in batch mode, i.e. we have to ask for the method and target
    if [ $inBatchMode -eq 0 ]; then
        local availableMethods
        local availableMethodCount
        local availableTargets
        local availableTargetCount
        parseConfiguredMethods
        local availableMethodsArray=$(echo ${availableMethods[@]})
        askForMethod "${availableMethodCount}" "$availableMethodsArray"
        parseTargetsForMethod ${releaseMethod}
        local availableTargetsArray=$(echo ${availableTargets[@]})
        askForTarget "${availableTargetCount}" "${availableTargets}"
    fi
    # load the project secific configuration (from .release)
    loadConfiguration ${releaseMethod} ${releaseTarget}

    # setup the origin
    local originToLoad=${ORIGIN}
    setupOrigin ${originToload}
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
    #if [ $inSilentMode = 0 ]; then
    #    function_summary
    #fi
    #
    ## run mysql dump/import if DO_MYSQL_DUMP=1
    #if [ ${DO_MYSQL_DUMP} -eq 1 ]; then
    #    function_mysql_dump
    #fi
    #
    ## and of we go (dispatch of sourced method)
    #functionExists function_dispatch && function_dispatch
    #
    ## check if $ERRORLOG file exists and show it's content if it does.
    ## exit process with a non-succesful return code.
    #function_show_errorlog ${inBatchMode}
    #
    #fn_dialog_info "Release completed.${METHOD_CUSTOM_COMPLETE}"
    #sleep 3
    #clear

    exit 0
}

release $@
