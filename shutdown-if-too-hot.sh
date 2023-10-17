#!/bin/bash
cpu-temp.sh
temp=`cpu-temp.sh | tr -dc '0-9'`
other_processes=`ps -aux | grep '.py' | grep -v "grep" | grep -o '.py'`
if [[ $temp -ge 700 ]]; then
	echo "Shutting down computer too hot"
	sudo killall -9 python3
	killall -9 sudo
	sudo led-off.py --hot
#	timeout 15 sudo poweroff
#	timeout 20 sudo poweroff -f
elif [[ 300 -le $temp  ]] ;then
	echo "No other process; starting new"
	(
#		 sudo color-cycle.py --win95 --white --more -c --time 50
		 #sudo color-cycle.py --steps=150 --more --slow --time=15 -c
#o		sudo color-cycle.py --win95 --white --more -c --time 5 --steps 145 
	       nowhour=$(date +%H | bc -l)
        	if [[ $nowhour -le 22 ]] && [[ $nowhour -eq 6 ]]; then
        	         sudo color-cycle.py --steps=150 --more --slow --time=15 -c &
        	fi
	)&
else
	echo "Not enought"
fi
