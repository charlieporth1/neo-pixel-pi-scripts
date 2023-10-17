#!/bin/bash
source /etc/environment
source /etc/environment.d/*.conf
source $PROG/all-scripts-exports-lite.sh
ROOT_DIR=/var/lib/GeoIP
TYPE=mmdb

cd $ROOT_DIR

CITY=GeoLite2-City
COUNTRY=GeoLite2-Country
ASN=GeoLite2-ASN

if ! [[ -d $ROOT_DIR ]]; then
	mkdir -p $ROOT_DIR
fi
LIC_KEY=mV3V4EX4EXP3t4Bn
ACCOUNT_ID=418536



wget -O $ROOT_DIR/$ASN.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=$LIC_KEY&suffix=tar.gz"



# Database URL
wget -O $ROOT_DIR/$COUNTRY.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=$LIC_KEY&suffix=tar.gz"

wget -O $ROOT_DIR/$CITY.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$LIC_KEY&suffix=tar.gz"


for t_file in $( ls *.tar.gz )
do
	tar -vxf $t_file
done
cp -vrf $ROOT_DIR/*/*.$TYPE $ROOT_DIR


if command -v geoipupdate
then
	if ! [[ -f /etc/GeoIP.conf ]]; then
echo """
# Please see https://dev.maxmind.com/geoip/geoipupdate/ for instructions
# on setting up geoipupdate, including information on how to download a
# pre-filled GeoIP.conf file.

# Enter your account ID and license key below. These are available from
# https://www.maxmind.com/en/my_license_key. If you are only using free
# GeoLite databases, you may leave the 0 values.
AccountID 418536
LicenseKey hZdv1kKyn75FF2wk

# Enter the edition IDs of the databases you would like to update.
# Multiple edition IDs are separated by spaces.
#
# Include one or more of the following edition IDs:
# * GeoLite2-ASN - GeoLite 2 ASN
# * GeoLite2-City - GeoLite 2 City
# * GeoLite2-Country - GeoLite2 Country
EditionIDs GeoLite2-Country GeoLite2-City GeoLite2-ASN
""" | sudo tee /etc/GeoIP.conf
	fi

	sudo geoipupdate -v
else
	needed_installs
fi
