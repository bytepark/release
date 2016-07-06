#!/usr/bin/env bash
#
# bytepark release manager - getopts.sh
#
# (c) 2011-2016 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#

parseForOptions() {
    # issue
    local issue="bytepark release manager - ${RELEASE_VERSION}"
    # Help text
    local help="${issue}\n
    \n
    Usage: release [OPTIONS]\n
    \n
    When OPTIONS is omitted the release manager executes\n
    in interactive mode, guiding the user in a step by step\n
    wizard through the release.\n
    \n
    Available options:\n
    \t-m\tthe method to use [rsync,tarball,rpm,deb,dump]\n
    \t-t\tthe target system\n
    \t-b\toptional git branch to release\n
    \t-r\toptional git tag to release\n
    \n
    \t-f\tdirect execution (CAUTIOUS USE - no summary)\n
    \t-d\tinclude database dump (CAUTIOUS USE - database is moved)\n
    \t-u\tupdate repo server\n
    \n
    \t-v\tversion\n
    \t-h\thelp text
    "

    while getopts "vhdfm:t:b:u" GETOPT_OPTION
    do
        inBatchMode=1
        case ${GETOPT_OPTION} in
            v)
                echo -e ${issue}
                exit 0
                ;;
            h)
                echo -e ${help}
                exit 0
                ;;
            m)
                releaseMethod=${OPTARG}
                i=0
                for method in "${METHODS[@]}"; do
                    if [ "$method" = "$releaseMethod" ]; then
                        DOWHAT=$i
                    fi
                    let i=$i+1
                done

                if [ -z $DOWHAT ]; then
                    echo "Method ${releaseMethod} not supported. Aborting."
                    exit
                fi

                if [ $releaseMethod = "rpm" ] || [ $releaseMethod = "deb" ]; then
                    UPDATEREPO="No"
                fi
                ;;
            t)
                TARGET_NAME=${OPTARG}
                ;;
            b)
                GITREVISION_BRANCH="1"
                RELEASETAG=${OPTARG}
                GITREVISION=${OPTARG}
                SUMMARY_REVISION="Head of branch ${GITREVISION}"
                ;;
            r)
                GITREVISION_TAG="1"
                RELEASETAG=${OPTARG}
                GITREVISION=${OPTARG}
                SUMMARY_REVISION="Tag ${GITREVISION}"
                ;;
            d)
                WITH_SQL_DUMP=true
                let inBatchMode=${inBatchMode}+0
                ;;
            f)
                inSilentMode=1
                ;;
            u)
                UPDATEREPO="Yes"
                ;;
            \?)
                echo "Invalid option: -${GETOPT_OPTION}.\nSee $0 -h for more information."
                exit 10
                ;;
            :)
                echo "Option -${GETOPT_OPTION} requires an argument.\nSee $0 -h for more information."
                exit 11
                ;;
        esac
    done
}
