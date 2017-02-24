#!/bin/bash

function_post_source() {
    RSYNC_FILES_DIR="${CONFIG_DIR}/rsync"
    OPT_RSYNC_EXCLUDE=""

    # check whether a rsync_exclude exists
    if [ -z $RSYNC_EXCLUDE ] && [ -d "${RSYNC_FILES_DIR}" ]; then
        if [ -f ${RSYNC_FILES_DIR}/exclude_${TARGET_NAME}.conf ]; then
            OPT_RSYNC_EXCLUDE=" --exclude-from=${RSYNC_FILES_DIR}/exclude_${TARGET_NAME}.conf "
        fi
    else
        if [ -f ${RSYNC_FILES_DIR}/$RSYNC_EXCLUDE ]; then
            OPT_RSYNC_EXCLUDE=" --exclude-from=${RSYNC_FILES_DIR}/${RSYNC_EXCLUDE}"
        fi
    fi

    OPT_RSYNC_ICONV=""
    if [ -n ${RSYNC_ENC_LOCAL+1} ] && [ -n ${RSYNC_ENC_REMOTE+1} ]; then
        OPT_RSYNC_ICONV="--iconv=${RSYNC_ENC_LOCAL},${RSYNC_ENC_REMOTE}"
    fi
}

function_dispatch() {
    #user func
    function_exists function_rsync_pre && function_rsync_pre

    # dump TODO includes/excludes
    # check whether a rsync_exclude/rsync_include exists
    if [ -z $SSHPORT ]; then
        SSHPORT=22
    fi

    # make a mysql dump on remote
    function_mysqldump_remote

    # synchronize files
    fn_dialog_progressbox "rsync -q ${OPT_RSYNC_ICONV} --delete ${OPT_RSYNC_EXCLUDE} -az -e \"ssh -p ${SSHPORT}\" $SSHUSER@$SSHHOST:$REMOTEPATH ."

    #user func
    function_exists function_rsync_post && function_rsync_post
}
