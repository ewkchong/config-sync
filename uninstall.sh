if [ -e /usr/local/bin/configsync ]; then
    rm /usr/local/bin/configsync
fi
if [ -e /usr/local/bin/configsync-update ]; then
    rm /usr/local/bin/configsync-update
fi
if [ -e ~/.configsync_info ]; then
    rm ~/.configsync_info
fi
# Confirm that files have been removed
if [ -e /usr/local/bin/configsync ]  || [ -e /usr/local/bin/configsync-update ] || [ -e ~/.configsync_info ]; then
    echo "\n Unable to remove one or all of the following:
    • '/usr/local/bin/configsync'
    • '/usr/local/bin/configsync-update'
    • '~/.configsync_info'
        \n You may try running this command with root privileges, or by manually removing these items. Exiting with error. \n"
    exit 1;
else
    echo "Files associated with configsync have been removed."
fi