#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf

blue='\e[0;34m'
green='\e[0;32m'
cyan='\e[0;36m'
red='\e[0;31m'
yellow='\e[1;33m'
white='\e[1;37m'
nc='\e[0m'

alert="alert"
owner="owner"
Login="Login"
IP="IP"
tracked="tracked"
sent="sent"
sms="sms"
email="email"


# DON BECAUSE OF GREPIP NOT ON ARM AND INCABLE
if [[ `grepip --version` != '0.2' ]]; then
	other_grep_ip_arg='-o'
fi

IP_ADD=$(last -1 --time-format notime | awk '{print $3}' | grepip $other_grep_ip_arg )
IPv4_ADD=$(last -1 --time-format notime | awk '{print $3}' | grepip $other_grep_ip_arg -4 )
IPv6_ADD=$(last -1 --time-format notime | awk '{print $3}' | grepip $other_grep_ip_arg -6 )

IP_ADD=${IP_ADD:=$IPv4_ADD}
IP_ADD=${IP_ADD:=$IPv6_ADD}

MMDB_GEO_DIR=/var/lib/GeoIP
GEO_UPDATE_DIR=/usr/share/GeoIP

ROOT_GEO_DIR=$MMDB_GEO_DIR
MOST_ACC_DB=GeoLite2-City.mmdb

if ! [[ -d $MMDB_GEO_DIR ]] && [[ -d $GEO_UPDATE_DIR ]]; then
		ROOT_GEO_DIR=$GEO_UPDATE_DIR
else
	ROOT_GEO_DIR=$MMDB_GEO_DIR
	if ! [[ -f $ROOT_GEO_DIR/$MOST_ACC_DB ]]; then
		if [[ -f $PROG/updates_geoip.sh ]]; then
			(sudo bash $PROG/updates_geoip.sh)&>/dev/null
		fi
	fi
fi

# https://stackoverflow.com/questions/14802807/compare-files-date-bash
# -nt = newer then
# -ot = older than
if [ $GEO_UPDATE_DIR/$MOST_ACC_DB -ot $ROOT_GEO_DIR/$MOST_ACC_DB ]; then
	ROOT_GEO_DIR=$MMDB_GEO_DIR
else
	ROOT_GEO_DIR=$GEO_UPDATE_DIR
fi

if [[ -n "$IP_ADD" ]]; then
	geoIPCity=`mmdblookup -f $ROOT_GEO_DIR/GeoLite2-City.mmdb -i $IP_ADD | grep en -A 1 | grep "<utf8_string>" | cut -d "\"" -f 2-2 | xargs`
	geoIPASN=`mmdblookup -f $ROOT_GEO_DIR/GeoLite2-ASN.mmdb -i $IP_ADD | grep en -A 1 | grep "<utf8_string>" | cut -d "\"" -f 2-2| xargs`
	geoIPCountry=`mmdblookup -f $ROOT_GEO_DIR/GeoLite2-Country.mmdb -i $IP_ADD | grep en -A 1 | grep "<utf8_string>" | cut -d "\"" -f 2-2| xargs`

	ALT_IP_INFO=$(ipinfo $IP_ADD)
else
	STR="Private IP of $IP_ADD"
	geoIPCity="$STR"
	geoIPASN="$STR"
	geoIPCountry="$STR"
fi

tailscaled_device=$(tailscale status | awk '{print $1" "$2}' | grep -oE "$IP_ADD.+($| )" )

if [[ -n $tailscaled_device ]]; then
	tailscaled_ip=$(tailscale ip)
	tailscale_msg=$(echo "Login in from tailscale device $tailscaled_device to $tailscaled_ip with hostname $HOSTNAME")
fi
loginINFO="Someone has logged into your one of your servers under the User: $USER;\n\n and the Server: $HOSTNAME; at the time of $(date); \n\nthe external IP address of the login was from $IP_ADD; the GeoIP $geoIPCountry; $geoIPCity; the ISP of the login $geoIPASN; \n\n$tailscale_msg. \n\nALT INFO  $ALT_IP_INFO"
(
	bash $PROG/alert_user.sh "$loginINFO" --channel="#login"
	bash $PROG/fix_devnull.sh
)&>/dev/null

echo -e "$yellow$Login $red$alert$nc $yellow$sent$nc to the $yellow$owner$nc of this server via $cyan$sms$nc over $cyan$email$nc"
echo -e "Your IP has been $yellow$tracked$nc; your $yellow$IP$nc address is $red$IP_ADD$nc"
echo -e "Your locations is $geoIPCountry $geoIPCity"
echo -e "Alt ip info \n$ALT_IP_INFO"
echo -e "If you log-off nothing will happen to you"




unset loginINFO

