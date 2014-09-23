#
# functions and constants for the release scipt
#

#
# constants for the release script
#

METHOD_DEPLOY=0
METHOD_TARBALL=1
METHOD_RPM=2
METHOD_DEB=3
METHOD_DUMP=4

METHODS=( deploy tarball rpm deb dump )
METHOD_LABELS=( "Make a rsync deploy to a remote site", "Build a gzipped tarball", "Build a RPM Package", "Build a DEB Package", "Dump data from remote site" )

#
# functions for the release script
#

#
# function to check for needed tools
#
function_check_tools() {
    TOOLS='basename clear cut dirname expr find git getopts grep ls mkdir rm rsync sed ssh tr tac'

    for prog in ${TOOLS}; do
        if [ ! `command -v ${prog}` ]; then
            fn_dialog_error "Cannot run. Command ${prog} can not be found on your system."
            exit
        fi
    done
}

#
# method to determine the current os we are running on
#
# @sets OS
#
function_determine_os() {
    OS=""
    OSPKG=""
    grep "centos" /etc/issue -i -q
    if [ $? = '0' ];then
        OS="centos"
        OSPKG="rpm"
    fi
    grep "fedora" /etc/issue -i -q
    if [ $? = '0' ];then
        OS="fedora"
        OSPKG="rpm"
    fi
    grep "debian" /etc/issue -i -q
    if [ $? = '0' ];then
        OS="debian"
        OSPKG="deb"
    fi
    grep "ubuntu" /etc/issue -i -q
    if [ $? = '0' ];then
        OS="ubuntu"
        OSPKG="deb"
    fi
    grep "mint" /etc/issue -i -q
    if [ $? = '0' ];then
        OS="mint"
        OSPKG="deb"
    fi
}


#
# method to determine the project name
#
# @sets $PROJECT
# @sets $PROJECTPATH
# @sets $CONFIG_DIR
#
function_determine_projectname_and_paths() {

    MYPATH=`pwd`
    while [ "${MYPATH}" != "/" ]; do
        if [ -d ${MYPATH}/.release ]; then
            PROJECT=`basename ${MYPATH}`
            PROJECTPATH=${MYPATH}
            CONFIG_DIR=${MYPATH}/.release
        fi

        MYPATH=`dirname ${MYPATH}`
    done
    if [ -z ${PROJECT} ]; then
        fn_dialog_error "You are not in a project directory. Exiting."
        exit 10
    fi
    if [ -z ${CONFIG_DIR} ]; then
        fn_dialog_error "No .release folder found. Exiting."
        exit 11
    fi
    if [ ! "ls -A ${CONFIG_DIR}/*.conf" ]; then
        fn_dialog_error "No config files in .release found. Exiting."
        exit 12
    fi
}

#
# method to determine the type of project we are in
#
# able to recognize
# - symfony 1.x
# - symfony 2.x
# - wordpress
# - redaxo
# - composer Component
#
# @sets $PROJECTTYPE
#
# @return void
#
function_determine_projecttype() {
    if [ -f ${PROJECTPATH}/${PROJECT}/composer.json ]; then
        PROJECTTYPE=composer
    fi
    if [ -f ${PROJECTPATH}/${PROJECT}/symfony ]; then
        PROJECTTYPE=symfony
    fi
    if [ -f ${PROJECTPATH}/${PROJECT}/app/console.php ]; then
        PROJECTTYPE=symfony2
    fi
    if [ -f ${PROJECTPATH}/${PROJECT}/application/Bootstrap.php ]; then
        PROJECTTYPE=zend
    fi
    if [ -d ${PROJECTPATH}/${PROJECT}/web/rxadmin ]; then
        PROJECTTYPE=redaxo
    fi
    if [ ! -n $PROJECTTYPE ]; then
        PROJECTTYPE=unknown
    fi
}

#
# determines the available config files
#
#
#
function_determine_available_configs() {
    if ls ${CONFIG_DIR}/deploy.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_DEPLOY=true
    fi
    if ls ${CONFIG_DIR}/tarball.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_TARBALL=true
    fi
    if ls ${CONFIG_DIR}/rpm.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_RPM=true
    fi
    if ls ${CONFIG_DIR}/deb.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_DEB=true
    fi
    if ls ${CONFIG_DIR}/dump.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_DUMP=true
    fi
}

