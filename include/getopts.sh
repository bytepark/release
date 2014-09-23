# Help text
HELP="bytepark release manager - $VERSION
\n
Usage: release [OPTIONS]\n
\n
When OPTIONS is omitted the release manager executes\n
in interactive mode, guiding the user in a step by step\n
wizard through the release.\n
\n
Available options:\n
\t-m\tthe method to use [deploy,tarball,rpm,deb,dump]\n
\t-t\tthe target system\n
\t-b\toptional git branch to release\n
\t-r\toptional git tag to release\n
\n
\t-f\tdirect execution (CAUTIOUS USE - no summary)\n
\t-d\tinclude database dump (CAUTIOUS USE - database is moved)\n
\t-u\tupdate repo server\n
\n
\t-v\tversion\n
\t-h\thelp text\n
\n
"

while getopts "vhdfm:t:b:u" OPTION
do
    BATCHMODE=1
    case $OPTION in
        v)
            echo -e ${VERSION}
            exit
            ;;
        h)
            echo -e ${HELP}
            exit
            ;;
        m)
            METHOD_NAME=${OPTARG}
            i=0
            for method in "${METHODS[@]}"; do
                if [ "$method" = "$METHOD_NAME" ]; then
                    DOWHAT=$i
                fi
                let i=$i+1
            done

            if [ -z $DOWHAT ]; then
                echo "Method ${METHOD_NAME} not supported. Aborting."
                exit
            fi

            if [ $METHOD_NAME = "rpm" ] || [ $METHOD_NAME = "deb" ]; then
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
            let BATCHMODE=${BATCHMODE}+0
            ;;
        f)
            FORCE=1
            ;;
        u)
            UPDATEREPO="Yes"
            ;;
        \?)
            echo "Invalid option: -${OPTION}.\nSee $0 -h for more information. Good bye."
            exit
            ;;
        :)
            echo "Option -${OPTION} requires an argument.\nSee $0 -h for more information. Good bye."
            exit
            ;;
    esac
done

# Check if opts are complete