#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf
wlan_dev=$(ifconfig | grep -oE "wl((an)?)0")

if ifconfig | grep -oE "wl((an)?)0"; then
	sudo wpa_supplicant -i $wlan_dev -c /etc/wpa_supplicant/wpa_supplicant.conf -D nl80211 -B
elif which wpa_supplicant; then
	yes | sudo apt purge -y wpa*
fi
