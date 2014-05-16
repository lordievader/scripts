#!/bin/bash
if [ -z $1 ]; then
    echo "Usage $0 <wlan-nic>"
    exit
fi

#Initial wifi interface configuration
ifconfig $1 up 10.0.2.1 netmask 255.255.255.0
sleep 2
###########Start DHCP, comment out / add relevant section##########
#Thanks to Panji
#Doesn't try to run dhcpd when already running
if [ "$(ps -e | grep dhcpd)" == "" ]; then
    dhcpd $1 &

fi
###########
#Enable NAT
#iptables --flush
#iptables --table nat --flush
#iptables --delete-chain
#iptables --table nat --delete-chain
#iptables --table nat --append POSTROUTING --out-interface $2 -j MASQUERADE
#iptables --append FORWARD --in-interface $1 -j ACCEPT
     
      
    #sysctl -w net.ipv4.ip_forward=1

#Start hostapd
hostapd /etc/hostapd/hanashi.conf -f /var/log/hostapd.log&

#Start sslstrip
#iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 4242
#sslstrip -l 4242 -a -w /var/log/sslstrip.log
service bind9 start
service apache2 start
