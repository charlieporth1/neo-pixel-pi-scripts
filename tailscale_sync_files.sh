#!/bin/bash
source $PROG/all-scripts-exports.sh
declare -a prog_files_array
prog_files_array=(
	all-scripts-exports.sh
	get_network_devices_ip_address.sh
	get_network_devices_names.sh
	get_ext_ip.sh
	tailscale_sync{,_{files,client{,_{setup,files_list,env,cron}}}}.sh
	start_tailscale.sh
	{regex,grep,{de,}csv,new_lin{e,}}ify.sh
	process_count.sh
	univeral_system_links.sh
	phoneone.sh
	alert_user.sh
	bot.sh
	secret_envs.sh
)
