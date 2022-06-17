#!/bin/sh
usage() { echo "usage: $(basename $0) [-p <PROJECT-ID>]" >&2; exit 1; }

createPatch() {
    if [ ! -d './config/sync' ]
    then
        echo "No config/sync/ folder detected, please make sure you are using this command in a project repository." >&2
        exit 1;
    fi

    HOST=$(platform ssh --pipe)
    # HOST="${pid}-master-7rqtwti--app@ssh.ca-1.platform.sh"
    ssh $HOST 'drush cex -n --destination=/tmp/config' 2>/dev/null 
    rsync -r $HOST:/tmp/config/ config/sync
   }

install() {
    # if [ -e '/usr/local/bin/configsync' ]; then
    #     echo "This tool is already installed."
    #     exit 0;
    # fi
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
