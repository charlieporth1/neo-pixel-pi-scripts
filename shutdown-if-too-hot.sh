#!/bin/bash
cpu-temp.sh
temp=`cpu-temp.sh | tr -dc '0-9'`
other_processes=`ps -aux | grep '.py' | grep -v "grep" | grep -o '.py'`
max_temp=550
if [[ $temp -ge $max_temp ]]; then
	echo "Shutting down computer too hot"
	sudo killall -9 python3
	sudo led-off.py --hot
#	timeout 15 sudo poweroff
#	timeout 20 sudo poweroff -f
elif [[ $(( $max_temp - 200 )) -le $temp  ]] && ! pgrep -f color-cycle.py; then
	echo "No other process; starting new"
	(
#		sudo color-fade.py 
#		 sudo color-cycle.py --win95 --white --more -c --time 50
		 #sudo color-cycle.py --steps=150 --more --slow --time=15 -c
#o		sudo color-cycle.py --win95 --white --more -c --time 5 --steps 145 
	      	nowhour=$(date +%H | bc -l)
        	if [[ $nowhour -ge 6 ]]; then
			echo "No other process; starting new"
        	         sudo color-cycle.py --steps=150 --more --slow --time=15 -c &
		else
			sudo killall -9 python3
			sudo led-off.py --off
        	fi
	)&
else
	sudo killall -9 python3
	sudo led-off.py --off
	echo "Not enought"
fi
