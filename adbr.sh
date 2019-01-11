#!/bin/bash
TURN=$1
IP=$2
if [[ -z "$IP" ]]; then
    IP='10.0.1.16'
fi
if [[ "$TURN" == "on" ]]; then
    echo "Enabeling remote debugging on $IP"
    adb tcpip 5555
    adb connect $IP:5555
else
    echo "Disabeling remote debugging on $IP"
    adb -s $IP:5555 usb
fi
