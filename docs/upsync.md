# Upsync method

# Configuration example

### Necessary release configuration vars

    REPOROOT=ssh://www.example.org/git/
    REPO=YourRepoName
    GITBRANCH=master

    SSHPORT=22
    SSHUSER=
    SSHHOST=
    REMOTEPATH=/path/to/public_html/project/

    DB_USER=
    DB_PASSWORD=
    DB_HOST=
    DB_NAME=

    RSYNC_DO_DRY_RUN=0|1
    # int+
    RSYNC_DONT_DELETE_MORE_THAN=100

    # set this var in order to *not* execute the function_import_dumps
    # of your target release upsync configuration
    SKIP_IMPORT=1

    UPSYNC_ROOT=$(pwd)/files

### custom release configuration vars

    UPSYNC_DUMPS=(cmf.xml.gz dev.sql.gz)
    CMF_DUMP_NAME=cmf
    SQL_DUMP_NAME=dev



# Method configuration functions

## Pre-import

    function_import_dumps_pre() {
        fn_dialog_info "Copying + extracting Dumps..."
        for DUMP in ${UPSYNC_DUMPS[*]}; do
            scp ./db/${DUMP} ${SSHUSER}@${SSHHOST}:${REMOTEPATH}
            ssh $SSHUSER@$SSHHOST "cd ${REMOTEPATH}; gunzip ${DUMP};"
        done
    }

# Import method

*Must* be defined within the release configuration file as "upsyncing" includes database + files

    function_import_dumps() {
        # user func
        functionExists function_import_dumps_pre && function_import_dumps_pre

        fn_dialog_info "Re-initializing the PHPCR..."
        ssh $SSHUSER@$SSHHOST "cd ${REMOTEPATH}; app/console --env=stage doctrine:phpcr:repository:init"
        ssh $SSHUSER@$SSHHOST "cd ${REMOTEPATH}; app/console --env=stage doctrine:phpcr:node:remove /cmf"

        fn_dialog_info "Importing the PHPCR dump..."
        ssh $SSHUSER@$SSHHOST "cd ${REMOTEPATH}; app/console --env=stage doctrine:phpcr:workspace:import --parentpath=\"/\" ./${CMF_DUMP_NAME}.xml"

        fn_dialog_info "Importing the MySQL dump..."
        ssh $SSHUSER@$SSHHOST "cd ${REMOTEPATH}; mysql -u${DB_USER} -p${DB_PASSWORD} -h${DB_HOST} ${DB_NAME} < ${SQL_DUMP_NAME}.sql"

        # user func
        functionExists function_import_dumps_post && function_import_dumps_post
    }

## Post-import

    function_import_dumps_post() {
        fn_dialog_info "Removing dumps..."
        ssh $SSHUSER@$SSHHOST "cd ${REMOTEPATH}; rm -f ${CMF_DUMP_NAME}.xml"
        ssh $SSHUSER@$SSHHOST "cd ${REMOTEPATH}; rm -f ${SQL_DUMP_NAME}.sql"
    }
