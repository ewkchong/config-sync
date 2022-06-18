# if [ -e '/usr/local/bin/configsync' ]; then
#     echo "This tool is already installed."
#     exit 0;
# fi
read -p 'This will add the script to your PATH. Would you like to continue? [yes/no] ' ans
if [ "$ans" = "no" ]; then
    exit 0;
elif [ "$ans" = "yes" ]; then
    :
else
    echo "Install cancelled."
    exit 0;
fi
cp ./configsync.sh /usr/local/bin/configsync
if [ ! $? -eq 0 ]; then
    echo "Unable to write to /usr/local/bin.\nYou may try running this command with root privileges, or by manually copying this script to your PATH."
    exit 1;
fi
pwd | cat > ~/.configsync_info
if [ $? -eq 1 ]; then
    echo "Error while trying to write repo path to home directory"
    exit 1;
fi
chmod +x ./update.sh
cp ./update.sh /usr/local/bin/configsync-update
