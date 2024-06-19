#!/bin/bash

systemctl enable --now ctp-led.timer ctp-led-stop.timer

export nowminute=$(date +%M | bc -l)
if [[ $(( $nowminute  % 15 )) -eq 0 ]]; then
	systemctl restart ctp-led{,-stop}.timer
fi

systemctl stop ctp-led.service
systemctl stop ctp-led.service

bash /home/pi/neo-pixel-pi-scripts/led-off.sh

exit 0
