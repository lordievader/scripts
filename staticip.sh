#!/bin/bash
help="./staticip.sh <interface> <ip-address> <dns> <wifi-conf-file>"

if [ -z $1 ]; then
    echo $help
    exit
fi
remove=$(echo $2|cut -d"." -f4)
gw=${2:0:${#2}-${#remove}}1
echo Gateway: $gw
sudo ifconfig $1 $2 netmask 255.255.255.0
sudo route add default gw $gw
sudo echo "nameserver $3" | sudo tee /etc/resolv.conf
sudo wpa_supplicant -Dwext -i$1 -c $4&
