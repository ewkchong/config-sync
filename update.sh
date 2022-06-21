REPO_PATH=$(cat ~/.configsync_info)
git -C $REPO_PATH fetch
git -C $REPO_PATH diff --exit-code -s
if [ $? -eq 1 ]; then
    read -p "There is an update available for configsync, would you like to update? [yes/no]: " ans
    if [ "$ans" = "yes" ]; then
        git -C $REPO_PATH reset --hard -q $(git remote)/master 
        cp "${REPO_PATH}/configsync.sh" /usr/local/bin/configsync
        if [ $? -eq 1 ]; then
            echo "Unable to update configsync. Please check your permissions or ensure the path to the repository is correct in ~/.configsync_info"
            exit 1;
        fi
        SUCCESS=" \x1B[1;97;42m[success]\x1B[22;0m "
        echo "configsync has been updated. Running command..."
        exit 0;
    else
        exit 0;
    fi
else
    exit 0;
fi
