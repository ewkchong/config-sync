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

while getopts "p?:e?:" op; do
    if [ ! -e ~/.configsync_info ]; then
        echo "config-sync has not yet been installed."
        exit 1;
    fi
    case $op in
        p)
            configsync-update
            pid=${OPTARG}
            echo $pid 
            # createPatch
            ;;
        e)
            configsync-update
            eid=${OPTARG}
            echo $eid
            # createPatch
            ;;
        ?)
            usage
            ;;
    esac
done
if [ $OPTIND -eq 1 ]; then usage; fi
