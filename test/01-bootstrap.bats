#!/usr/bin/env bats

setup() {
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/.."
    SCRIPT_INCLUDEPATH="${SCRIPT_PATH}/include"

    CONCRETE_VIEW="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
}

@test "[bootstrap] Variables are initialized after bootstrapping" {
    [ $BATCHMODE -eq 0 ]
    [ $FORCE -eq 0 ]
    [ $DO_MYSQL_DUMP -eq 0 ]
    [ "$ERRORLOG" = "/home/ts/workspace/release/release.errors.log" ]
}
