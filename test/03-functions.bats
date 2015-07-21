#!/usr/bin/env bats

setup() {
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/.."
    SCRIPT_INCLUDEPATH="${SCRIPT_PATH}/include"

    BATCHMODE=0
    CONCRETE_VIEW="prompt"
    load $BATS_TEST_DIRNAME/../include/view.sh
    load $BATS_TEST_DIRNAME/../include/functions.sh
}

@test "[functions] checkTools succeeds when program is present" {
    run checkTools "bats"

    [ $status -eq 0 ]
}

@test "[functions] checkTools returns error code 20 with message when program is NOT present" {
    run checkTools "unknown_program"

    [ $status -eq 20 ]
    [ $output = "Tools missing. Please install 'unknown_program' on your system." ]
}
