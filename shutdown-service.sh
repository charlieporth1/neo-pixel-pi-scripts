#!/bin/bash
arg=$1
systemctl enable --now ctp-led.timer ctp-led-stop.timer

export nowminute=$(date +%M | bc -l)
export nowhour=$(date +%H | bc -l)
if [[ $(( $nowminute  % 15 )) -eq 0 ]]; then
    systemctl restart ctp-led{,-stop}.timer
fi

export lockFile=/tmp/shutdown-led.lock
if [[ $arg = --mk-lock ]]; then
	touch $lockFile
elif [[ $arg = --rm-lock ]]; then
	rm $lockFile
fi

if [[ $nowhour -le  ]]; then
	touch $lockFile
elif [[ $nowhour -ge  ]]; then
	rm $lockFile
fi

systemctl stop ctp-led.service
systemctl stop ctp-led.service

bash /home/pi/neo-pixel-pi-scripts/shutdown-led.sh
exit 0
