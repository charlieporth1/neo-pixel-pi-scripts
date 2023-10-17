
#!/bin/bash
source /etc/environment
source /etc/environment.d/*.conf

shopt -s dotglob
shopt -s expand_aliases
shopt -s extglob
shopt -s extquote
shopt -s failglob
shopt -s complete_fullquote
shopt -s globstar

DEFAULT_PROG=${PROG:=$CONF_PROG_DIR}


# LN EXYRA

if [[ -f $PROG/ctp-dns.service ]] || [[ -f /etc/systemd/system/ctp-dns.service ]]; then

	EXPERAMENTAL_ITEMS=(
				ctp-dns-list-backend.service
				ctp-network-zeroteir.service
		 		ctp-dns-adgaurd.service
				ctp-dns-dnscrypt.service
				$( [[ "$HOSTNAME" != 'ctp-vpn' ]] && echo rate-ctp-dns.service ctp-yt-ttl-dns.service ctp-YouTube-Ad-Blocker.service )
			)

	PROG_SERVICES=( $( ls $PROG/*.{service,timer} | rev | awk -F/ '{print $1}' | rev ) )

	find /etc/systemd/system/ -xtype l 2>/dev/null -exec rm {} \;
	find /lib/systemd/system/ -xtype l 2>/dev/null -exec rm {} \;

	parallel sudo rm -v '/etc/systemd/system/{}' ::: ${PROG_SERVICES[@]}
	parallel sudo rm -v '/lib/systemd/system/{}' ::: ${PROG_SERVICES[@]}

	sudo ln -s /etc/fail2ban/filter.d/ctp-custom-vars.conf /etc/fail2ban/filter.d/common.local
	sudo ln -s $PROG/{ctp-dns,nginx-dns-rfc,ctp-fail-over-dns,ctp-auto-6to4,pihole-loadbalancer-ctp-dns,rate-ctp-dns}.service /etc/systemd/system/
	sudo ln -s $PROG/*.{service,timer} /lib/systemd/system/

	sudo systemctl enable ${PROG_SERVICES[@]}
	sudo systemctl reenable ${PROG_SERVICES[@]}
	parallel sudo systemctl enable ::: ${PROG_SERVICES[@]}

	parallel sudo systemctl stop ::: ${EXPERAMENTAL_ITEMS[@]}
	parallel sudo systemctl disable ::: ${EXPERAMENTAL_ITEMS[@]}
	parallel sudo systemctl mask ::: ${EXPERAMENTAL_ITEMS[@]}

	sudo systemctl daemon-reload

	sudo rm -rf /etc/environment.d/01-PROG.conf
	sudo rm -rf /etc/environment.d/02-PROG-ROUTE.conf

	sudo ln -s /etc/environment.d/01-$HOSTNAME.conf /etc/environment.d/01-PROG.conf
	sudo ln -s /etc/environment.d/02-$HOSTNAME-route.conf /etc/environment.d/02-PROG-ROUTE.conf

fi

# LN $PROG
sudo rm -rf /usr/local/bin/{regexify,grepify,new_linify,csvify,decsvify,dnsmasq}{,.sh}
sudo rm -rf /usr/local/bin/{cat_comments,ccat}{,.sh}
sudo rm -rf /usr/local/bin/{ctp-{dns,pihole}}{,.sh}
sudo rm -rf /usr/local/bin/{netpid,timeout3}{,.sh}

sudo ln -s $DEFAULT_PROG/{regex,grep,new_lin,{de,}csv,dnsmasq,cas}ify.sh /usr/local/bin
sudo ln -s $DEFAULT_PROG/csvify.sh /usr/local/bin/csvify
sudo ln -s $DEFAULT_PROG/decsvify.sh /usr/local/bin/decsvify
sudo ln -s $DEFAULT_PROG/regexify.sh /usr/local/bin/regexify
sudo ln -s $DEFAULT_PROG/new_linify.sh /usr/local/bin/new_linify
sudo ln -s $DEFAULT_PROG/grepify.sh /usr/local/bin/grepify
sudo ln -s $DEFAULT_PROG/dnsmasqify.sh /usr/local/bin/dnsmasqify
sudo ln -s $DEFAULT_PROG/casify.sh /usr/local/bin/casify

sudo ln -s $DEFAULT_PROG/netpid.sh /usr/local/bin
sudo ln -s $DEFAULT_PROG/netpid.sh /usr/local/bin/netpid
sudo ln -s $DEFAULT_PROG/process_count.sh /usr/local/bin
sudo ln -s $DEFAULT_PROG/process_count.sh /usr/local/bin/process_count
sudo ln -s $DEFAULT_PROG/timeout3 /usr/local/bin

sudo ln -s $DEFAULT_PROG/cat_comments.sh /usr/local/bin/cat_comments.sh
sudo ln -s $DEFAULT_PROG/cat_comments.sh /usr/local/bin/cat_comments
sudo ln -s $DEFAULT_PROG/cat_comments.sh /usr/local/bin/ccat.sh
sudo ln -s $DEFAULT_PROG/cat_comments.sh /usr/local/bin/ccat

sudo ln -s $DEFAULT_PROG/ctp-pihole.sh /usr/local/bin/ctp-pihole.sh
sudo ln -s $DEFAULT_PROG/ctp-pihole.sh /usr/local/bin/ctp-pihole

# LN $ROUTE
sudo ln -s $ROUTE/ctp-dns.sh /usr/local/bin/ctp-dns
sudo ln -s $ROUTE/ctp-dns.sh /usr/local/bin/

sudo ln -s /etc/profile.d/0001-login.sh /usr/local/bin/0001-login.sh
sudo ln -s /etc/profile.d/0001-login.sh /usr/local/bin/login.sh

# CHMOD $PROG
sudo chmod 777 $ROUTE/ctp-dns.sh
sudo chmod 777 $DEFAULT_PROG/{regex,grep,new_lin,{de,}csv,dnsmasq,cas}ify.sh
sudo chmod 777 $DEFAULT_PROG/{cat_comments,netpid}.sh
sudo chmod 777 $DEFAULT_PROG/timeout3
sudo chmod 777 $DEFAULT_PROG/ctp-pihole.sh

# CHMOD /usr/local/bin/
sudo chmod 777 /usr/local/bin/ctp-{dns,pihole}{,.sh}
sudo chmod 777 /usr/local/bin/{regex,grep,new_lin,{de,}csv,cas}ify{,.sh}
sudo chmod 777 /usr/local/bin/{cat_comments,ccat,netpid}{,.sh}
sudo chmod 777 /usr/local/bin/{timeout3,certbot-ocsp-fetcher}
sudo chmod 777 /usr/local/bin/process_count{,.sh}
sudo chmod 777 /usr/local/bin/grepip
sudo chmod 777 /usr/local/bin/timeout3

find /etc/systemd/system/ -xtype l 2>/dev/null -exec rm {} \;
find /lib/systemd/system/ -xtype l 2>/dev/null -exec rm {} \;

find /usr/local/bin/ -xtype l 2>/dev/null -exec rm {} \;
find $DEFAULT_PROG/ -xtype l 2>/dev/null -exec rm {} \;

find $ROUTE -xtype l 2>/dev/null -exec rm {} \;
find $ALT_ROUTE -xtype l 2>/dev/null -exec rm {} \;
