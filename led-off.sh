#!/bin/bash
sudo killall -9 python python3
pgrep -f py | xargs sudo kill -9
sleep 2s
sudo echo 11 > /sys/class/gpio/export
