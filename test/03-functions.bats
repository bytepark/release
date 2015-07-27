#!/usr/bin/env bats

setup() {
    RELEASE_PATH="${BATS_TEST_DIRNAME}/.."
    RELEASE_INCLUDEPATH="${RELEASE_PATH}/include"

    BATCHMODE=0
    CONCRETE_VIEW="prompt"
    load $BATS_TEST_DIRNAME/../include/view.sh
    load $BATS_TEST_DIRNAME/../include/functions.sh
}

@test "[functions] guardEmptyOrExitWithError returns 0 on success" {
    run guardEmptyOrExitWithError "" 1 "NON EMPTY"

    [ $status -eq 0 ]
}

@test "[functions] guardEmptyOrExitWithError exits with error code and message on guard failure" {
    run guardEmptyOrExitWithError "A" 1 "NON EMPTY"

    [ $status -eq 1 ]
    [ $output = "NON EMPTY" ]
}

@test "[functions] guardNonEmptyOrExitWithError returns 0 on success" {
    run guardNonEmptyOrExitWithError "non empty" 1 "EMPTY"

    [ $status -eq 0 ]
}

@test "[functions] guardNonEmptyOrExitWithError exits with error code and message on guard failure" {
    run guardNonEmptyOrExitWithError "" 1 "EMPTY"

    [ $status -eq 1 ]
    [ $output = "EMPTY" ]
}

@test "[functions] guardSuccessfulCallOrExitWithError returns 0 on success" {
    run guardSuccessfulCallOrExitWithError "ls" 1 "EXEC FAILED"

    [ $status -eq 0 ]
}

@test "[functions] guardSuccessfulCallOrExitWithError exits with error code and message on guard failure" {
    run guardSuccessfulCallOrExitWithError "ls-this-should-fail" 1 "EXEC FAILED"
echo $status
    [ $status -eq 1 ]
    [ $output = "EXEC FAILED" ]
}

@test "[functions] checkForTool returns 0 when program is present " {
    run checkForTool "bats"

    [ $status -eq 0 ]
}

@test "[functions] checkForTool returns 1 when program is NOT present" {
    run checkForTool "unknown_program"

    [ $status -eq 1 ]
}

@test "[functions] checkForTools returns with 0 when programs are present" {
    run checkForTools "bats bash"

    [ $status -eq 0 ]
}

@test "[functions] checkFofrTools exits with error code 20 and message when ONE program is NOT present" {
    run checkForTools "unknown_program bats"

    [ $status -eq 20 ]
    [ $output = "Tools missing. Please install 'unknown_program' on your system." ]
}

@test "[functions] checkForTools exits with error code 20 and message when MORE programs are NOT present" {
    run checkForTools "unknown_program even_more_unknown_program"

    [ $status -eq 20 ]
    [ $output = "Tools missing. Please install 'unknown_program', 'even_more_unknown_program' on your system." ]
}

@test "[functions] checkForProjectPath" {
    [ 1 -eq 1 ]
}