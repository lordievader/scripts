#!/bin/bash
if [ -z $1 ]; then
    echo "$0 <interface> <config-file>"
    exit
fi
ifconfig $1 down
iwconfig $1 mode managed
ifconfig $1 up
sudo wpa_supplicant -Dwext -i $1 -c $2&
sleep 5
sudo dhclient $1
