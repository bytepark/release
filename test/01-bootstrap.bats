#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh

@test "[bootstrap] Variables are initialized after bootstrapping" {
    RELEASE_PATH="${BATS_TEST_DIRNAME}/.."
    RELEASE_INCLUDEPATH="${RELEASE_PATH}/include"
    CONCRETE_VIEW="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
    expected="$(cd $(dirname ${BATS_TEST_DIRNAME}); pwd)/release.errors.log"

    assert_equal $BATCHMODE 0
    assert_equal $FORCE 0
    assert_equal $DO_MYSQL_DUMP 0
    assert_equal "$ERRORLOG" "${expected}"
}
