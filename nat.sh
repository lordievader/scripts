#!/bin/bash
###########
#Enable NAT
#iptables --flush
#iptables --table nat --flush
#iptables --delete-chain
#iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $2 -j MASQUERADE
iptables --append FORWARD --in-interface $1 -j ACCEPT
     
      
sysctl -w net.ipv4.ip_forward=1

