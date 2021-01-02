#!/bin/bash
sudo killall python python3
sleep 2s
sudo echo 11 > /sys/class/gpio/export
