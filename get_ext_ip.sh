#!/bin/bash
#dig +short myip.opendns.com @resolver1.opendns.com
# dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com
# dig -t aaaa +short myip.opendns.com @resolver1.opendns.com
# curl -6 https://ifconfig.co
# curl -6 https://ipv6.icanhazip.com  
# curl https://api64.ipify.org
# curl -6 http://ipinfo.io/ip
# telnet -6 ipv6.telnetmyip.com 
#   ssh -6 sshmyip.com
# ip -6 addr show scope global 
#curl ifconfig.co/json
source /etc/environment 
ARGS="$@"
timeout=4
function get_ext_ip() {
	local isIPv6="$1"
	local iface="$2"

	if [[ "$isIPv6" == '-6' ]]; then
		local CURL_IP_TYPE=-6
		local DNS_IP_TYPE=AAAA
		local IPv_REGEX='^(([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4})$'
	else
		local CURL_IP_TYPE=-4
		local DNS_IP_TYPE=A
		local IPv_REGEX=^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$
	fi

	if [[ -n "$iface" ]]; then
		local CURL_IFACE="--interface $iface"
		local DIG_IFACE="-b $(ifconfig $iface | awk '{print $2}' | grepip $CURL_IP_TYPE | sed -n '1p')"
	fi

	local IP_THRU_DNS=`dig -t $DNS_IP_TYPE $DIG_IFACE +short myip.opendns.com @resolver1.opendns.com +timeout=$timeout +retry=2 +tries=2`
	local IP_THRU_CURL=`timeout $timeout curl $CURL_IP_TYPE $CURL_IFACE -s -w '\n' 'https://api64.ipify.org/' || echo "$IP_THRU_DNS"`
	if [[ $IP_THRU_DNS =~ $IPv_REGEX ]]; then
		echo $IP_THRU_DNS
	elif [[ $IP_THRU_CURL =~ $IPv_REGEX ]]; then
		echo $IP_THRU_CURL
	else
		timeout $(( $timeout * 2 )) curl $CURL_IP_TYPE $CURL_IFACE -s -w '\n' 'https://api64.ipify.org'
	fi
}

[[ -z `echo "$ARGS" | grep -Eio '(\-\-|\-)(h|host)(=| )'` ]]
[[ -n `echo "$ARGS" | grep -Eio '(\-\-|\-)(mn|multiple-nic)'` ]] && export MUTI_NIC=true || MUTI_NIC=false
[[ -n `echo "$ARGS" | grep -io '\-6'` ]] && export IPv=-6 || export IPv=-4

if [[ -n `echo "$ARGS" | grep -Eio '(\-\-|\-)(ip|ip-address|cip|current-ip)'` ]]; then
	get_ext_ip $IPv
elif [[ "$MUTI_NIC" == 'true' ]]; then

	NICS=$(ifconfig | grep -Eio "^$ETH_DEVICE_REGEX")
	for nic in $NICS
	do
		get_ext_ip $IPv $nic
	done

else
	HOST="${1:-dns.ctptech.dev}"
#	export EXT_IP=`host $HOST | awk '{print $4}'`
	export EXT_IP=`dig +short $HOST`
	printf "$EXT_IP\n"
fi
