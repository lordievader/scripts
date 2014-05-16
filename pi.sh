#!/bin/bash
help="./pi.sh <NIC-to-Pi> <NIC-to-internet> <gateway>"

if [ -z $1 ]; then
    echo $help
    exit
fi

pi=$1
internet=$2
gw=$3

# Options
bridge=1
dhcp=1
bind=1
sslstrip=0

#Initial wifi interface configuration
ifconfig $pi down
killall dhcpd
service bind9 stop
sleep 2

ifconfig $pi up 10.0.2.1 netmask 255.255.255.0
sleep 2

# DHCP
if [ $dhcp == 1 ]; then
    if [ "$(ps -e | grep dhcpd)" == "" ]; then
        dhcpd $pi &
    fi
fi

# Bind
if [ $bind == 1 ]; then
    service bind9 start
fi

# NAT
if [ $bridge == 1 ]; then
    sysctl -w net.ipv4.ip_forward=1
    iptables --table nat --append POSTROUTING --out-interface $internet -j MASQUERADE
    iptables --append FORWARD --in-interface $pi -j ACCEPT
    iptables --append FORWARD --in-interface $internet -j ACCEPT
    #route del default
    #route add default gw $gw
fi

# Start sslstrip
if [ $sslstrip == 1 ]; then
    iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 4242
    sslstrip -l 4242 -a -w /var/log/sslstrip.log
fi
