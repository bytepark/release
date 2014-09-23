# methods for dialog rendering

# cleanup
rm -f /tmp/dialog_1_* &> /dev/null

BACKTITLE="bytepark release manager ${VERSION} - ${USER}@${HOSTNAME}"
data=/tmp/dialog_1_$$

#
# renders an error message as msgbox
#
fn_dialog_error() {
    if [ $BATCHMODE = 0 ]; then
        dialog --backtitle "${BACKTITLE}" --title "Error" --msgbox "$1" 12 76
    fi
}

#
# renders an info message as msgbox
#
fn_dialog_info() {
    if [ $BATCHMODE = 0 ]; then
        dialog --aspect 76 --backtitle "${BACKTITLE}" --title "Info" --infobox "$1" 0 0
        sleep 1
    fi
}

#
# renders an radiolist
#
# @sets RETURN
#
fn_dialog_radiolist() {
    cmd="dialog --aspect 15 --backtitle \"${BACKTITLE}\" \
        --radiolist \"$1\" \
        10 60 $2 $3"
    eval $cmd 2> $data
    RETURN=$(cat $data)
}

#
# renders an menubox
#
# @sets RETURN
#
fn_dialog_menubox() {
    if [ -n "${4}" ]; then
        SIZE="${4}"
    else
        SIZE="0 0"
    fi
    cmd="dialog --aspect 15 --backtitle \"${BACKTITLE}\" \
        --menu \"$1\" \
        $SIZE $2 $3"
    eval $cmd 2> $data
    RETURN=$(cat $data)
}

#
# renders a yes or no box
#
# @sets RETURN
#
fn_dialog_yesorno() {
    dialog --defaultno --aspect 15 --backtitle "${BACKTITLE}" --title "$1" --yesno "$2" 0 0
    case $? in
        0) RETURN=1
        ;;
        1|255) RETURN=0
        ;;
    esac
}

#
# renders a waiting box
#
fn_dialog_waitingbox() {
    if [ $BATCHMODE = 0 ]; then
        if [ "$2" ]; then
            LABEL=$2
        else
            LABEL=$1
        fi
        dialog --aspect 15 --backtitle "${BACKTITLE}" --title "Bitte warten" --infobox "$LABEL" 5 76 && eval "$1"
    else
        eval "$1" 1> /dev/null 2>> ${ERRORLOG}
    fi

    # Check the return code of 'eval "$1"' and exit the program if something broke!
    # We cannot use $? here, because it will be set by the right side of the pipe
    # (dialog in this case; which will always be successful). Plus, it's not the command
    # we wanted to check.
    # The return code of the left side of the pipe is stored in $PIPESTATUS.
    function_exit_if_failed $PIPESTATUS
}

#
# renders a progress box
#
fn_dialog_progressbox() {
    if [ $BATCHMODE = 0 ]; then
        if [ "$2" ]; then
            LABEL="$2"
        else
            LABEL="Fortschritt"
        fi
        eval "$1" | dialog --aspect 15 --backtitle "${BACKTITLE}" --title "Bitte warten" --progressbox "${LABEL}" 24 76
    else
        eval "$1" 1> /dev/null 2>> ${ERRORLOG}
    fi

    # Check the return code of 'eval "$1"' and exit the program if something broke!
    # We cannot use $? here, because it will be set by the right side of the pipe
    # (dialog in this case; which will always be successful). Plus, it's not the command
    # we wanted to check.
    # The return code of the left side of the pipe is stored in $PIPESTATUS.
    function_exit_if_failed $PIPESTATUS
}
