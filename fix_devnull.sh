#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf

FILE=/dev/null
REQUIRED_PERMISSIONS=666
ACTUAL_PERMISSIONS=$(stat -c '%a' "$FILE")

#Wif [[ -d $FILE ]] || [[ -f $FILE ]] ||
if [[ $(( $REQUIRED_PERMISSIONS )) != $(( $ACTUAL_PERMISSIONS )) ]]; then
	echo "Fixing $FILE `[[ -f $FILE  ]] && echo true` REQUIRED_PERMISSIONS != ACTUAL_PERMISSIONS $REQUIRED_PERMISSIONS != $ACTUAL_PERMISSIONS"
	sudo rm -rf $FILE
	sudo rm -rf $FILE

	sudo mknod -m 666 $FILE c 1 3

	sudo chmod -R 666 $FILE

	sudo chown -R root:root $FILE
fi
