#!/bin/bash
arg=$1

case $arg
in
	--start )
		systemctl start ctp-led-run.service
		systemctl enable ctp-led-run.timer ctp-led-stop.timer ctp-led-holiday.timer
		systemctl start ctp-led-run.timer ctp-led-stop.timer ctp-led-holiday.timer
	;;
	--stop )
		systemctl stop ctp-led-run.service
	;;
esac
