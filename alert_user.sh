#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf
ARGS="$@"

source $PROG/secret_envs.sh
bash $PROG/fix_devnull.sh
LOG=/var/log/email_count.log

PHONE=$(get_secret phone)
CC=$(get_secret cc)

REPLY_TO=$CC
MAX_EMAILS=350

FILE_CREATE_DATE=`stat $LOG  | grep Access | sed -n '2p' | awk '{print $2}'`
YESTERDAY=`date -d "yesterday 00:00" '+%Y-%m-%d'`

if ! [[ -f $LOG ]]; then
        touch $LOG
elif [[ -f $LOG ]] && [[ "$YESTERDAY" == "$FILE_CREATE_DATE" ]]; then
	rm $LOG
	touch $LOG
fi

chown -R $ADMIN_USR:nogroup $LOG 2>/dev/null
chmod -R 755 $LOG 2> /dev/null

function WRITE_LOG() {
	local email="$1"
	local scount="$2"
	local data="$email,$scount,[`date`]"
	echo $data >> $LOG
}

function GET_EMAIL_COUNT() {
        local fn="$1"
        local count=`tail -100 $LOG | grep "$fn" | tail -1 | awk -F , '{print $2}'`
        echo "${count:-0}"
}

function CHOOSE_RANDOM() {
	RANDOM_ACCOUNT=$(( ( RANDOM % ${#USRS[@]} )  + 0 ))
	CHOOSE_USER "$RANDOM_ACCOUNT" 'true'
}

function CHOOSE_USER() {
		local i="$1"
		local is_random="$2"
		local USR="${USRS[$i]}"
		local COUNT=$((1+$(GET_EMAIL_COUNT "$USR")))
		if [[ $COUNT -le $MAX_EMAILS ]]; then
			declare -g COUNT="$COUNT"
			declare -xg USR="$USR"
			declare -xg PSSWD="${PSSWDS[$i]}"
		else
			if [[ "$is_random"  == 'true' ]] && [[ ${#USRS[@]} -lt $i ]]; then
				CHOOSE_USER $(( $i + 1 ))
			elif [[ ${#USRS[@]} -gt $i ]]; then
				return 1
			fi
		fi

}

function CHOOSE_ACCOUNT() {
	declare -ga PSSWDS
	local PSSWD1=$(get_secret PSSWD1)
	local PSSWD2=$(get_secret PSSWD2)
	local PSSWD3=$(get_secret PSSWD3)
	PSSWDS=("$PSSWD1" "$PSSWD2" "$PSSWD3")

	declare -ga USRS
	local USR1=$(get_secret USR1)
	local USR2=$(get_secret USR2)
	local USR3=$(get_secret USR3)
	USRS=("$USR1" "$USR2" "$USR3")

	CHANCE_OF_OTHER_ACCOUNT=40
	RANDOM_PERCENT=$(( ( RANDOM % 100 )  + 0 ))

	if [[ $RANDOM_PERCENT < $CHANCE_OF_OTHER_ACCOUNT ]]; then
		CHOOSE_RANDOM
	else
		for i in $(seq 0 ${#USR1[@]} )
		do
			CHOOSE_USER $i
		done
	fi
}

CHOOSE_ACCOUNT

(WRITE_LOG "$USR" $COUNT)&

SERVER_IP=`bash $PROG/get_ext_ip.sh --curent-ip | xargs`
FROM_USER=$USER@dns.ctptech.dev
MACHINE_DATA="machine_data:{ hostname: $HOSTNAME; date: `date`; user: $USER; email_send_count: $COUNT; email: $USR; server_ip: $SERVER_IP; from_user: $FROM_USER }"
SUB="$1"
CHANNEL_REGEX='(\-\-)(c|channel)=#.+($| )'

MSG_ARGS=$(echo -e "$ARGS" | perl -pe "s/$CHANNEL_REGEX//g" )
MSG=$( echo -e "$MSG_ARGS; \n\n{ $MACHINE_DATA }\n\n\n" )

st=$(get_secret ST)
default_chan=$(get_secret chan)

channel=`echo "$ARGS" | grep -Eio "$CHANNEL_REGEX" | awk -F= '{print $2}'`
chan="${channel:=$default_chan}"
(
	if [[ -f $PROG/bot.sh  ]]; then
		bash $PROG/bot.sh "$st" "$chan" "$HOSTNAME" "$MSG" 2>&1 /dev/null
	fi
)&>/dev/null

if command -v sendemail > /dev/null; then
	sendemail -f $FROM_USER -u "$(echo ${SUB:-$HOSTNAME} | cut -c 1-50)..." -m "$MSG" \
		-s smtp.gmail.com:587 -o tls=yes \
		-xu "$USR" -xp "$PSSWD" -q -o reply-to=$CC -t "$PHONE" -cc "$CC"
else
	yes | sudo apt install -y sendemail &>/dev/null
fi

unset ENCPASS_HOME_DIR
unset USR
unset PSSWD
unset PHONE
unset CC
unset st
unset chan
bash $PROG/fix_devnull.sh &
