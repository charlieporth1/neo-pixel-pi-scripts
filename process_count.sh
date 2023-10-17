#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf
SCRIPT=`basename $0 | rev | cut -d '/' -f 1 | rev`
SCRIPT_NAME_FULL=`basename $0`
R_PROGRAM="${1:-$SCRIPT}"
PID_TO_EXCLUDE="${2:-$$}"
FILE_NAME=`echo "$R_PROGRAM" | rev | cut -d '.' -f 2 | rev`

INPUT_PID=`echo "$@" | grep -E '[0-9]+'`

function TO_EXCLUDE() {
	local VAR="$1"
	if [[ -n "$VAR" ]] && [[ -n "$EXCLUDE_PIDS" ]]; then
	 	declare -g EXCLUDE_PIDS="$EXCLUDE_PIDS\|$VAR"
	elif [[ -n "$VAR" ]]; then
	 	declare -g EXCLUDE_PIDS="$VAR"
	fi
}

PROGRAM_GREP="$R_PROGRAM\|$FILE_NAME\|$0\|$SCRIPT_NAME_FULL"

#OTHER_EXCLUDED_PIDS=`ps -aux | grep "$PROGRAM_GREP" | grep -vE "((p)?grep|nano|vi|vim|tail|(c)?cat|perl||parellel|process_count.sh)" | awk '{print $2}' | xargs`
OTHER_EXCLUDED_PIDS=$(pgrep "((p)?grep|nano|vi|vim|tail|(c)?cat|perl||parellel|process_count.sh)")
OE_PIDS="${OTHER_EXCLUDED_PIDS//\ /\\|}"
INPUT_PIDS="${INPUT_PID//\ /\\|}"
TO_EXCLUDE $INPUT_PID
TO_EXCLUDE $LOCAL_PID
TO_EXCLUDE $BASHPID
TO_EXCLUDE $PID_TO_EXCLUDE
TO_EXCLUDE $0
TO_EXCLUDE $$
TO_EXCLUDE $OE_PIDS
TO_EXCLUDE $INPUT_PIDS


if [[ -z $R_PROGRAM ]]; then
	echo "You need to speify a program"
fi
#PROGRAM_PIDS=$(pgrep $R_PROGRAM | grep -v )

pgrep $R_PROGRAM | grep -v "$EXCLUDE_PIDS" | grep -cE "[0-9]+"
exit 0
