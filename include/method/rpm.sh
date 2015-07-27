#!/bin/bash

#
# script to create a rpm suiting the deployment strategy of
# the ImmobilienScout 24 GmbH
#
# enhanced to use dialog and be generic
#
# (c) bytepark GmbH, 2011-2013

function_post_source() {
    # exit if we are not on a system capable of creating rpm packages
    # or no build host is configured
    if [ -z ${OSPKG} ] || [ "${OSPKG}" != "rpm" ]; then
        if [ -z ${BUILD_HOST} ]; then
            fn_dialog_error "You can not create a rpm package on ${OS}. Sorry. Exiting.\n"
            exit
        fi
    fi

    # exit if we do not find a .release/rpm folder
    if [ ! -d ${PROJECT_CONFIG_DIR}/rpm ]; then
        fn_dialog_error "You do not have a rpm folder in your .release directory.\n\nThe release tool has changed some directory and file locations as well as some variable names.\nRefer to https://faq.bytenetz.de/development/release-tool/.\n\nAborting."
        exit
    fi

    # deploy to repo server ?
    if [ -z ${UPDATEREPO} ]; then
        fn_dialog_yesorno "Deploy to the bytepark yum repository? (Y/n)"
        if [ "$RETURN" = "0" ]; then
            UPDATEREPO="No"
        else
            UPDATEREPO="Yes"
        fi
    fi

    # go to the temporary directory
    function_create_tempdir

    if [ ${GITREVISION_BRANCH} ]; then
        RELEASETAG=${DATESHORT}_${RELEASETAG}
    fi

    OUTPUTFILE=${BUILDPATH}/${RPMNAME}-${RELEASETAG}.tar.gz
    BUILD_CONFIG_DIR="${BUILDPATH}/${RPMNAME}-${RELEASETAG}/.release/rpm"
}

function_dispatch() {

    # user func hook
    function_exists function_clone_pre && function_clone_pre

    # get the repo
    function_git_dispatch "${RPMNAME}-${RELEASETAG}"

    fn_dialog_info "Integrating metadata into spec file"

    # set default ARCHITECTURE if it is not given
    if [ -z $ARCHITECTURE ]; then
        ARCHITECTURE="noarch"
    fi

    sed -i "s/%RELEASETAG%/$RELEASETAG/" ${BUILD_CONFIG_DIR}/$SPECFILE
    sed -i "s/%ARCHITECTURE%/$ARCHITECTURE/" ${BUILD_CONFIG_DIR}/$SPECFILE
    cat ${BUILD_CONFIG_DIR}/CHANGELOG >> ${BUILD_CONFIG_DIR}/$SPECFILE
    # @todo - exit if no CHANGELOG found

    #user func hook
    function_exists function_clone_post && function_clone_post

    # no more git after here
    function_remove_gitfiles

    # save the specfile before cleanup
    cp ${BUILD_CONFIG_DIR}/$SPECFILE ${BUILDPATH}/$SPECFILE
    # @todo - exit, if no specfile found

    # auto cleanup
    function_remove_releasefiles

    # create tarball
    cd ${BUILDPATH}
    fn_dialog_waitingbox "tar -c ${RPMNAME}-${RELEASETAG} | gzip -c > ${OUTPUTFILE}" "Creating tarball for rpm build"

    # user func hook
    function_exists function_tarball_post && function_tarball_post

    # check for rpm build location
    if [ ${BUILD_HOST} ]; then
        method_build_remote
    else
        method_build_local
    fi

    if [ "${UPDATEREPO}" = "Yes" ]; then
        fn_dialog_info "Publishing release on yum repo server"
        scp ${BUILDPATH}/${RPMNAME}-${RELEASETAG}*.rpm $YUMREPOUSER@$YUMREPOHOST:$YUMREPOPATH/$RPMNAME 1> /dev/null 2>> ${ERRORLOG}
        ssh $YUMREPOUSER@$YUMREPOHOST "createrepo --update $YUMREPOPATH" 1> /dev/null 2>> ${ERRORLOG}

        # TESTING. FIXME. REMOVE THIS!
        #ssh $YUMREPOUSER@$YUMREPOHOST "rm $YUMREPOPATH/$RPMNAME/${RPMNAME}-${RELEASETAG}*.rpm"
        #ssh $YUMREPOUSER@$YUMREPOHOST "echo > $YUMREPOPATH/$RPMNAME/${RPMNAME}-${RELEASETAG}*.rpm"

        # Exit if file was not uploaded at all.
        function_exit_if_remotefile_does_not_exist "$YUMREPOUSER@$YUMREPOHOST" "$YUMREPOPATH/$RPMNAME/${RPMNAME}-${RELEASETAG}*.rpm"

        # Exit if file was not uploaded completely (different fize sizes).
        function_exit_if_localfile_and_remotefile_not_same_size "${BUILDPATH}/${RPMNAME}-${RELEASETAG}*.rpm" "$YUMREPOUSER@$YUMREPOHOST" "$YUMREPOPATH/$RPMNAME/${RPMNAME}-${RELEASETAG}*.rpm"

        METHOD_CUSTOM_COMPLETE="\n\nThe rpm package ist published in the yum repository "
    else
        mv ${BUILDPATH}/${RPMNAME}-${RELEASETAG}*.rpm ${PROJECT_PATH}
        METHOD_CUSTOM_COMPLETE="\n\nThe rpm package file is located in your current directory"
    fi
}

