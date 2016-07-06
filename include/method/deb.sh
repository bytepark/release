#!/usr/bin/env bash

#
# script to create a debian package
# (c) bytepark GmbH, 2012

function_post_source() {
    # exit if we are not on a system capable of creating deb packages
    # or no build host is configured
    if [ -z ${OSPKG} ] || [ "${OSPKG}" != "deb" ]; then
        if [ -z ${BUILD_HOST} ]; then
            fn_dialog_error "You can not create a Debian package on ${OS}. Sorry. Exiting.\n"
            exit
        fi
    fi

    # exit if we do not find a .release/debian folder
    if [ ! -d ${PROJECT_CONFIG_DIR}/debian ]; then
        fn_dialog_error "You do not have a .debian folder in your app root.\n\nThe release tool has changed some directory and file locations as well as some variable names.\nRefer to  https://faq.bytenetz.de/development/release-tool/.\n\nAborting."
        exit
    fi

    # deploy to repo server?
    if [ -z ${UPDATEREPO} ]; then
        fn_dialog_yesorno "Deploy to the bytepark apt repository? (Y/n)"
        if [ "$RETURN" = "0" ]; then
            UPDATEREPO="No"
        else
            UPDATEREPO="Yes"
        fi
    fi

    # go to the temporary directory
    function_create_tempdir
}

function_dispatch() {
    #user func hook
    functionExists function_clone_pre && function_clone_pre

    # export the current trunk
    mkdir -p debian/DEBIAN
    mkdir -p debian/usr/share/doc/${DEBNAME}
    mkdir -p debian/${APPROOT}
    # do the cloning

    function_git_dispatch "debian/${APPROOT}"

    #user func hook
    functionExists function_clone_post && function_clone_post

    # no more git after here
    function_remove_gitfiles


    fn_dialog_info "Preparing build"
    # move debian files
    cd ${BUILDPATH}/debian
    # move everything else into their directories
    mv ${APPROOT}/.release/debian/files/* ./ 1> /dev/null 2>> ${ERRORLOG}
    rm -rf ${APPROOT}/.release/debian/files
    # now move doc files
    mv ${APPROOT}/.release/debian/copyright* usr/share/doc/${DEBNAME}/
    mv ${APPROOT}/.release/debian/changelog* usr/share/doc/${DEBNAME}/
    # move control files
    mv ${APPROOT}/.release/debian/control DEBIAN/
    # set debian version
    if [ $DEBNAMESUFFIX ]; then
        RELEASETAG=${DEBNAMESUFFIX}-${RELEASETAG}
    fi

    # set default ARCHITECTURE if it is not given
    if [ -z $ARCHITECTURE ]; then
        ARCHITECTURE="amd64"
    fi

    /bin/sed -i "s/%SCRIPT_VERSION%/${RELEASETAG}/" DEBIAN/control
    /bin/sed -i "s/%ARCHITECTURE%/${ARCHITECTURE}/" DEBIAN/control
    # now move everything else
    chmod 755 ${APPROOT}/.release/debian/*
    mv ${APPROOT}/.release/debian/* DEBIAN/
    # now we can delete the DEBIAN folder
    rm -rf ${APPROOT}/.release/debian

    # auto cleanup
    cd ${APPROOT}
    function_remove_releasefiles

    # now package it
    cd ${BUILDPATH}

    #user hook deb_pre
    functionExists function_deb_pre && function_deb_pre

    # packaging
    gzip --best debian/usr/share/doc/${DEBNAME}/changelog
    gzip --best debian/usr/share/doc/${DEBNAME}/changelog.DEBIAN
    fn_dialog_info "Building debian package"
    fakeroot dpkg-deb --build ./debian 1> /dev/null 2>> ${ERRORLOG}
    DEBFILE=${BUILDPATH}/${DEBNAME}_${RELEASETAG}_${ARCHITECTURE}.deb
    mv debian.deb ${DEBFILE}

    #user func
    functionExists function_deb_post && function_deb_post

    # copy the package to bytepark debian repo host
    if [ "${UPDATEREPO}" = "Yes" ]; then
        fn_dialog_info "Publishing release on apt repo server"
        scp ${DEBFILE} ${DEBREPOUSER}@${DEBREPOHOST}:${DEBREPOPATH}/${TARGET_NAME}/ 1> /dev/null 2>> ${ERRORLOG}
        ssh ${DEBREPOUSER}@${DEBREPOHOST} "cd ${DEBREPOPATH}/../ ; reprepro includedeb ${TARGET_NAME} ${DEBREPOPATH}/${TARGET_NAME}/*.deb" &> /dev/null

        # Exit if file was not uploaded at all.
        function_exit_if_remotefile_does_not_exist "${DEBREPOUSER}@${DEBREPOHOST}" "${DEBREPOPATH}/${TARGET_NAME}/$(basename ${DEBFILE})"

        # Exit if file was not uploaded completely (different fize sizes).
        function_exit_if_localfile_and_remotefile_not_same_size "${DEBFILE}" "${DEBREPOUSER}@${DEBREPOHOST}" "${DEBREPOPATH}/${TARGET_NAME}/$(basename ${DEBFILE})"

        METHOD_CUSTOM_COMPLETE="\n\nThe deb package ist published in the apt repository "
    else
        mv ${DEBFILE} ${PROJECT_PATH}
        METHOD_CUSTOM_COMPLETE="\n\nThe deb package file is located in your current directory"
    fi
}
