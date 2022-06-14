REPO_PATH=$(cat ~/.configsync_info)
git -C $REPO_PATH diff --exit-code -s
if [ $? -eq 1 ]; then
    read -p "There is an update available for configsync, would you like to update? [yes|no]: " ans
    if [ "$ans" = "yes" ]; then
        git -C $REPO_PATH pull --force
        cp "${REPO_PATH}/configsync.sh" /usr/local/bin/configsync.sh
        "config-sync has been updated."
    elif [ "$ans" = "no" ]; then
        exit 0;
    else
        exit 1;
    fi
else
    :
fi
