#!/bin/bash
export PROG=/home/pi/Programs
sudo -E ln -s $HOME/neo-pixel-pi-scripts $PROG
sudo -E cp -vrf ./ctp-led.{timer,service} /etc/systemd/system
sudo -E systemctl daemon-reload
sudo -E systemctl enable --now ctp-led.timer
sudo -E systemctl enable --now ctp-led.service

echo "PROG=$PROG" | sudo -E tee -a /etc/environment
sudo -E ln -s $PROG/cpu-temp.sh  /usr/local/bin
