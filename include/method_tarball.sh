#!/bin/bash

#
# script to create a tarball
# (c) bytepark GmbH, 2011
function_post_source() {
    # go to the temporary directory
    function_create_builddir

    # set default tarball file name if it is not given
    if [ -z $OUTPUTFILE ]; then
        OUTPUTFILE=${DEPLOYPATH}/${DATESHORT}_${PROJECT}_${RELEASETAG}.tar.gz
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

    # auto cleanup
    function_remove_releasefiles

    # create tarball
    fn_dialog_info "Creating tarball"
    # cd .. we didn't have a folder in tars until know
    #tar -c ${FOLDER} | gzip -c > ${OUTPUTFILE}
    tar -c . | gzip -c > ${OUTPUTFILE}

    fn_dialog_info "Moving tarball to project directory"
    mv ${OUTPUTFILE} ${PROJECTPATH}

    #user func
    function_exists function_tarball_post && function_tarball_post
}