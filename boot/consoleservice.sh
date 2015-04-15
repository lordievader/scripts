#!/bin/bash
while [ true ]; do
	Wlan=$(ifconfig |grep wlan)
	if [ -z $Wlan ]; then
		clear
		acpi -b
		echo "Wireless is down"
	else
		Signal=$(iwconfig wlan0|grep -e 'Signal level'|awk {'print $4'}|tail -c 4)
		Rate=$(iwconfig wlan0 |grep "Bit Rate"|awk {'print $2'}|tail -c 3)
		Link=$(iwconfig wlan0 |grep "Link"|awk {'print $2'}|tail -c 6)
		clear
		acpi -b
		echo "Signal level: "$Signal" dBm, Bit rate: "$Rate" Mb/s, Link quality: "$Link
		#mpc -h 192.168.178.14
	fi
	sleep 5
done
