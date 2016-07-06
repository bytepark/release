#
# bytepark release manager - view/prompt.sh
#
# (c) 2011-2016 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# View implementation with vanilla bash functions
#

# template method map for public view api
VIEW_ERROR='fn_error'
VIEW_INFO='fn_info'
VIEW_LIST='fn_list'
VIEW_MENU='fn_menu'
VIEW_YES_NO='fn_yesno'
VIEW_WAITING='fn_waiting'
VIEW_PROGRESS='fn_progress'

# methods for dialog rendering

#
# renders an error message
#
# @param message
#
fn_error() {
    if [ ${inBatchMode} = 0 ]; then
        echo -e "$1"
    fi
}

#
# renders an info message
#
# @param message
#
fn_info() {
    if [ ${inBatchMode} = 0 ]; then
        echo -e "$1"
    fi
}

#
# renders an choice list
#
# @param message
#
fn_list() {
    if [ ${inBatchMode} = 0 ]; then
        echo -e "$1"
    fi
}

#
# renders a menu
#
# @param message
#
fn_menu() {
    if [ ${inBatchMode} = 0 ]; then
        echo -e "$1"
    fi
}

#
# renders a yes/no prompt
#
# @param message
#
fn_yesno() {
    if [ ${inBatchMode} = 0 ]; then
        echo -e "$1"
    fi
}

#
# renders a waiting message
#
# @param message
#
fn_waiting() {
    if [ ${inBatchMode} = 0 ]; then
        echo -e "$1"
    fi
}

#
# renders a progress message
#
# @param message
#
fn_progress() {
    if [ ${inBatchMode} = 0 ]; then
        echo -e "$1"
    fi
}
