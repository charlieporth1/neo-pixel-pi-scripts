#!/bin/bash
p=/home/pi/neo-pixel-pi-scripts
bash $p/led-off.sh
bash $p/led-off.sh
sudo killall -9 python3
pgrep -f led-off.py | xargs sudo kill -9
sudo led-off.py --off
sudo led-off.py --off
