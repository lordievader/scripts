#!/bin/bash
if [ -z $1 ]; then
    echo "$0 <config-file>"
    exit
fi
interface='wlo1'
ifconfig $interface down
iwconfig $interface mode managed
ifconfig $interface up
sudo wpa_supplicant -Dwext -i $interface -c ~/Documents/Wifi/wpa_supplicant/$1.conf&
sleep 1
sudo dhclient $interface
