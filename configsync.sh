#!/bin/sh
usage() { echo "usage: $(basename $0) [-p <PROJECT-ID>] [-e <ENVIRONMENT-NAME>] [-y]" >&2; exit 1; }

SUCCESS=" \x1B[1;97;42m[success]\x1B[22;0m "
ERROR=" \x1B[1;97;41m[error]\x1B[22;0m "

checkForUpdates() {
    configsync-update "$@"
    if [ $? -eq 1 ]; then
        exit 0;
    fi
}
createPatch() {
    if [ ! -d './config/sync' ]
    then
        echo "${ERROR}No config/sync/ folder detected, please make sure you are using this command in a project repository." >&2
        exit 1;
    fi
    if ! command -v platform &> /dev/null
    then
        echo "platform.sh CLI is not installed, please install it and try again"
        exit 1;
    fi
    if [ -z ${pid} ] && [ -z ${eid} ]; then
        HOST=$(platform ssh --pipe)
    elif [ -z ${pid} ] && [ ! -z ${eid} ]; then
        HOST=$(platform ssh --pipe -e $eid)
    elif [ ! -z ${pid} ] && [ -z ${eid} ]; then
        HOST=$(platform ssh --pipe -p $pid)
    else
        HOST=$(platform ssh --pipe -p $pid -e $eid)
    fi
    if [ -z ${yes} ]; then
        read -p 'This will overwrite any changes you currently have in the config/sync folder, would you like to continue? [yes/no] ' ans
        if [ $ans != "yes" ]; then
            echo "Configuration synchronization has been cancelled."
            exit 0;
        fi
    fi
    echo "Connecting to site using SSH..."
    ssh $HOST 'drush cex -n --destination=/tmp/config' 2>/dev/null 1>/dev/null
    echo "Config exported, now performing sync with local working tree..."
    rsync -r $HOST:/tmp/config/ config/sync --exclude '.gitkeep' --exclude '.htaccess' --exclude 'README.txt' --delete 1>/dev/null
    if [ $? -eq 1 ]; then
        echo "${ERROR}Unable to perform rsync."
    else
        echo "${SUCCESS}Config has been applied to working tree."
    fi
   }

checkForUpdates
trap "kill $$" SIGINT
while getopts ":p:e:y" op; do
    if [ ! -e ~/.configsync_info ]; then
        echo "${ERROR}config-sync has not yet been installed."
        exit 1;
    fi
    case $op in
        p)
            pid=${OPTARG}
            ;;
        e)
            eid=${OPTARG}
            ;;
        y)
            yes=true
            ;;
        ?)
            usage 
            ;;
    esac
done

createPatch
