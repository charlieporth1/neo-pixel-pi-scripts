#!/bin/bash
$PROG=$HOME/Programs
sudo ln -s $HOME/neo-pixel-pi-scripts $PROG
sudo cp -rf $PROG/ctp-led.{timer,service} /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable --now ctp-led.timer
sudo systemctl enable --now ctp-led.service

echo "PROG=$PROG" | sudo tee -a /etc/environment
sudo ln -s $PROG/cpu-temp.sh  /usr/local/bin
