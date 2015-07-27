#!/usr/bin/env bats

@test "[release] when called with -h option, release shows a usage message on the second line" {

    CONCRETE_VIEW="prompt"
    run bash -c "$BATS_TEST_DIRNAME/../release.sh -h"

    [ $status = 0 ]
    [ "${lines[2]}" = " Usage: release [OPTIONS]" ]
}