#
# finds out what we should do
#
# @sets $DOWHAT
#
function_whattodo() {
    # find out what we want to do
    RADIOLIST=""
    METHOD_COUNT=0
    if [ $HAS_CONFIG_DEPLOY ]; then
        TITLE=${METHOD_LABELS[${METHOD_DEPLOY}]}
        RADIOLIST="${RADIOLIST} ${METHOD_DEPLOY} \"${TITLE}\""
        let METHOD_COUNT=${METHOD_COUNT}+1
    fi
    if [ $HAS_CONFIG_TARBALL ]; then
        TITLE=${METHOD_LABELS[${METHOD_TARBALL}]}
        RADIOLIST="${RADIOLIST} ${METHOD_TARBALL} \"${TITLE}\""
        let METHOD_COUNT=${METHOD_COUNT}+1
    fi
    if [ $HAS_CONFIG_RPM ]; then
        TITLE=${METHOD_LABELS[${METHOD_RPM}]}
        RADIOLIST="${RADIOLIST} ${METHOD_RPM} \"${TITLE}\""
        let METHOD_COUNT=${METHOD_COUNT}+1
    fi
    if [ $HAS_CONFIG_DEB ]; then
        TITLE=${METHOD_LABELS[${METHOD_DEB}]}
        RADIOLIST="${RADIOLIST} ${METHOD_DEB} \"${TITLE}\""
        let METHOD_COUNT=${METHOD_COUNT}+1
    fi
    if [ $HAS_CONFIG_DUMP ]; then
        TITLE=${METHOD_LABELS[${METHOD_DUMP}]}
        RADIOLIST="${RADIOLIST} ${METHOD_DUMP} \"${TITLE}\""
        let METHOD_COUNT=${METHOD_COUNT}+1
    fi
    #read -s -n 1 -p ">" DOWHAT

    if [ "${METHOD_COUNT}" = "1" ]; then
        DOWHAT=`echo ${RADIOLIST} | cut -d " " -f1`
    else
        fn_dialog_menubox "What do you want to do today?" ${METHOD_COUNT} "$RADIOLIST"
        DOWHAT=$RETURN
        if [[ ! $DOWHAT =~ ^[0-9]+$ ]]; then
            fn_dialog_info "\nGood bye."
            exit 20
        fi
#        if [ ${DOWHAT} -lt 1 ] || [ ${DOWHAT} -gt ${#METHODS[@]} ]; then
#            fn_dialog_info "\nGood bye."
#            exit 20
#        fi
    fi

    METHOD_NAME="${METHODS[${DOWHAT}]}"
}


function_wheretogo() {
    TARGET_PATTERN="${METHOD_NAME}.*.conf"
    TARGET_COUNT=0
    RADIOLIST=""

    for FILE in $( ls -1 ${CONFIG_DIR}/${TARGET_PATTERN} | sed 's#.*/##' ); do
        TARGET_COUNT=`expr ${TARGET_COUNT} + 1`
        TITLE=`echo ${FILE} | cut -d "." -f2`
        RADIOLIST="${RADIOLIST} ${TARGET_COUNT} ${TITLE}"

        CNF[${TARGET_COUNT}]=${TITLE}
    done

    if [ ${TARGET_COUNT} == 0 ]; then
        fn_dialog_error "No config files found. Exiting.\n"
        exit
    fi

    if [ ${TARGET_COUNT} = 1 ]; then
        TARGET=1
    else
        fn_dialog_menubox "What is the target system?" $TARGET_COUNT "$RADIOLIST"
        TARGET=${RETURN}
    fi

    if [ -z ${TARGET} ]; then
        fn_dialog_error "Aborting.\n"
        exit
    fi

    TARGET_NAME=${CNF[${TARGET}]}
}


