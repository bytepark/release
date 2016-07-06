#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh

setup() {
    releasePath="${BATS_TEST_DIRNAME}/.."
    releaseIncludePath="${releasePath}/include"

    concreteView="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
}

@test "[origin] setupOrigin exits with error code 60 and message when origin NOT present" {
    run setupOrigin "non-available-origin"

    assert_status 60
    assert_failure "The origin 'non-available-origin' is not available"
}

@test "[origin] setupOrigin return with error code 0 when origin is present" {
    run setupOrigin "git"

    assert_status 0
}
