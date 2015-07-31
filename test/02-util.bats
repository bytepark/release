#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh
load $BATS_TEST_DIRNAME/../include/util.sh

@test "[util] functionExists returns with 0 when the function exists" {
    run functionExists functionExists

    assert_success
}

@test "[util] functionExists returns with 1 when the function exists not" {
    run functionExists veryNonExistingFunction

    assert_failure
}

@test "[util] toUpper returns strings in upper case" {
    run toUpper "all lower"

    assert_success "ALL LOWER"
}

@test "[util] toUpper returns numbers as they are" {
    run toUpper 0

    assert_success "0"
}

@test "[util] inArray returns 0 when needle is in haystack" {
    needle="one"
    anArray=(one two three)
    haystack=$(echo ${anArray}[@])
    run inArray "$needle" "$haystack"

    assert_status 0
}

@test "[util] inArray returns 1 when needle is not in haystack" {
    needle="four"
    anArray=(one two three)
    haystack=$(echo ${anArray}[@])
    run inArray "$needle" "$haystack"

    assert_status 1
}
