#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/test_helper.sh

setup() {
    SCRIPT_VERSION='1.0-test'
    USER='John Doe'
    HOSTNAME='FUCKUP_-_First_Universal_Cybernetic_Kynetic_Ultramicro-Programmer'

    EXPECTED_PID=$$

    load $BATS_TEST_DIRNAME/../include/util.sh
    load $BATS_TEST_DIRNAME/../include/view/dialog.sh
}

@test "[view/dialog] it sets VIEW_ERROR variable" {
    assert_equal "fn_dialog_error" "$VIEW_ERROR"
}

@test "[view/dialog] it points VIEW_ERROR to the concrete implementation" {
    run functionExists $VIEW_ERROR

    assert_success
}

@test "[view/dialog] it sets VIEW_INFO variable" {
    assert_equal "fn_dialog_info" "$VIEW_INFO"
}

@test "[view/dialog] it points VIEW_INFO to the concrete implementation" {
    run functionExists $VIEW_INFO

    assert_success
}

@test "[view/dialog] it sets VIEW_LIST variable" {
    assert_equal "fn_dialog_radiolist" "$VIEW_LIST"
}

@test "[view/dialog] it points VIEW_LIST to the concrete implementation" {
    run functionExists $VIEW_LIST

    assert_success
}

@test "[view/dialog] it sets VIEW_MENU variable" {
    assert_equal "fn_dialog_menubox" "$VIEW_MENU"
}

@test "[view/dialog] it points VIEW_MENU to the concrete implementation" {
    run functionExists $VIEW_MENU

    assert_success
}

@test "[view/dialog] it sets VIEW_YES_NO variable" {
    assert_equal "fn_dialog_yesorno" "$VIEW_YES_NO"
}

@test "[view/dialog] it points VIEW_YES_NO to the concrete implementation" {
    run functionExists $VIEW_YES_NO

    assert_success
}

@test "[view/dialog] it sets VIEW_WAITING variable" {
    assert_equal "fn_dialog_progressbox" "$VIEW_PROGRESS"
}

@test "[view/dialog] it points VIEW_WAITING to the concrete implementation" {
    run functionExists $VIEW_WAITING

    assert_success
}

@test "[view/dialog] it sets BACKTITLE variable with script version, user and hostname" {
    assert_equal "bytepark release manager 1.0-test - John Doe@FUCKUP_-_First_Universal_Cybernetic_Kynetic_Ultramicro-Programmer" "$BACKTITLE"
}

@test "[view/dialog] it sets a data variable containing the path to a error log file for dialog calls" {
    assert_equal "/tmp/dialog_1_${EXPECTED_PID}" "$data"
}