function_source_config() {
    ERROR_MESSAGE=""
    if [ -z ${METHOD_NAME} ]; then
        ERROR_MESSAGE="No method defined. Exiting.\n"
    fi
    if [ -z ${TARGET_NAME} ]; then
        ERROR_MESSAGE="No target defined. Exiting.\n"
    fi

    CONFIG_FILEPATH="${CONFIG_DIR}/${METHOD_NAME}.${TARGET_NAME}.conf"

    if [ ! -f ${CONFIG_FILEPATH} ]; then
        ERROR_MESSAGE="Unavailable Target"
    fi

    if [ $ERROR_MESSAGE ]; then
        if [ $BATCHMODE = 1 ]; then
            echo -e ${ERROR_MESSAGE}
        else
            fn_dialog_error ${ERROR_MESSAGE}
        fi
    fi

    source ${CONFIG_FILEPATH}

    # check if there is a hook definition file and source it
    if [ -f ${CONFIG_DIR}/hooks.conf ]; then
        source ${CONFIG_DIR}/hooks.conf
    fi
}

#
# function to source the correct method file
#
function_source_method() {
    ERROR_MESSAGE=""
    if [ -z ${METHOD_NAME} ]; then
        ERROR_MESSAGE="No method defined. Exiting.\n"
    fi

    METHOD_FILEPATH="${BASE}/include/method_${METHOD_NAME}.sh"

    if [ ! -f ${METHOD_FILEPATH} ]; then
        ERROR_MESSAGE="Unavailable method Exiting.\n"
    fi

    if [ $ERROR_MESSAGE ]; then
        if [ $BATCHMODE = 1 ]; then
            echo -e ${ERROR_MESSAGE}
        else
            fn_dialog_error ${ERROR_MESSAGE}
        fi
    fi

    source ${METHOD_FILEPATH}

    function_exists function_post_source && function_post_source
}

#
# this function sets the DO_MYSQL_DUMP variable to 0 or 1 after asking the user
# whether to create a mysql dump. the question will only be asked if the MYSQL_*
# config variables are set.
#
# The following variables MUST BE SET:
#       MYSQL_HOST_LOCAL
#       MYSQL_USERNAME_LOCAL
#       MYSQL_PASSWORD_LOCAL
#       MYSQL_DB_LOCAL
#       MYSQL_HOST_REMOTE
#       MYSQL_USERNAME_REMOTE
#       MYSQL_PASSWORD_REMOTE
#       MYSQL_DB_REMOTE
#
function_ask_for_mysql_dump() {
    # Don't do a mysql dump and exit function
    # if any of the MYSQL_* variables is NOT SET.
    if [ -z ${MYSQL_HOST_LOCAL} ] ||
       [ -z ${MYSQL_USERNAME_LOCAL} ] ||
       [ -z ${MYSQL_PASSWORD_LOCAL} ] ||
       [ -z ${MYSQL_DB_LOCAL} ] ||
       [ -z ${MYSQL_HOST_REMOTE} ] ||
       [ -z ${MYSQL_USERNAME_REMOTE} ] ||
       [ -z ${MYSQL_PASSWORD_REMOTE} ] ||
       [ -z ${MYSQL_DB_REMOTE} ]; then
       DO_MYSQL_DUMP=0
       return
    fi

    # All required MYSQL_* variables are set.
    # Ask if mysql dump should be created and set
    # the variable DO_MYSQL_DUMP accordingly.
    fn_dialog_yesorno "Create mysql dump and import it on target host? (Y/n)"
    if [ "$RETURN" = "0" ]; then
        DO_MYSQL_DUMP=0
    else
        DO_MYSQL_DUMP=1
    fi
}

#
# prepares all variables needed for git and the resulting release
#
function_setup_git() {
    # set the GITREPO
    if [ -z ${REPO} ]; then
        fn_dialog_error "Variable \$REPO is not set. Please add this to your release config"
        exit 10
    fi

    # set the PROJECT VAR with correct name from repo
    PROJECT=${REPO}
    GITREPO="ssh://elena.bytenetz.de/git/${REPO}.git"

    function_ask_revision
}

