#!/usr/bin/env bash
#
# bytepark release manager - functions.sh
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Global functions for the release script

#
# Checks the first parameter for emptyness and exits with the given
# error code and message on failing
#
guardEmptyOrExitWithError() {
    if [ ! -z "${1}" ]; then
        view_error "${3}"
        exit $2
    fi

    return 0
}

#
# Checks the first parameter for non-emptyness and exits with the given
# error code and message on failing
#
guardNonEmptyOrExitWithError() {
    if [ -z "${1}" ]; then
        view_error "${3}"
        exit $2
    fi

    return 0
}

#
# Executes the first parameter and exits with the given
# error code and message on failing
#
guardSuccessfulCallOrExitWithError() {
   `${1} > /dev/null 2>&1`

   if [ $? -ne 0 ]; then
        view_error "${3}"
        exit $2
    fi

    return 0
}

#
# Checks if the given commands are present on the system
#
# Exits with error code 20 when commands are not present
#
checkForTools() {
    local commands=$1
    local missing=""

    for command in ${commands}; do
        checkForTool "${command}"
        if [ $? -eq 1 ]; then
            if [ -z ${missing} ]; then
                missing="'${command}'"
            else
                missing="${missing}, '${command}'"
            fi
        fi
    done

    guardEmptyOrExitWithError "${missing}" 20 "Tools missing. Please install ${missing} on your system."

    return 0
}

#
# Checks if the given command is present on the system
#
# @return 1 when command is not present, 0 otherwise
#
checkForTool() {
    if [ ! $(command -v ${1}) ]; then
        return 1
    fi

    return 0
}

#
# Initializes the basic project settings
#
initializeProject() {
    local currentPath="${PWD}"
    parseProjectPath "${currentPath}"

    guardNonEmptyOrExitWithError "${PROJECT}" 21 "You are not in a project directory.\n\nAborting"
    guardNonEmptyOrExitWithError "${PROJECT_CONFIG_DIR}" 22 "No .release folder found.\n\nAborting"
    guardSuccessfulCallOrExitWithError "echo ${PROJECT_CONFIG_DIR}/*.conf" 23 "No release configurations files in .release.\n\nAborting"

    return 0
}

#
# Parses the given path for release configurations and sets the needed variables
#
# @sets PROJECT_PATH
# @sets PROJECT
# @sets PROJECT_CONFIG_DIR
#
# @return 1 on failure, 0 otherwise
#
parseProjectPath() {
    local path="$1"

    while [ "${path}" != "/" ]; do
        if [ -d ${path}/.release ]; then
           break
        fi
        path=$(dirname "${path}")
    done

    if [ "/" = ${path} ]; then
        return 1
    fi

    PROJECT_PATH=${path}
    PROJECT=$(basename "${path}")
    PROJECT_CONFIG_DIR="${path}/.release"

    return 0
}

#
# Loads the release configuration definied by given values
#
# @param method
# @param target
#
loadConfiguration() {
    local method=$1
    local target=$2
    local configFile="${method}.${target}.conf"
    if [ ! -f ${PROJECT_CONFIG_DIR}/${configFile} ]; then
        view_error "Release configuration '${configFile}' not found. Aborting."
        exit 12
    fi

    . ${PROJECT_CONFIG_DIR}/${configFile}
}

