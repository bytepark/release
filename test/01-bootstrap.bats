#!/usr/bin/env bats

setup() {
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/.."
    SCRIPT_INCLUDEPATH="${SCRIPT_PATH}/include"

    CONCRETE_VIEW="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
}

@test "[bootstrap] Variables are initialized after bootstrapping" {
    skip "will have to find out how to check variables from loaded script"
}
