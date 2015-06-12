#!/bin/bash
if [ $USER != 'root' ]; then
  echo "Please run this script as root"
  exit 1
fi

if [ -f /etc/firewall/ipset ]; then
  ipset restore < /etc/firewall/ipset
  if [ -f /etc/firewall/iptables ]; then
    iptables-restore < /etc/firewall/iptables
  else
    echo "No firewall rules found!"
  fi
  if [ -f /etc/firewall/ip6tables ]; then
    ip6tables-restore < /etc/firewall/ip6tables
  else
    echo "No ipv6 firewall rules found"
  fi
else
  echo "No ipset rules found!"
fi