method_post_gitbranch_pull() {
    fn_dialog_info "Setting Release in spec and pushing to repository."
    FILE=${BUILDPATH}/${RPMNAME}-${RELEASETAG}/.release/rpm/$SPECFILE
    awk '/Release:/ { sub(/[0-9]+/, int(substr($0, match($0, /[0-9]+/), length()))+1)};{ print }' ${FILE} > $FILE.new
    mv $FILE.new $FILE
    git add -u 1> /dev/null 2>> ${ERRORLOG}
    git commit -m "[RELEASE] Incremented Release in spec file ${SPECFILE}." 1> /dev/null 2>> ${ERRORLOG}
    git push origin ${GITREVISION} 1> /dev/null 2>> ${ERRORLOG}
}

method_post_gittag_checkout() {
    FILE=${BUILDPATH}/${RPMNAME}-${RELEASETAG}/.release/rpm/$SPECFILE
    awk '/Release:/ { sub(/[0-9]+/, int(substr($0, match($0, /[0-9]+/), length()))+1)};{ print }' ${FILE} > $FILE.new
    mv $FILE.new $FILE
    git add -u 1> /dev/null 2>> ${ERRORLOG}
    git commit -m "[RELEASE] Incremented Release in spec file ${SPECFILE}." 1> /dev/null 2>> ${ERRORLOG}
    git push origin ${GITREVISION} 1> /dev/null 2>> ${ERRORLOG}
}

method_build_remote() {
    fn_dialog_info "Copying and building rpm file on host $BUILD_HOST"
    # prepare remote dir
    ssh $BUILD_HOST_USER@$BUILD_HOST "rm -f $BUILD_HOST_PATH/${SPECFILE}; rm -f $BUILD_HOST_PATH/rpmbuild/SOURCES/$RPMNAME*; rm -Rf $BUILD_HOST_PATH/rpmbuild/BUILD/$RPMNAME*" 1> /dev/null 2>> ${ERRORLOG}
    # put the tar and spec file on the vm
    scp $OUTPUTFILE $BUILD_HOST_USER@$BUILD_HOST:$BUILD_HOST_PATH/rpmbuild/SOURCES/ 1> /dev/null 2>> ${ERRORLOG}
    scp ${BUILDPATH}/$SPECFILE $BUILD_HOST_USER@$BUILD_HOST:$BUILD_HOST_PATH 1> /dev/null 2>> ${ERRORLOG}
    # ... and build
    ssh $BUILD_HOST_USER@$BUILD_HOST "cd $BUILD_HOST_PATH; rpmbuild -bb $SPECFILE;" 1> /dev/null 2>> ${ERRORLOG}
    # clean up
    scp $BUILD_HOST_USER@$BUILD_HOST:$BUILD_HOST_PATH/rpmbuild/RPMS/$ARCHITECTURE/$RPMNAME-$RELEASETAG*.rpm . 1> /dev/null 2>> ${ERRORLOG}
    ssh $BUILD_HOST_USER@$BUILD_HOST " rm -f $BUILD_HOST_PATH/rpmbuild/RPMS/$ARCHITECTURE/$RPMNAME-$RELEASETAG*.rpm; " 1> /dev/null 2>> ${ERRORLOG}
}

method_build_local() {
    cd ${BUILDPATH}
    mkdir -p ~/rpmbuild/SOURCES
    cp $OUTPUTFILE ~/rpmbuild/SOURCES
    fn_dialog_progressbox "rpmbuild -bb ${SPECFILE} 2>> ${ERRORLOG}"
    RPM="$HOME/rpmbuild/RPMS/$ARCHITECTURE/$RPMNAME-$RELEASETAG*.rpm"

    if [ ! -e $RPM ]; then
        exit 1
    fi

    cp $RPM ${BUILDPATH}
}
