#!/bin/bash

function_post_source() {
    RSYNC_FILES_DIR="${PROJECT_CONFIG_DIR}/rsync"

    # check whether a rsync_exclude exists
    if [ -z $RSYNC_EXCLUDE ] && [ -d "${RSYNC_FILES_DIR}" ]; then
        if [ -f ${RSYNC_FILES_DIR}/exclude_${TARGET_NAME}.conf ]; then
            OPT_RSYNC_EXCLUDE=" --exclude-from=${RSYNC_FILES_DIR}/exclude_${TARGET_NAME}.conf "
        else
            fn_dialog_error "No rsync exclude file found in directory '.release/rsync'.\n\nThe release tool has changed some directory and file locations as well as some variable names.\nRefer to https://faq.bytenetz.de/development/release-tool/.\n\nAborting."
            exit
        fi
    else
        if [ -f ${RSYNC_FILES_DIR}/$RSYNC_EXCLUDE ]; then
            OPT_RSYNC_EXCLUDE=" --exclude-from=${RSYNC_FILES_DIR}/${RSYNC_EXCLUDE}"
        else
            fn_dialog_error "No rsync exclude file found in directory '.release/rsync'.\n\nThe release tool has changed some directory and file locations as well as some variable names.\nRefer to https://faq.bytenetz.de/development/release-tool/.\n\nAborting."
            exit
        fi
    fi
}

function_dispatch() {
    #user func
    functionExists function_rsync_pre && function_rsync_pre

    # dump TODO includes/excludes
    # check whether a rsync_exclude/rsync_include exists
    if [ -z $SSHPORT ]; then
        SSHPORT=22
    fi

    # make a mysql dump on remote
    function_mysqldump_remote

    # synchronize files
    fn_dialog_progressbox "rsync -q --delete ${OPT_RSYNC_EXCLUDE} -az -e \"ssh -p ${SSHPORT}\" $SSHUSER@$SSHHOST:$REMOTEPATH ."

    #user func
    functionExists function_rsync_post && function_rsync_post
}
