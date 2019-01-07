#!/bin/bash

### variables
UNINSTALL_SCRIPT_DIR=$(echo "$(cd "${BASH_SOURCE[0]%/*}" && pwd)")

SERVICE_NAME=com.network.select
SERVICE_INSTALL_PATH=/Library/LaunchDaemons
SCRIPT_NAME=network_select
SCRIPT_INSTALL_PATH=/Library/Scripts/custom

# UniqueID of loggedInUser
loggedInUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#UNIQUE_USER_ID="$(dscl . -read /Users/$loggedInUser UniqueID | awk '{print $2;}')"
UNIQUE_USER_ID=$(id -u "$loggedInUser")

LOGDIR=/var/log
LOGFILE="$LOGDIR"/"$SCRIPT_NAME".log

# other launchd services
other_launchd_services=(
com.hostsfile.install_update
com.cert.install_update
)

launchd_services=(
"${other_launchd_services[@]}"
"$SERVICE_NAME"
)


### deleting script
if [[ -f "$SCRIPT_INSTALL_PATH"/"$SCRIPT_NAME".sh ]]
then
    sudo rm -f "$SCRIPT_INSTALL_PATH"/"$SCRIPT_NAME".sh
else
    :
fi


### unloading and disabling (-w) launchd service
if [[ $(sudo launchctl list | grep "$SERVICE_NAME") != "" ]]
then
    sudo launchctl unload "$SERVICE_INSTALL_PATH"/"$SERVICE_NAME".plist
    sudo launchctl disable system/"$SERVICE_NAME"
    sudo launchctl remove "$SERVICE_NAME"
else
    :
fi


### enabling ohter launchd services
# checking if installed and disabled, if yes, enable
for i in "${other_launchd_services[@]}"
do
    if [[ $(sudo launchctl print-disabled system | grep "$i" | grep true) != "" ]];
    then
        #echo "enabling "$i"..."
        sudo launchctl enable system/"$i"
    else
        :
    fi
done


### deleting launchd service
if [[ -f "$SERVICE_INSTALL_PATH"/"$SERVICE_NAME".plist ]]
then
    sudo rm -f "$SERVICE_INSTALL_PATH"/"$SERVICE_NAME".plist
else
    :
fi


### deleting logfile
if [[ -f "$LOGFILE" ]]
then
    sudo rm -f "$LOGFILE"
else
    :
fi


### checking installation
if [[ $(ps aux | grep /install_"$SCRIPT_NAME"_and_launchdservice.sh | grep -v grep) == "" ]]
then
    echo ''
    echo "checking installation..."
    sudo "$UNINSTALL_SCRIPT_DIR"/checking_installation.sh
    wait
else
    :
fi


#echo ''
echo "uninstalling done..."
echo ''
