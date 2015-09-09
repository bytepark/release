#!/bin/bash

#
# script to do a deploy to a remote site
# (c) bytepark GmbH, 2011
# v0.1
function_post_source() {
    # go to the temporary directory
    function_create_builddir

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

    function_exists function_build_workspace && function_build_workspace

    cp -R ${WORKSPACEPATH}/* ${DEPLOYPATH}
    cd ${DEPLOYPATH}

    function_exists function_build_deploy && function_build_deploy

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
    if [ "$RSYNC_DO_DRY_RUN" = "1" ]; then
		if [ $REMOTESUDO ]; then
			rsync --rsync-path="sudo rsync" --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant --exclude=backup/ ${OPT_RSYNC_EXCLUDE} -avzn -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH > /tmp/rsync-output
		else
			rsync --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=backup/ --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant ${OPT_RSYNC_EXCLUDE} -avzn -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH > /tmp/rsync-output
		fi

		DELETECOUNT=$(grep -c "deleting" /tmp/rsync-output)
		sed -i '/deleting/b;/.*/d' /tmp/rsync-output
		if ! [ -z $RSYNC_DONT_DELETE_MORE_THAN ]; then
			if [ "$DELETECOUNT" -gt "$RSYNC_DONT_DELETE_MORE_THAN" ]; then
				fn_dialog_error "Aborting. Too much deletions. Rsync configuration may be wrong. See /tmp/rsync-output."
				clear
				exit
			fi
		fi
		fn_dialog_yesorno "Rsync will delete ${DELETECOUNT} Files(output in /tmp/rsync-output). Proceed with Rsync?"
		if [ "$RETURN" = "0" ]; then
			fn_dialog_info "Aborting."
			clear
			exit
		fi
	else
		rm -f /tmp/rsync-output
	fi
    if [ $REMOTESUDO ]; then
        rsync --rsync-path="sudo rsync" -q --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant --exclude=backup/ ${OPT_RSYNC_EXCLUDE} -avz -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH 1> /dev/null 2>> ${ERRORLOG}
    else
        #rsync -q --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=backup/ --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant ${OPT_RSYNC_EXCLUDE} -avz -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH
    rsync -q --delete --exclude=.release --exclude=.ssh --exclude=.gitignore --exclude=.git --exclude=backup/ --exclude=.puppet --exclude=Vagrantfile --exclude=.vagrant ${OPT_RSYNC_EXCLUDE} -avz -e "ssh -p ${SSHPORT}" . $SSHUSER@$SSHHOST:$REMOTEPATH 1> /dev/null 2>> ${ERRORLOG}
    fi

    #user func
    function_exists function_rsync_post && function_rsync_post
}
