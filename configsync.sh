#!/bin/sh
usage() { echo "usage: $(basename $0) [-p <PROJECT-ID>]" >&2; exit 1; }

createPatch() {
    if [ ! -d './config/sync' ]
    then
        echo "No config/sync/ folder detected, please make sure you are using this command in a project repository." >&2
        exit 1;
    fi

    HOST="${pid}-master-7rqtwti--app@ssh.ca-1.platform.sh"
    # see README.md for details about this command
    ssh $HOST 'drush cex --diff -n --ansi' 2>&1 |
        sed -re "s|/tmp/drush_tmp_[0-9]{10}_.{13}/|/config/sync/|g"\
        -e "s,\x1B\[[0-9;]*[a-zA-Z],,g"\
        -e '/^\[warning\]/,$d'\
        -e 's|^rename\ from\ \/|rename\ from\ |g'\
        -e 's|^rename\ to\ \/|rename\ to\ |g'\
        -e '/diff/,$!d' > configsync.diff
    trap 'rm configsync.diff' EXIT
    if [ ! $? -eq 0 ]
    then
        echo "There was an error connecting to the master site, please check to make sure you have the following:\n\t The correct project ID\n\t Access to the project\n\t git\n\t zsh" >&2
        rm configsync.diff
        exit 1;
    elif [ ! -s configsync.diff ]
    then
        echo "There are no configuration changes to sync."
        rm configsync.diff
        exit 0;
    fi
    REMOTE=$(git remote)
    git diff-index --exit-code --quiet ${REMOTE}/master ./config/sync/
    if [ ! $? -eq 0 ]
    then
        echo "Please check that all files in config/sync/ are clean, in sync with master, and try again." >&2
        rm configsync.diff
        exit 1;
    fi
    git apply --reject configsync.diff
    if [ $? -eq 0 ]
    then
        echo "\nConfiguration successfully synced."
    fi
    rm configsync.diff
}

install() {
    if [ -e '/usr/local/bin/configsync' ]; then
        echo "This tool is already installed."
        exit 0;
    fi
    read "This will add the script to your PATH. Would you like to continue? [yes/no]: " ans
    if [ $ans = "no" ]; then
        exit 0;
    elif [ $ans = "yes" ]; then
        :
    else
        echo "Install cancelled."
        exit 0;
    fi
    cp $(basename $0) /usr/local/bin/configsync
    if [ ! $? -eq 0 ]; then
        echo "Unable to write to /usr/local/bin.\nYou may try running this command with root privileges, or by manually copying this script to your PATH."
        exit 1;
    fi
}

while getopts "p:" op; do
    if [ ! -e ~/.configsync_info ]; then
        echo "config-sync has not yet been installed."
        exit 1;
    fi
    case $op in
        p)
            configsync-update
            pid=${OPTARG}
            createPatch
            ;;
        ?)
            usage
            ;;
    esac
done
if [ $OPTIND -eq 1 ]; then usage; fi
