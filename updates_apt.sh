#!/bin/bash
source /etc/environment
source /etc/environment.d/*.conf
yes | dpkg --configure -a
yes | apt -y update
yes | apt -y upgrade
yes | apt -y full-upgrade
yes | apt -y dist-upgrade
yes | apt -y autoremove
yes | apt -y autoclean
