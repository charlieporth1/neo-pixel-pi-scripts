#!/bin/bash
cpu-temp.sh
temp=`cpu-temp.sh | tr -dc '0-9'`
other_processes=`ps -aux | grep '.py' | grep -v "grep" | grep -o '.py'`
if [[ $temp -ge 525 ]]; then
	echo "Shutting down computer too hot"
	sudo killall -9 python3
	killall -9 sudo
	sudo led-off.py --hot
#	timeout 15 sudo poweroff
#	timeout 20 sudo poweroff -f
elif [[ -z "$other_processes" ]] && [[ $temp -le 450 ]] ;then
	echo "No other process; starting new"
	(
#		 sudo color-cycle.py --win95 --white --more -c --time 50
		 #sudo color-cycle.py --steps=150 --more --slow --time=15 -c
#o		sudo color-cycle.py --win95 --white --more -c --time 5 --steps 145 
		 sudo color-cycle.py --win95 --white --more -c --time 1 --steps 1000
	)&
else
	echo "Not enought"
fi
