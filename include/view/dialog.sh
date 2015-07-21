#
# bytepark release manager - view/dialog.sh
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# View implementation with the dialog tool
#

# template method map for public view api
VIEW_ERROR='fn_dialog_error'
VIEW_INFO='fn_dialog_info'
VIEW_LIST='fn_dialog_radiolist'
VIEW_MENU='fn_dialog_menubox'
VIEW_YES_NO='fn_dialog_yesorno'
VIEW_WAITING='fn_dialog_waitingbox'
VIEW_PROGRESS='fn_dialog_progressbox'

# methods for dialog rendering

# cleanup
rm -f /tmp/dialog_1_* &> /dev/null

BACKTITLE="bytepark release manager ${SCRIPT_VERSION} - ${USER}@${HOSTNAME}"
data=/tmp/dialog_1_$$

#
# renders an error message as msgbox
#
# @param message
#
fn_dialog_error() {
    if [ ${BATCHMODE} = 0 ]; then
        dialog --backtitle "${BACKTITLE}" --title "Error" --msgbox "$1" 12 76
        clear
    fi
}

#
# renders an info message as msgbox
#
# @param message
#
fn_dialog_info() {
    if [ ${BATCHMODE} = 0 ]; then
        dialog --aspect 76 --backtitle "${BACKTITLE}" --title "Info" --infobox "$1" 0 0
        sleep 1
    fi
}

#
# renders an radiolist
#
# @param
# @param
# @param
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
# @param
# @param
# @param
# @param
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
# @param
# @param
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
# @param
# @param
#
fn_dialog_waitingbox() {
    if [ ${BATCHMODE} = 0 ]; then
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
# @param
# @param
#
fn_dialog_progressbox() {
    if [ ${BATCHMODE} = 0 ]; then
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
