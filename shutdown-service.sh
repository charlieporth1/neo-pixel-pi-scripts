#!/bin/bash

systemctl enable --noq ctp-led.timer ctp-led-stop.timer

systemctl stop ctp-led.service
systemctl stop ctp-led.service

bash /home/pi/neo-pixel-pi-scripts/led-off.sh

exit 0
