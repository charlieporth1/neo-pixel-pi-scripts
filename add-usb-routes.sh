#!/bin/bash
alias ip='sudo ip'
# ip route | grep usb | parallel sudo ip route del
# ip addr show | grep usb | grep inet | awk '{print $2" dev "$7}' | parallel ip addr del

function add-addr() {
	dev=$1
	cidr=$2

	dev_nm=$(sudo nmcli con show | grep "$dev" | awk '{print $1" "$2" "$3}')
	sudo nmcli con mod "$dev_nm" ipv4.method manual ipv4.addresses "$cidr.2"
	# sudo nmcli con mod "$dev_nm" ipv4.addresses "$cidr.1"
	# sudo nmcli con mod "$dev_nm" ipv4.gateway "$cidr.2"
	sudo nmcli con up "$dev_nm"

	sudo ifconfig $dev $cidr.2
	sudo ip route add $cidr.0/24 dev $dev proto static scope link src $cidr.2 metric 400000

	self_addr=$( ip -4 addr show dev $dev | grep 169.254 | grep inet | awk '{print $2}'  )
	ip addr del dev $dev $self_addr
	ip addr del dev $dev $self_addr

	self_addr=$( ip -4 addr show dev $dev | grep 169.254 | grep inet | awk '{print $2}'  )
	ip addr del dev $dev $self_addr
	ip addr del dev $dev $self_addr

}



add-addr usb0 192.168.7
add-addr usb1 192.168.6

if ! command -v parallel > /dev/null; then
	apt install -y parallel
fi
ip route | grep 169.254 | parallel sudo ip route del

if ! command -v ifmetric > /dev/null; then
	apt install -y ifmetric
fi
ifmetric usb0 400000
ifmetric usb1 400001
ifmetric usb2 400002
ifmetric usb3 400003

