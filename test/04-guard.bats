#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh

setup() {
    releasePath="${BATS_TEST_DIRNAME}/.."
    releaseIncludePath="${releasePath}/include"

    concreteView="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
}

@test "[guard] guardEmptyOrExitWithError returns 0 on success" {
    run guardEmptyOrExitWithError "" 1 "NON EMPTY"

    assert_success
}

@test "[guard] guardEmptyOrExitWithError exits with error code and message on guard failure" {
    run guardEmptyOrExitWithError "A" 1 "NON EMPTY"

    assert_failure "NON EMPTY"
}

@test "[guard] guardNonEmptyOrExitWithError returns 0 on success" {
    run guardNonEmptyOrExitWithError "non empty" 1 "EMPTY"

    assert_success
}

@test "[guard] guardNonEmptyOrExitWithError exits with error code and message on guard failure" {
    run guardNonEmptyOrExitWithError "" 1 "EMPTY"

    assert_failure "EMPTY"
}

@test "[guard] guardSuccessfulCallOrExitWithError returns 0 on success" {
    run guardSuccessfulCallOrExitWithError "ls" 1 "EXEC FAILED"

    assert_success
}

@test "[guard] guardSuccessfulCallOrExitWithError exits with error code and message on guard failure" {
    run guardSuccessfulCallOrExitWithError "ls-this-should-fail" 1 "EXEC FAILED"

    assert_failure "EXEC FAILED"
}
