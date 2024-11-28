#!/bin/bash
# vars
dir=$(dirname $0)

export HOME=/home/pi
export PROG=$HOME/Programs

# misc setup
find -L $HOME -type l -exec rm -rf {} \; -not -path "/mnt/*"
find -L /home/pi -type l -exec rm -rf {} \; -not -path "/mnt/*"
cd $dir

# apt & dpkg
dpkg --configure -a
apt install -y python3 python3-pip python3-full
apt install -y bc jq

# pip
# https://www.pysysops.com/2018/07/23/Running-Tasks-Based-on-Public-Holidays.html
# https://stackoverflow.com/questions/75608323/how-do-i-solve-error-externally-managed-environment-every-time-i-use-pip-3
pip install --break-system-packages publicholiday

# perms
chmod +x *.sh
chmod +x /usr/local/bin/
chmod -x *.timer
chmod -x *.service

# install
sudo -E ln -s $HOME/neo-pixel-pi-scripts $PROG
#sudo -E ln -s $dir $PROG

sudo -E cp -vrf ./ctp-led.{timer,service} /etc/systemd/system
sudo -E cp -vrf ./ctp-led*.{timer,service} /etc/systemd/system

# systemd
sudo -E systemctl daemon-reload
sudo -E systemctl enable --now ctp-led.timer
sudo -E systemctl enable --now ctp-led.service
sudo -E systemctl enable --now ctp-led-stop.timer
sudo -E systemctl enable --now ctp-led-stop.service
sudo -E systemctl enable --now ctp-led*

# systemd ext
sudo systemctl restart ctp-led*
sudo systemctl restart ctp-led.timer ctp-led.service
sudo systemctl status ctp-led.timer ctp-led.service | grep ''
# env
echo "PROG=$PROG" | sudo -E tee -a /etc/environment
sudo -E ln -s $PROG/cpu-temp.sh  /usr/local/bin

# git stash; git pull -ff; sudo -E ./install.sh
# git add .; git commit -m "Automatic commit from host $HOSTNAME at: `date`"; git push
