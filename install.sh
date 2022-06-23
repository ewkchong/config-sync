# Technically, the script is not added to PATH, but it is added to a directory that is, by default, listed in the PATH variable
# Note: adding a command/script to a directory listed in the PATH variable makes it invokable from any directory
read -p 'This will add the script to your PATH. Would you like to continue? [yes/no] ' ans
if [[ $ans =~ ^n.*$  ]]; then
    exit 0;
elif [[ $ans =~ ^y.*$ ]]; then
    :
else
    echo "Install cancelled."
    exit 0;
fi

# copy configsync script from local repository to a directory listed in PATH variable
cp ./configsync.sh /usr/local/bin/configsync
if [ ! $? -eq 0 ]; then
    echo "Unable to write to /usr/local/bin.\nYou may try running this command with root privileges, or by manually copying this script to your PATH."
    exit 1;
fi

# stores the repository path in an accessible location, for update.sh to refer to.
pwd | cat > ~/.configsync_info
if [ $? -eq 1 ]; then
    echo "Error while trying to write repo path to home directory"
    exit 1;
fi

# adds the execute permission to the update script
chmod +x ./update.sh

# copy update script from local repository to a directory listed in PATH variable, command is only invoked in configsync.sh:checkForUpdates()
cp ./update.sh /usr/local/bin/configsync-update
