# Gets repo path from file, it is required to run git commmands in the repository directory, without this script being in it
# We run git commands from a different directory by passing in the -C <directory> option
# Git is used to check for new commits from the remote repository
REPO_PATH=$(cat ~/.configsync_info)
git -C $REPO_PATH fetch -q
git -C $REPO_PATH diff --exit-code -s master..origin/master

# if git diff returns an exit code of 1, that means that there are differences, so we will prompt for an update
if [ $? -eq 1 ]; then
    read -p "There is an update available for configsync, would you like to update? [yes/no]: " ans
    # If the user inputs a string that begins with y, it will perform the update
    if [[ $ans =~ ^y.*$ ]]; then
        git pull
        git -C $REPO_PATH reset --hard -q origin/master 
        cp "${REPO_PATH}/configsync.sh" /usr/local/bin/configsync
        if [ $? -eq 1 ]; then
            echo "Unable to update configsync. Please check your permissions or ensure the path to the repository is correct in ~/.configsync_info"
            exit 1;
        fi
        SUCCESS=" \x1B[1;97;42m[success]\x1B[22;0m "
        echo "configsync has been updated. Running command..."
        exit 0;
    # If the user types anything that does not start with a y, then we will exit the update script and skip updating
    else
        exit 0;
    fi
# if git diff returns an exit code of 0, that means there are no differences between the local and remote master branch, so there is no need to update
else
    exit 0;
fi
