if [ -e /usr/local/bin/configsync ]; then
    rm /usr/local/bin/configsync
fi
if [ -e /usr/local/bin/configsync-update ]; then
    rm /usr/local/bin/configsync-update
fi
if [ -e ~/.configsync_info ]; then
    rm ~/.configsync_info
fi
echo "Files associated with configsync have been removed."