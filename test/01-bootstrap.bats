#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh

@test "[bootstrap] Variables are initialized after bootstrapping" {
    releasePath="${BATS_TEST_DIRNAME}/.."
    releaseIncludepath="${releasePath}/include"
    concreteView="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
    expectedPath=$(normalizedPath "${BATS_TEST_FILENAME}")
    expected="${expectedPath}/release.errors.log"

    assert_equal 0 $inBatchMode
    assert_equal 0 $inSilentMode
    assert_equal 0 $DO_MYSQL_DUMP
    assert_equal "${expected}" "$ERRORLOG"
}
