#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf
TOKEN=$1
CHANNEL=$2
USERNAME=$3
MESSAGE=$4

function push {
  local msg="$1"
  local RESPONSE=$(curl -X POST -s https://slack.com/api/chat.postMessage -v --data "token=$TOKEN&channel=$CHANNEL&text=$msg&username=$USERNAME&mrkdwn=true" 2> /dev/null )
  #echo $RESPONSE
  bash $PROG/fix_devnull.sh
}
push "$MESSAGE"
exit 0
