#!/bin/bash
systemctl start cron tailscaled
systemctl start ctp-led.timer ctp-led-stop.timer
systemctl enable --now ctp-led.timer ctp-led-stop.timer

p=/home/pi/neo-pixel-pi-scripts
bash $p/led-off.sh
bash $p/led-off.sh
sudo killall -9 python3
pgrep -f led-off.py | xargs sudo kill -9
sudo led-off.py --off
sudo led-off.py --off