function_ask_revision() {
    if [ $BATCHMODE = 0 ]; then
        if [ -z "${GITBRANCH}" ]; then
            fn_dialog_menubox "Branch or tag release?" 2 "0 \"HEAD of a branch\" 1 Tag"
            REVISION_TARGET=${RETURN}

            if [ $REVISION_TARGET = 0 ]; then
                function_gitbranch
            fi
            if [ $REVISION_TARGET = 1 ]; then
                function_gittag
            fi
        else
            GITREVISION_BRANCH="1"
            RELEASETAG=${GITBRANCH}
            GITREVISION=${GITBRANCH}
            SUMMARY_REVISION="Head of branch ${GITREVISION}"
        fi
    else
        if [ -z $GITREVISION ]; then
            GITREVISION_BRANCH="1"
            RELEASETAG="master"
            GITREVISION="master"
            SUMMARY_REVISION="Head of branch ${GITREVISION}"
        fi
    fi
}



#
# prints out a summary of the pending action
#
function_summary() {
    SUMMARYTEXT="This is what we are going to do:\n"

    SUMMARYTEXT="${SUMMARYTEXT}\nTask:         ${METHOD_LABELS[${DOWHAT}]}"
    SUMMARYTEXT="${SUMMARYTEXT}\nTarget:       ${TARGET_NAME}"
    SUMMARYTEXT="${SUMMARYTEXT}\nGit-Repo:     ${GITREPO}"
    SUMMARYTEXT="${SUMMARYTEXT}\nRevision:     ${SUMMARY_REVISION}"

    if [ ! -z $SSHUSER ]; then
        SUMMARYTEXT="${SUMMARYTEXT}\nSSH:          ${SSHUSER}@${SSHHOST}"
    fi
    if [ ! -z $UPDATEREPO ]; then
        SUMMARYTEXT="${SUMMARYTEXT}\nUpdate repo:  ${UPDATEREPO}"
    fi

    if [ ${BUILD_HOST} ]; then
        SUMMARYTEXT="${SUMMARYTEXT}\n\nRemote build"
        SUMMARYTEXT="${SUMMARYTEXT}\nHost:         ${BUILD_HOST}"
        SUMMARYTEXT="${SUMMARYTEXT}\nUser:         ${BUILD_HOST_USER}"
    fi

    if [ ${DO_MYSQL_DUMP} -eq 1 ]; then
        SUMMARYTEXT="${SUMMARYTEXT}\n\nMySQL dump/import"
        SUMMARYTEXT="${SUMMARYTEXT}\nLocal host:      ${MYSQL_HOST_LOCAL}"
        SUMMARYTEXT="${SUMMARYTEXT}\nLocal username:  ${MYSQL_USERNAME_LOCAL}"
        SUMMARYTEXT="${SUMMARYTEXT}\nLocal password:  ${MYSQL_PASSWORD_LOCAL}"
        SUMMARYTEXT="${SUMMARYTEXT}\nLocal database:  ${MYSQL_DB_LOCAL}"
        SUMMARYTEXT="${SUMMARYTEXT}\nRemote host:     ${MYSQL_HOST_REMOTE}"
        SUMMARYTEXT="${SUMMARYTEXT}\nRemote username: ${MYSQL_USERNAME_REMOTE}"
        SUMMARYTEXT="${SUMMARYTEXT}\nRemote password: ${MYSQL_PASSWORD_REMOTE}"
        SUMMARYTEXT="${SUMMARYTEXT}\nRemote database: ${MYSQL_DB_REMOTE}"
    fi

    SUMMARYTEXT="${SUMMARYTEXT}\n\nDo you want to continue?"
    fn_dialog_yesorno "Summary" "${SUMMARYTEXT}"
    CONTINUE=${RETURN}

    if [ "$CONTINUE" != "1" ]; then
            fn_dialog_info "Aborting."
            clear
            exit
    fi
}

#
# create a myql dump/import based on MYSQL_* configuration variables
#
function_mysql_dump() {
    function_mysqldump
    function_mysqlimport
}

#
# creates a temporary directory
#
function_create_tempdir() {
    FOLDER=temp_${USER}_${REPO}
    cd /tmp/

    # delete old temp folder, if exists
    if [ -d ${FOLDER} ]; then
        rm -rf ${FOLDER}
    fi

    # create temp folder
    mkdir -p ${FOLDER}
    cd ${FOLDER}

    BUILDPATH="/tmp/${FOLDER}"
}

