#!/bin/bash
arg=$1

case $arg
in
	--start )
		systemctl start ctp-led-run.service
	;;
	--stop )
		systemctl stop ctp-led-run.service
	;;
esac
