#!/bin/bash
while [ true ]; do
    interfaces=($(iwconfig 2>/dev/null|grep IEEE|awk '{print $1}'))
    for item in ${interfaces[@]}; do
        bit_rate=$(iwconfig $item|grep "Bit Rate"|awk '{print $2}'|cut -d= -f2)
        link_quality=$(cat /proc/net/wireless|grep $item|awk '{print $3}'|sed 's,\.,,g')
        signal_level=$(cat /proc/net/wireless|grep $item|awk '{print $4}'|sed 's,\.,,g')
        noise_level=$(cat /proc/net/wireless|grep $item|awk '{print $5}'|sed 's,\.,,g')
        if [ -z $bit_rate ]; then

            cat /dev/null
        else

            echo "$item Bit: $bit_rate Mb/s, Link: $link_quality, Signal: $signal_level dBm, Noise: $noise_level dBm"
        fi
    done
    sleep 5
done
