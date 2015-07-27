#!/usr/bin/env bats

@test "[bootstrap] Variables are initialized after bootstrapping" {
    RELEASE_PATH="${BATS_TEST_DIRNAME}/.."
    RELEASE_INCLUDEPATH="${RELEASE_PATH}/include"
    CONCRETE_VIEW="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
echo $ERRORLOG
    [ $BATCHMODE -eq 0 ]
    [ $FORCE -eq 0 ]
    [ $DO_MYSQL_DUMP -eq 0 ]
    [ "$ERRORLOG" = "/home/ts/workspace/release/test/release.errors.log" ]
}
