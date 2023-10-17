#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf

if [[ -z $PROG ]]; then
	l_PROG=/home/$USER/Programs

	if [[ -d $l_PROG ]] || [[ -L $l_PROG ]]; then
		export PROG=$l_PROG
	elif [[ -n $ADMIN_HOME ]]; then
                export PROG=$ADMIN_HOME/Programs
                mkdir -p $PROG
        elif [[ -n $ADMIN_USR ]]; then
                export PROG=/home/$ADMIN_USR/Programs
                mkdir -p $PROG
	fi
else
	export PROG=$PROG
	export prog=$PROG
fi

export CROND=/etc/cron.d/
source $PROG/tailscale_sync_files.sh
export INSTALL_DIR=/usr/local/bin/

BOOK_REGEX="(chrome|mac)((book)?)"
GALAXY_REGEX="(galaxy|tab)((tab|s)?)"
TV_REGEX='tv'
NAS_REGEX='(ds|wd|my)((my)?(cloud|720plus)?)'
DESKTOP_REGEX='(mpc66|desktop-ru7renf)'
export REGEX_AROUND_HOSTS="($DESKTOP_REGEX|$BOOK_REGEX|$GALAXY_REGEX|$NAS_REGEX|$TV_REGEX|hello|ctp-vpn|fly)"

[[ -f $PROG/all-scripts-exports.sh ]] && source $PROG/all-scripts-exports.sh
