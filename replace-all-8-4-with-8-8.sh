#!/bin/bash
replace_amount=$(( 8 * 4 ))
replaced_amount=$(( 8 * 8 ))

replace_str="LED_COUNT      = $replace_amount"
replace_str_1="LED_COUNT      =  $replace_amount"
replace_str_2="LED_COUNT = $replace_amount"

replaced_str="LED_COUNT      = $replaced_amount"

if ! command -v parallel; then
	apt install -y parallel
fi

for file in $( ls /home/pi/neo-pixel-raspi-py/*.py )
do
	sed -i "s/$replace_str/$replaced_str/g" $file
	sed -i "s/$replace_str_1/$replaced_str/g" $file
	sed -i "s/$replace_str_2/$replaced_str/g" $file
done