#
# parses the configuration files
#
parseConfigurations() {
    local configFileName
    local currentMethod
    local currentTarget
    local currentMethodKey
    local currentMethodName
    local currentMethodLabel

    for configFileName in $( ls -1 ${PROJECT_CONFIG_DIR}/*.conf | sed 's#.*/##' | sed 's#\.conf##' ); do
        local configPartsArray=($(echo "${configFileName}" | tr "\." " "))
        currentMethod=${configPartsArray[0]}
        currentTarget=${configPartsArray[1]}

        methodHaystack=$(echo ${METHODS[@]})
        inArray "${methodName}" "$methodHaystack"
        if [ $? -ne 0 ]; then
            view_error "Unavailable method '${methodName}'. Aborting"
            exit 24
        fi

        declare methodvariable="METHOD_$(toUpper ${currentMethod})"
        currentMethodKey=${!methodvariable}
        currentMethodName=${METHODS[${!methodvariable}]}
        currentMethodLabel=${METHOD_LABELS[${!methodvariable}]}
    done
}

#
#
#
askForMethod() {
    return 0
}

#
#
#
askForTarget() {
    return 0
}



####### OLD CODE FROM HERE ON
#
# determines the available config files
#
#
#
function_determine_available_configs() {
    if ls ${PROJECT_CONFIG_DIR}/deploy.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_DEPLOY=true
    fi
    if ls ${PROJECT_CONFIG_DIR}/tarball.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_TARBALL=true
    fi
    if ls ${PROJECT_CONFIG_DIR}/rpm.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_RPM=true
    fi
    if ls ${PROJECT_CONFIG_DIR}/deb.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_DEB=true
    fi
    if ls ${PROJECT_CONFIG_DIR}/dump.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_DUMP=true
    fi
    if ls ${PROJECT_CONFIG_DIR}/upsync.*.conf > /dev/null 2>&1
    then
        HAS_CONFIG_UPSYNC=true
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
    if [ $HAS_CONFIG_UPSYNC ]; then
        TITLE=${METHOD_LABELS[${METHOD_UPSYNC}]}
        RADIOLIST="${RADIOLIST} ${METHOD_UPSYNC} \"${TITLE}\""
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

    releaseMethod="${METHODS[${DOWHAT}]}"
}


function_wheretogo() {
    TARGET_PATTERN="${releaseMethod}.*.conf"
    TARGET_COUNT=0
    RADIOLIST=""

    for FILE in $( ls -1 ${PROJECT_CONFIG_DIR}/${TARGET_PATTERN} | sed 's#.*/##' ); do
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
    if [ -z ${releaseMethod} ]; then
        ERROR_MESSAGE="No method defined. Exiting.\n"
    fi
    if [ -z ${TARGET_NAME} ]; then
        ERROR_MESSAGE="No target defined. Exiting.\n"
    fi

    CONFIG_FILEPATH="${PROJECT_CONFIG_DIR}/${releaseMethod}.${TARGET_NAME}.conf"

    if [ ! -f ${CONFIG_FILEPATH} ]; then
        ERROR_MESSAGE="Unavailable Target"
    fi

    if [ $ERROR_MESSAGE ]; then
        if [ $inBatchMode = 1 ]; then
            echo -e ${ERROR_MESSAGE}
        else
            fn_dialog_error ${ERROR_MESSAGE}
        fi
    fi

    source ${CONFIG_FILEPATH}

    # check if there is a hook definition file and source it
    if [ -f ${PROJECT_CONFIG_DIR}/hooks.conf ]; then
        source ${PROJECT_CONFIG_DIR}/hooks.conf
    fi
}

#
# function to source the correct method file
#
function_source_method() {
    ERROR_MESSAGE=""
    if [ -z ${releaseMethod} ]; then
        ERROR_MESSAGE="No method defined. Exiting.\n"
    fi

    METHOD_FILEPATH="${BASE}/include/method_${releaseMethod}.sh"

    if [ ! -f ${METHOD_FILEPATH} ]; then
        ERROR_MESSAGE="Unavailable method Exiting.\n"
    fi

    if [ $ERROR_MESSAGE ]; then
        if [ $inBatchMode = 1 ]; then
            echo -e ${ERROR_MESSAGE}
        else
            fn_dialog_error ${ERROR_MESSAGE}
        fi
    fi

    source ${METHOD_FILEPATH}

    functionExists function_post_source && function_post_source
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

    if [ -z ${REPOROOT} ]; then
        fn_dialog_error "Variable \$REPOROOT is not set. Please add this to your release config. Example: git@github.com:bytepark/"
        exit 13
    fi

    # set the PROJECT VAR with correct name from repo
    PROJECT=${REPO}
    GITREPO="${REPOROOT}${REPO}.git"

    function_ask_revision
}

function_ask_revision() {
    if [ $inBatchMode = 0 ]; then
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
    functionExists method_pre_gitbranch_pull && method_pre_gitbranch_pull

    if [ -n "${GITREVISION_BRANCH}" -a "master" != "${GITREVISION}" ]; then
        fn_dialog_progressbox "git checkout -b ${GITREVISION} origin/${GITREVISION}" "Pulling branch ${GITREVISION}"
    fi

    # hook for master branch actions after branch pull
    functionExists method_post_gitbranch_pull && method_post_gitbranch_pull


    if [ ${GITREVISION_TAG} ]; then
        # hook for master branch actions before tag checkout
        functionExists method_pre_gittag_checkout && method_pre_gittag_checkout

        fn_dialog_progressbox "git checkout ${GITREVISION}" "Checkout of tag ${GITREVISION}"

        # hook for master branch actions after tag checkout
        functionExists method_post_gittag_checkout && method_post_gittag_checkout
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
