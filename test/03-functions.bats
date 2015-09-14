#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh

setup() {
    releasePath="${BATS_TEST_DIRNAME}/.."
    releaseIncludepath="${releasePath}/include"

    concreteView="prompt"
    load $BATS_TEST_DIRNAME/../include/bootstrap.sh
}

@test "[functions] guardEmptyOrExitWithError returns 0 on success" {
    run guardEmptyOrExitWithError "" 1 "NON EMPTY"

    assert_success
}

@test "[functions] guardEmptyOrExitWithError exits with error code and message on guard failure" {
    run guardEmptyOrExitWithError "A" 1 "NON EMPTY"

    assert_failure "NON EMPTY"
}

@test "[functions] guardNonEmptyOrExitWithError returns 0 on success" {
    run guardNonEmptyOrExitWithError "non empty" 1 "EMPTY"

    assert_success
}

@test "[functions] guardNonEmptyOrExitWithError exits with error code and message on guard failure" {
    run guardNonEmptyOrExitWithError "" 1 "EMPTY"

    assert_failure "EMPTY"
}

@test "[functions] guardSuccessfulCallOrExitWithError returns 0 on success" {
    run guardSuccessfulCallOrExitWithError "ls" 1 "EXEC FAILED"

    assert_success
}

@test "[functions] guardSuccessfulCallOrExitWithError exits with error code and message on guard failure" {
    run guardSuccessfulCallOrExitWithError "ls-this-should-fail" 1 "EXEC FAILED"

    assert_failure "EXEC FAILED"
}

@test "[functions] checkForTool returns 0 when program is present " {
    run checkForTool "bats"

    assert_success
}

@test "[functions] checkForTool returns 1 when program is NOT present" {
    run checkForTool "unknown_program"

    assert_failure
}

@test "[functions] checkForTools returns with 0 when programs are present" {
    run checkForTools "bats bash"

    assert_success
}

@test "[functions] checkForTools exits with error code 20 and message when ONE program is NOT present" {
    run checkForTools "unknown_program bats"

    assert_status 20
    assert_failure "Tools missing. Please install 'unknown_program' on your system."
}

@test "[functions] checkForTools exits with error code 20 and message when MORE programs are NOT present" {
    run checkForTools "unknown_program even_more_unknown_program"

    assert_status 20
    assert_failure "Tools missing. Please install 'unknown_program', 'even_more_unknown_program' on your system."
}

@test "[functions] parseProjectPath returns error code 0 and populates the global variables when in a project" {
    expectedProjectPath=$(normalizedPath "$BATS_TEST_FILENAME")
    expectedProject=$(basename "$expectedProjectPath")
    expectedProjectConfigDir="${expectedProjectPath}/.release"

    run parseProjectPath "${BATS_TEST_DIRNAME}"

    assert_success
    assert_equal "$PROJECT_PATH" "$expectedProjectPath"
    assert_equal "$PROJECT" "$expectedProject"
    assert_equal "$PROJECT_CONFIG_DIR" "$expectedProjectConfigDir"
 }


@test "[functions] parseProjectPath returns error code 1 and DOES NOT populate the global variables when NOT in a project" {
    PROJECT=""
    PROJECT_PATH=""
    PROJECT_CONFIG_DIR=""

    run parseProjectPath "/etc"

    assert_failure
    assert_equal "$PROJECT_PATH" ""
    assert_equal "$PROJECT" ""
    assert_equal "$PROJECT_CONFIG_DIR" ""
}

@test "[functions] loadConfiguration returns 0 on success" {
    run loadConfiguration "deb" "test2"

    assert_success
}

@test "[functions] loadConfiguration exits with error code 41 when an old release configuration is called" {
    run loadConfiguration "deb" "test"

    assert_status 41
}

@test "[functions] loadConfiguration exits with error code 40 and message on failure" {
    run loadConfiguration "deb" "wrong-target"

    assert_status 40
    assert_failure "Release configuration 'deb.wrong-target.conf' not found. Aborting."
}

@test "[functions] executeIfFileExists executes command if file exists" {
    FILE="foo"
    touch $FILE

    run executeIfFileExists "echo 'Hello World'" $FILE

    rm $FILE

    assert_success
    assert_equal "$output" "Hello World"
}

@test "[functions] executeIfDirExists executes command if directory exists" {
    DIR="foo"
    mkdir $DIR

    run executeIfDirExists "echo 'Hello World'" $DIR

    rm -r $DIR

    assert_success
    assert_equal "$output" "Hello World"
}

@test "[functions] executeIfFileExists does not execute command if file does not exist" {
    run executeIfFileExists "echo 'Hello World'" "unknown_file"

    assert_status 50
    assert_equal "$output" ""
}

@test "[functions] executeIfDirExists does not execute command if dir does not exist" {
    run executeIfDirExists "echo 'Hello World'" "unknown_dir"

    assert_status 51
    assert_equal "$output" ""
}
