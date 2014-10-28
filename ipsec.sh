#!/bin/bash

action=$1
config=$2
if [ -z "$action" ]; then
  echo "Please select an action and config"
  exit
fi

function get_ip () {
  ip=$(ip a s $1 |grep inet|grep -v inet6|awk '{print $2}')
}

function get_nics () {
  nics=($(ip link|grep ":\ "|awk '{print $2}'|sed 's/://g'))
  declare -A nic_ip
  for nic in ${nics[@]}; do
    get_ip $nic
    if [ "$ip" != '' ]; then   
      nic_ip[$nic]=$ip
    fi
  done
  #for nic in ${!nic_ip[@]}; do
  #  echo "$nic --> ${nic_ip[$nic]}"
  #done
}

function get_gateway () {
  get_nics
  for nic in ${!nic_ip[@]}; do
    echo "$nic --> ${nic_ip[$nic]}"
  done
}

function start_vpn () {
  sudo service ipsec start
  sudo service xl2tpd start
  sleep 1
  sudo ipsec auto --up "$1"
  echo "c vpn-$1" |sudo tee /var/run/xl2tpd/l2tp-control

  sleep 1
  ip=$(ip a s ppp0|grep inet|grep -v inet6|awk '{print $2}')
  sudo ip route add 10.0.1.0/24 dev ppp0 src $ip
}

function stop_vpn () {
  ip=$(ip a s ppp0|grep inet|awk '{print $2}')
  sudo ip route del 10.0.1.0/24 dev ppp0 src $ip
  
  echo "d vpn-$1" |sudo tee /var/run/xltpd/l2tp-control
  sudo ipsec auto --down "$1"
  sudo service xl2tpd stop
  sudo service ipsec stop
}

case "$action" in
  up)
    start_vpn $config
    ;;
  down)
    stop_vpn $config
    ;;
  test)
    get_gateway
    ;;
esac
