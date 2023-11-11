#!/bin/bash
export PROG=/home/pi/Programs
sudo -E ln -s $HOME/neo-pixel-pi-scripts $PROG
sudo -E cp -vrf ./ctp-led.{timer,service} /etc/systemd/system
sudo -E systemctl daemon-reload
sudo -E systemctl enable --now ctp-led.timer
sudo -E systemctl enable --now ctp-led.service
sudo systemctl restart ctp-led.timer ctp-led.service
sudo systemctl status ctp-led.timer ctp-led.service | grep ''

echo "PROG=$PROG" | sudo -E tee -a /etc/environment
sudo -E ln -s $PROG/cpu-temp.sh  /usr/local/bin

# git stash; git pull -ff; sudo -E ./install.sh