#
# removes the git folder and corresponding git files
#
function_remove_gitfiles() {
    rm -rf .git
    find . -type f -name "*.git*" -exec rm -f '{}' \;
}

function_remove_releasefiles() {
    if [ -d .release ]; then
        rm -rf .release
    fi

    rm -Rf .puppet
    rm -f Vagrantfile
    rm -f build.xml
    rm -f phpunit.xml.dist
}

function_exists() {
    type -t $1 | grep -q 'function'
}

function_mysqldump() {
    fn_dialog_info -n "Making MySQL dump ..."
    # dump the local db
    echo "SET FOREIGN_KEY_CHECKS=0;" > dump.sql && mysqldump --set-charset --add-drop-table $MYSQL_DUMP_EXTRA_PARAMS -h $MYSQL_HOST_LOCAL -u$MYSQL_USERNAME_LOCAL -p$MYSQL_PASSWORD_LOCAL $MYSQL_DB_LOCAL | gzip -c > dump.sql.gz
    fn_dialog_info "Done."
}

function_mysqlimport() {
    fn_dialog_info "Importing mysql on live machine ..."
    # unzip, import the transferred dump on live db, and remove the dump
    ssh $SSHUSER@$SSHHOST "cd $REMOTEPATH ; gzip -f -d dump.sql.gz ; mysql -h $MYSQL_HOST_REMOTE -u$MYSQL_USERNAME_REMOTE -p$MYSQL_PASSWORD_REMOTE $MYSQL_DB_REMOTE < dump.sql ; rm dump.sql ;"
    fn_dialog_info "Done."
}

function_mysqldump_remote() {
    fn_dialog_info "Making MySQL dump on remote side..."
    # dump the local db
    ssh $SSHUSER@$SSHHOST "cd $REMOTEPATH ; echo \"SET FOREIGN_KEY_CHECKS=0;\" > dump.sql && mysqldump --set-charset --add-drop-table $MYSQL_DUMP_EXTRA_PARAMS_REMOTE -h $MYSQL_HOST_REMOTE -u$MYSQL_USERNAME_REMOTE -p$MYSQL_PASSWORD_REMOTE $MYSQL_DB_REMOTE | gzip -c > dump.sql.gz; "
    fn_dialog_info "Done."
}

function_mysqlimport_remote() {
    fn_dialog_info "Importing mysql on local machine ..."
    # unzip, import the transferred dump on live db, and remove the dump
    gzip -f -d dump.sql.gz
    mysql -h $MYSQL_HOST_LOCAL -u$MYSQL_USERNAME_LOCAL -p$MYSQL_PASSWORD_LOCAL $MYSQL_DB_LOCAL < dump.sql
    rm dump.sql
    ssh $SSHUSER@$SSHHOST "cd $REMOTEPATH ; rm dump.sql.gz; "
    fn_dialog_info "Done."
}

