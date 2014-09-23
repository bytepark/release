#!/bin/bash

#
# script to do a deploy to a remote site
# (c) bytepark GmbH, 2011
# v0.1
function_post_source() {
    # go to the temporary directory
    function_create_tempdir

    RSYNC_FILES_DIR="${CONFIG_DIR}/rsync"

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
    #user func hook
    function_exists function_clone_pre && function_clone_pre

    # get the repo
    function_git_dispatch "${RELEASETAG}"

    #user func hook
    function_exists function_clone_post && function_clone_post

    # delete gitconfigs
    function_remove_gitfiles

    # set standard ssh port when not defined
    if [ -z $SSHPORT ]; then
        SSHPORT=22
    fi
    # auto cleanup
    function_remove_releasefiles

    # count files in temp directory and exit here if number seems to little
    FILECNT=`find . | wc -l`
    if [ "$FILECNT" -lt "5" ]; then
        fn_dialog_error "Something seems to have gone wrong while doing git clone. Temp Directory seems rather empty. You'd better have a look for yourself."
        exit
    fi

    fn_dialog_info "rsync"
    if [ $REMOTESUDO ]; then
        rsync --rsync-path="sudo rsync" -q --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant --exclude=backup/ ${OPT_RSYNC_EXCLUDE} -avz -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH 1> /dev/null 2>> ${ERRORLOG}
    else
        #rsync -q --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=backup/ --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant ${OPT_RSYNC_EXCLUDE} -avz -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH
    rsync -q --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=backup/ --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant ${OPT_RSYNC_EXCLUDE} -avz -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH 1> /dev/null 2>> ${ERRORLOG}
    fi

    #user func
    function_exists function_rsync_post && function_rsync_post
}
