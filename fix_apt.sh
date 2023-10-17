#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf
sudo apt -y --fix-broken install
sudo dpkg --configure -a
