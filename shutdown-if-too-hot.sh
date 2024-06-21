#!/bin/bash
export PATH="/opt/vc/bin:$PATH"
cpu-temp.sh
temp=`cpu-temp.sh | tr -dc '0-9'`
other_processes=`ps -aux | grep '.py' | grep -v "grep" | grep -o '.py'`
# 40.1 *C
# 401  *C
max_temp=575
arg=$1
process_count=$(pgrep -c -f color-cycle.py)

systemctl enable --now ctp-led.timer ctp-led-stop.timer

bin=bc
if ! command -v $bin; then
	apt install -y $bin
fi
bin=jq
if ! command -v $bin; then
	apt install -y $bin
fi

export nowminute=$(date +%M | bc -l)
export nowhour=$(date +%H | bc -l)
if [[ $(( $nowminute  % 15 )) -eq 0 ]]; then
        systemctl restart ctp-led{,-stop}.timer
fi

export lockFile=/tmp/shutdown-led.lock
day=$(date +%a)
hours=$(echo $(seq 8 17))
cased_hours=${hours//\ /|}
case $nowhour
in
	8|9|10|11|12|13|14|15|16|17 )
	# https://stackoverflow.com/questions/3490032/how-to-check-if-today-is-a-weekend-in-bash
		case $day in
		    Sat|Sun)
			echo "Hooray!"
			rm $lockFile
		    ;;
		    * )
			bash /home/pi/neo-pixel-pi-scripts/shutdown-led.sh
			touch $lockFile
			exit 0
		    ;;
		esac
	;;
	* )
		echo not hours
		rm $lockFile
	;;
esac


function run() {
	array=($@)
	args=${array[@]:2:99}
	bin=$1
	sudo killall -9 python3
	pgrep -f $bin | xargs sudo kill -9
	$bin $args &
	pgrep -f $bin > /run/led-ctp.pid
	return 0
}
if [[ $arg = --off ]]; then
	bash /home/pi/neo-pixel-pi-scripts/shutdown-led.sh
	bash /home/pi/neo-pixel-pi-scripts/shutdown-led.sh
	exit 0
fi
if [[ $temp -ge $max_temp ]]; then
	echo "Shutting down computer too hot"
	run led-off.py --hot
#	timeout 15 sudo poweroff
#	timeout 20 sudo poweroff -f
elif [[ $temp -le $(( $max_temp - 100 )) ]] && [[ $process_count -eq 0 ]]; then
	echo "No other process; starting new"
#		sudo color-fade.py 
#		 sudo color-cycle.py --win95 --white --more -c --time 50
		 #sudo color-cycle.py --steps=150 --more --slow --time=15 -c
#o		sudo color-cycle.py --win95 --white --more -c --time 5 --steps 145 
      	nowhour=$(date +%H | bc -l)
	echo "No other process; starting new"
	run color-cycle.py --steps=150 --more --slow --time=15 -c

else
	run led-off.py --off
	echo "Not enought"
fi