#
# read in git tags
#
function_gittag() {
    GITREVISION_TAG="1"
    # get the tag we want to package
    fn_dialog_info "Fetching git tags. Please wait"
    TAGS=( $(git ls-remote --tags ${GITREPO} | grep -v "{}" | cut -f 2 | sed "s|refs/tags/||" | sort -rV) )

    # exit if we got no tags
    if [ "${#TAGS[@]}" -lt "1" ]; then
        fn_dialog_error "Could not find any git tags.\n Exiting."
    fi
    # exit if we got one tag, we're done
    if [ "${#TAGS[@]}" = "1" ]; then
        RETURN=0
    else
        # otherwise let user select
        RADIOLIST=""
        for (( c=0; c<${#TAGS[@]}; c++ )); do
            RADIOLIST="${RADIOLIST} $c \"${TAGS[${c}]}\""
        done
        fn_dialog_menubox "Available Tags" $c "$RADIOLIST" "20 70"
    fi
    RELEASETAG=${TAGS[${RETURN}]}
    GITREVISION=${RELEASETAG}
    SUMMARY_REVISION="Tag ${GITREVISION}"
}

#
# read in git branches
#
function_gitbranch() {
    GITREVISION_BRANCH="1"
    # get the tag we want to package
    fn_dialog_info "Fetching git branches. Please wait"
    BRANCHES=( $(git ls-remote --heads ${GITREPO} | grep -v "{}" | cut -f2 | sed "s|refs/heads/||" | sort) )

    # exit if we got no tags
    if [ "${#BRANCHES[@]}" -lt "1" ]; then
        fn_dialog_error "Could not find any git branches.\n Exiting."
    fi

    if [ ${#BRANCHES[@]} = 1 -a "${BRANCHES[0]}" = "master" ]; then
        RELEASETAG="master"
        GITREVISION="master"
    else
        # otherwise let user select
        RADIOLIST=""
        for (( c=0; c<${#BRANCHES[@]}; c++ )); do
            RADIOLIST="${RADIOLIST} $c \"${BRANCHES[${c}]}\""
        done
        fn_dialog_menubox "Available Branches" $c "$RADIOLIST" "20 70"
        RELEASETAG=${BRANCHES[${RETURN}]}
        GITREVISION=${RELEASETAG}
    fi
    SUMMARY_REVISION="Head of branch ${GITREVISION}"
}

function_git_dispatch() {
    fn_dialog_progressbox "git clone "${GITREPO}" "$1" 2>> ${ERRORLOG}" "Cloning repository"

    # prepare the app
    cd $1

    # hook for master branch actions before branch pull
    function_exists method_pre_gitbranch_pull && method_pre_gitbranch_pull

    if [ -n "${GITREVISION_BRANCH}" -a "master" != "${GITREVISION}" ]; then
        fn_dialog_progressbox "git checkout -b ${GITREVISION} origin/${GITREVISION}" "Pulling branch ${GITREVISION}"
    fi

    # hook for master branch actions after branch pull
    function_exists method_post_gitbranch_pull && method_post_gitbranch_pull


    if [ ${GITREVISION_TAG} ]; then
        # hook for master branch actions before tag checkout
        function_exists method_pre_gittag_checkout && method_pre_gittag_checkout

        fn_dialog_progressbox "git checkout ${GITREVISION}" "Checkout of tag ${GITREVISION}"

        # hook for master branch actions after tag checkout
        function_exists method_post_gittag_checkout && method_post_gittag_checkout
    fi
}

# This function is kinda obsolete now since we are using the ERRORLOG.
# I decided to keep it because sometimes it does not make sense to run
# through the whole script just to see that something broke 10 minutes ago.
# So, if you want to exit the release process immidiately (and display the error message),
# you should use this function.
function_exit_if_failed() {
    if [ -z $1 ] || [ $1 -eq 0 ]; then
        return;
    fi
    function_show_errorlog 0
    exit 1;
}

function_exit_if_remotefile_does_not_exist() {
    $(ssh $1 ls -l $2 1> /dev/null 2>> ${ERRORLOG})

    if [ $? -ne 0 ]; then
        echo "The file should have been uploaded to the repo server but it's not there! Aborting!" >> ${ERRORLOG}
        exit 1;
    fi
}

function_exit_if_localfile_and_remotefile_not_same_size() {
    localfile_size=$(ls -l $1 | awk '{print $5}')
    remotefile_size=$(ssh $2 ls -l $3 | awk '{print $5}')

    if [ $localfile_size -ne $remotefile_size ]; then
        echo "Something went wrong uploading the file to our repo host." >> ${ERRORLOG}
        echo "The local file and the remote file don't have the same size!" >> ${ERRORLOG}
        exit 1;
    fi
}

# check if $ERRORLOG file exists and show it's content if it does.
# exit process with a non-succesful return code.
function_show_errorlog() {
    if [ ! -f ${ERRORLOG} ]; then
        return
    fi

    ERRORS=`cat ${ERRORLOG}`

    # ERRORLOG exists. Check if it's empty.
    # Don't show error dialog if it is and remove the empty file!
    if [ -z "${ERRORS}" ]; then
        rm -f ${ERRORLOG}
        return
    fi

    # In Batchmode, always return with exit code 0.
    if [ "$1" == "1" ]; then
        exit 0
    fi

    fn_dialog_progressbox "cat ${ERRORLOG}" "Errors or warnings occured during release."
    exit 1
}
