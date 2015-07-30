#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh

@test "[release] when called with -h option, release shows a usage message on the second line" {

    CONCRETE_VIEW="prompt"
    run bash -c "$BATS_TEST_DIRNAME/../release.sh -h"

    assert_success
    assert_line " Usage: release [OPTIONS]"
}