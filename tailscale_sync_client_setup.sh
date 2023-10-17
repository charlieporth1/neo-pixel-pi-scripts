#!/bin/bash
source /etc/environment
[[ -d /etc/environment.d ]] && source /etc/environment.d/*.conf
if [[ -z $PROG ]]; then
	export PROG=$HOME/Programs
fi

INSTALL_DIR=/usr/local/bin/
if [[ -f $PROG/all-scripts-exports.sh ]]; then
	source $PROG/all-scripts-exports.sh
fi
if [[ -f $PROG/tailscale_sync_client_env.sh ]]; then
	source $PROG/tailscale_sync_client_env.sh
fi
if ! [[ -L $INSTALL_DIR/tailscale_sync_client_env.sh ]] || ! [[ -f $INSTALL_DIR/tailscale_sync_client_env.sh ]]; then
	rm $INSTALL_DIR/tailscale_sync_client_env.sh
fi

if [[ -f ~/tailscale_sync_client_env.sh ]]; then
	sudo ln -s ~/tailscale_sync_client_env.sh $INSTALL_DIR/tailscale_sync_client_env.sh
elif [[ -f $PROG/tailscale_sync_client_env.sh ]]; then
	sudo ln -s $PROG/tailscale_sync_client_env.sh $INSTALL_DIR/tailscale_sync_client_env.sh
else
	echo "could not find tailscale_sync_client_env.sh which is needed for setup"
#	exit 22
fi
bash $PROG/univeral_system_links.sh

[[ -f $INSTALL_DIR/tailscale_sync_client_env.sh ]] && source tailscale_sync_client_env.sh

CROND=/etc/cron.d/
CTP_INSTALL='# CTP INSTALL'

if [[ -f /etc/environment ]] && [[ -z `grep "$CTP_INSTALL" /etc/environment` ]]; then

echo """
$CTP_INSTALL `date`
PROG=$PROG
INSTALL_DIR=$INSTALL_DIR
ADMIN_USR=$USER
ADMIN_HOME=/home/$USER
CROND=$CROND
CRON=$CROND

""" | sudo tee -a /etc/environment

fi

if [[ -z `grep "$CTP_INSTALL" /etc/bash.bashrc` ]]; then
echo """
$CTP_INSTALL `date`

""" | sudo tee -a /etc/bash.bashrc

fi
TS_CRON_STR=$CROND/tailscale_$HOSTNAME

echo """
PROG=$PROG
0    *   *   *   *    root sudo bash $PROG/start_tailscale.sh
5    */3 *   *   *    root sudo bash $PROG/ban_abuse_ssh.sh
5    */4 *   *   *    root sudo bash $PROG/tailscale_sync_client_cron.sh
10   */4 *   *   *    root sudo bash $PROG/tailscale_sync_client_setup.sh
15   */4 *   *   *    root sudo bash $PROG/univeral_system_links.sh
0      0 *   *   *    root sudo geoipupdate
0      0 *   *   *    root sudo bash $PROG/updates_geoip.sh
""" | sudo tee $TS_CRON_STR-cron_setup

echo """
PROG=$PROG

*/15 *   *   *   *    root sudo bash $PROG/tailscale_client_wlan_setup.sh
*/15 *   *   *   *    root sudo bash $PROG/fix_apt.sh
*/15 *   *   *   *    root sudo bash $PROG/fix_resolvconf.sh

""" | sudo tee $TS_CRON_STR-health-checks

echo """
PROG=$PROG

*/5 *   *   *   *    root ping 1.1.1.1 -c 4 -W 10 -q || sudo reboot -f
*/5 *   *   *   *    root tailscale ip -4 || sudo tailscale up || sudo bash $PROG/start_tailscale.sh
*/5 *   *   *   *    root sudo systemctl is-active tailscaled || sudo systemctl restart tailscaled
*/5 *   *   *   *    root sudo systemctl is-active ssh || sudo systemctl restart ssh
*/10 *   *   *   *    root sudo systemctl is-active sshd || sudo systemctl restart sshd
*/10 *   *   *   *    root sudo systemctl is-active systemd-resolved || sudo systemctl restart systemd-resolved
*/10 *   *   *   *    root ifconfig tailscale0 | grep -o tailscale0 || sudo bash $PROG/start_tailscale.sh
*/10 *   *   *   *    root ping www.google.com -c 4 -W 10 -q || sudo reboot -f
""" | sudo tee $TS_CRON_STR-watchdogs

echo """
PROG=$PROG
@reboot sudo bash $PROG/start_tailscale.sh
@reboot sudo bash $PROG/fix_resolvconf.sh
@reboot sudo bash $PROG/fix_apt.sh
@reboot sudo bash $PROG/modprobes.sh
""" | sudo tee $TS_CRON_STR-rc-local-reboot

needed_installs
sudo geoipupdate
yes | sudo apt update
yes | sudo apt install -y tailscale

[[ -f $PROG/0001-login.sh ]] && sudo mv $PROG/0001-login.sh /etc/profile.d/ || echo "err file do not exist"
[[ -f $PROG/usr_env.ex3 ]] && sudo mv $PROG/usr_env.ex3 $INSTALL_DIR || echo "err not exist"


IS_AES_HW=$( cat /proc/cpuinfo | grep -io aes > /dev/null && echo true || echo false )
if [[ $IS_AES_HW == 'false' ]]; then
	curl -L https://git.io/JBWnf | sudo tee /usr/local/bin/issh
	issh -K processes
	sudo chmod +x /usr/local/bin/issh
else
	curl -sSL https://raw.githubusercontent.com/ahnick/encpass.sh/master/encpass.sh  | sudo tee /usr/local/bin/encpass.sh
fi
"""
#ForceCommand /usr/local/bin/login.sh
#ForceCommand /etc/profile.d/0001-login.sh
""" | sudo tee -a /etc/ssh/sshd_config
