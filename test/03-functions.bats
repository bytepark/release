#!/usr/bin/env bats

setup() {
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/.."
    SCRIPT_INCLUDEPATH="${SCRIPT_PATH}/include"

    BATCHMODE=0
    CONCRETE_VIEW="prompt"
    load $BATS_TEST_DIRNAME/../include/view.sh
    load $BATS_TEST_DIRNAME/../include/functions.sh
}

@test "[functions] checkTool returns 0 when program is present " {
    run checkTool "bats"

    [ $status -eq 0 ]
}

@test "[functions] checkTool returns 1 when program is NOT present" {
    run checkTool "unknown_program"

    [ $status -eq 1 ]
}

@test "[functions] checkTools returns with 0 when programs are present" {
    run checkTools "bats bash"

    [ $status -eq 0 ]
}

@test "[functions] checkTools exits with error code 20 and message when ONE program is NOT present" {
    run checkTools "unknown_program bats"

    [ $status -eq 20 ]
    [ $output = "Tools missing. Please install 'unknown_program' on your system." ]
}

@test "[functions] checkTools exits with error code 20 and message when MORE programs are NOT present" {
    run checkTools "unknown_program even_more_unknown_program"

    [ $status -eq 20 ]
    [ $output = "Tools missing. Please install 'unknown_program', 'even_more_unknown_program' on your system." ]
}
