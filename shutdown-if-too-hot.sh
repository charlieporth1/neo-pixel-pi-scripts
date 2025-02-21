#!/bin/bash
export PATH="/opt/vc/bin:$PATH"
cpu-temp.sh

# args
arg=$1

# static vars
src_dir=/home/pi/neo-pixel-pi-scripts
lockFile=/tmp/shutdown-led.lock
shutFile=/tmp/shutdown-led.shutdown
overFile=/tmp/shutdown-led.override
is_day_hit=0
max_temp=575

# dynmaic vars
computer_date=$(date +%F)
day=$(date +%a)
dom=$(date +%d)
mo=$(date +%m)
current_year=$(date +%Y)
hours=$(echo $(seq 8 17))
cased_hours=${hours//\ /|}
export nowminute=$(date +%M | bc -l)
export nowhour=$(date +%H | bc -l)

temp=`cpu-temp.sh | tr -dc '0-9'`
process_count=$(pgrep -c -f color-cycle.py)
other_processes=`ps -aux | grep '.py' | grep -v "grep" | grep -o '.py'`

# 40.1 *C
# 401  *C

# systemd
systemctl start cron tailscaled
systemctl start ctp-led.timer ctp-led-stop.timer
systemctl enable --now tailscaled cron
systemctl enable --now ctp-led.timer ctp-led-stop.timer

# install bins
bin=bc
if ! command -v $bin; then
	apt install -y $bin
fi

bin=jq
if ! command -v $bin; then
	apt install -y $bin
fi

if [[ $(( $nowminute  % 15 )) -eq 0 ]]; then
    systemctl restart ctp-led{,-stop}.timer
fi

# accept / run
function accept-action() {
	if ! [[ -f $shutFile ]]
	then
		declare -gx is_day_hit=1
		echo "Hooray!"
		rm $lockFile
		declare -gx ec=0
	fi
}

# fail / shutdown
function fail-action() {
	if [[ $is_day_hit -eq 0 ]] && \
	 ! [[ -f $overFile ]]
	then
		bash $src_dir/shutdown-led.sh
		touch $shutFile
		declare -gx ec=0
		exit $ec
	fi
}


# Calculate the date of the fourth Thursday of November

case $nowhour
in
	7|8|9|10|11|12|13|14|15|16|17 )
		# dynamic days
		thanksgiving_date=$(bash $src_dir/x-day-of-the-week-of-month.sh November 4 4)
		black_fri_date=$(bash $src_dir/x-day-of-the-week-of-month.sh November 5 4)
		black_fri_date_1=$(bash $src_dir/x-day-of-the-week-of-month.sh November 5 5)
		if [[ $thanksgiving_date -eq $computer_date ]]; then
			accept-action
		elif [[ $black_fri_date -eq $computer_date ]]; then
			accept-action
		elif [[ $black_fri_date_1 -eq $computer_date ]]; then
			accept-action
		else
			is_day_hit=0
		fi
		# https://stackoverflow.com/questions/3490032/how-to-check-if-today-is-a-weekend-in-bash
		# static days
		case $dom
		in
			01 )
				case $mo
				in
					01 )
						accept-action
					;;
					* )
						fail-action
						exit $ec
					;;
				esac
			;;
			04 )
				case $mo
				in
					07 )
						accept-action
					;;
					* )
						fail-action
						exit $ec
					;;
				esac
			;;
			23 | 24 | 25 | 31 )
				case $mo
				in
					12 )
						accept-action
						declare -gx special_day=1225
					;;
					* )
						fail-action
						exit $ec
					;;
				esac
			;;


			* )
				case $day in
				    Sat | Sun )
						accept-action
				    ;;
				    * )
						fail-action
						exit $ec
				    ;;
				esac
			;;
		esac
	;;
	0|1|2|3|4|5|6 )
		case $day in
			Fri | Sat | Sun )
				# accept-action
				fail-action
				exit $ec
			;;
			* )
				fail-action
				exit $ec
		 	;;
		esac
	;;
	* )
		accept-action
	;;
esac


function run() {
	array=($@)
	args=${array[@]:2:99}
	bin=$1
	#sudo killall -9 python3
	#pgrep -f $bin | xargs sudo kill -9
	if ! [[ $lockFile ]]; then
		$bin $args &
	fi
	pgrep -f $bin > /run/led-ctp.pid
	return 0
}

if [[ $arg = --off ]]; then
	bash $src_dir/shutdown-led.sh
	bash $src_dir/shutdown-led.sh
	exit 0
fi
if [[ $temp -ge $max_temp ]]; then
	echo "Shutting down computer too hot"
	run led-off.py --hot
	# timeout 15 sudo poweroff
	# timeout 20 sudo poweroff -f
elif [[ $temp -le $(( $max_temp - 100 )) ]] && [[ $process_count -eq 0 ]]; then
	echo "No other process; starting new"
	# sudo color-fade.py
	# sudo color-cycle.py --win95 --white --more -c --time 50
	# sudo color-cycle.py --steps=150 --more --slow --time=15 -c
	# sudo color-cycle.py --win95 --white --more -c --time 5 --steps 145
   	nowhour=$(date +%H | bc -l)
	echo "No other process; starting new"
	case $special_day
	in
		1225 )
			run chrismiss.py
		;;
		* )
			run color-cycle.py --steps=150 --more --slow --time=15 -c
		;;
	esac


else
	run led-off.py --off
	echo "Not enought"
fi
