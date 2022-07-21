#!/bin/sh
usage() { echo "usage: $(basename $0) [-p <PROJECT-ID>] [-e <ENVIRONMENT-NAME>] [-y]" >&2; exit 1; }

# Coloured message prefixes. To learn more, see "ANSI Escape Sequences" online.
SUCCESS=" \x1B[1;97;42m[success]\x1B[22;0m "
ERROR=" \x1B[1;97;41m[error]\x1B[22;0m "

# Run update script that was installed in install.sh, quit configsync if it fails
# Note: all original command arguments are passed to update script (via $@), but this currently has no effect
checkForUpdates() {
    configsync-update "$@"
    REPO_PATH=$(cat ~/.configsync_info)
    cp "${REPO_PATH}/update.sh" /usr/local/bin/configsync-update
    if [ $? -eq 1 ]; then
        exit 0;
    fi
}

# Uses platform ssh to grab ssh host URI, runs drush cex to a writable directory, performs an rsync to local directory
createPatch() {
    # Ensure that configsync has met conditions to run properly (config/sync directory exists, platform CLI is installed)
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

    # Store the ssh host URI, passing different options depending on the original command's options; store in variable HOST
    if [ -z ${pid} ] && [ -z ${eid} ]; then
        HOST=$(platform ssh --pipe)
    elif [ -z ${pid} ] && [ ! -z ${eid} ]; then
        HOST=$(platform ssh --pipe -e $eid)
    elif [ ! -z ${pid} ] && [ -z ${eid} ]; then
        HOST=$(platform ssh --pipe -p $pid)
    else
        HOST=$(platform ssh --pipe -p $pid -e $eid)
    fi

    # if a -y flag was passed, do not ask for confirmation. See below for options parser.
    if [ -z ${yes} ]; then
        read -p 'This will overwrite any changes you currently have in the config/sync folder, would you like to continue? [yes/no] ' ans
        if [[ ! $ans =~ ^y.*$ ]]; then
            echo "Configuration synchronization has been cancelled."
            exit 0;
        fi
    fi
    
    echo "Connecting to site using SSH..."

    # Run drush cex on remote machine with 'no interaction' option and destination of a writable directory; output gets redirected to /dev/null to suppress output
    ssh $HOST 'drush cex -n --destination=/tmp/config' 2>/dev/null 1>/dev/null

    echo "Config exported, now performing sync with local working tree..."

    # Perform recursive rsync on local and remote config folders, excluding certain files that should not be modified by a config sync
    rsync -r $HOST:/tmp/config/ config/sync --exclude '.gitkeep' --exclude '.htaccess' --exclude 'README.txt' --delete 1>/dev/null
    if [ $? -eq 1 ]; then
        echo "${ERROR}Unable to perform rsync."
    else
        echo "${SUCCESS}Config has been applied to working tree."
    fi
   }

# First, check for updates using checkForUpdates()
checkForUpdates

# Make sure that if the user presses CTRL-C, the configsync is killed
trap "kill $$" SIGINT

# Parse command line options
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

# Perform the patch after all command line options have been parsed
createPatch
