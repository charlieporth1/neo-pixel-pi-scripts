#!/bin/bash
set +e
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf
source $PROG/all-scripts-exports.sh --no-log --no-copy $@

WLAN_REGEX="w(i|l)((o|fi|an)?)[0-9]+"
wlan_dev=$(ifconfig -a | grep -oE "$WLAN_REGEX")

wpa_name=wpa_supplicant

extra_config_file=/etc/$wpa_name.conf
def_config_file=/etc/$wpa_name/$wpa_name.conf


config_file=$def_config_file
if ! [[ -f $config_file ]] && [[ -f $extra_config_file ]]; then
	config_file=$extra_config_file
else
	echo "Error no config files need to create config file $def_config_file"
fi

fn0=ctp-wpa.service
fn1=$wpa_name.service
fn=$fn0
service=$fn

if [[ -z $wlan_dev ]]; then
	apt purge -y wpa* iw*
	rm /etc/cron.d/wlan-setup
	systemctl disable --now  $service
	systemctl mask $service
else
	systemctl unmask $fn0
	systemctl enable $fn0
	systemctl enable --now $fn1
fi

run_dir=/run/$wpa_name
run_file=$run_dir/$wlan_dev

if ! command -v grepip &> /dev/null
then
	needed_installs
fi

if ! command -v wpa_supplicant; then
	sudo apt install -y wpasupplicant
fi

if ! command -v iw; then
	sudo apt install -y iw
fi

if ! command -v dhcpcd; then
	sudo apt install -y dhcpcd5
	sudo systemctl enable dhcpcd
	sudo systemctl start dhcpcd
fi

if ! command -v dhclient; then
	sudo apt install -y isc-dhcp-client
fi

function is-wlan-connected() {
	iw_link=$(iw $wlan_dev link | grep -o 'Not connected.')
	ip_addr=$(ip addr show dev $wlan_dev | grep -v 169.254 | grepip -4o)
	if [[ -n $iw_link ]]; then
		return 1
	elif [[ -z $ip_addr ]]; then
		return 2
	else
		return 0
	fi

}
export -f is-wlan-connected
if ! is-wlan-connected; then
	if [[ -f $run_file ]]; then
		rm $run_file
	fi
	wpa_supplicant -D nl80211,wext -c $config_file -i $wlan_dev
	sudo wpa_action $wlan_dev CONNECTED
fi
