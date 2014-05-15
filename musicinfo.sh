#!/bin/bash

while [ true ]; do
  clear
  /usr/share/kmc/control.py now_playing
  sleep 5
done

#while [ true ]; do
#    ping=$(ping -c1 -W1 $mpd2 2>/dev/null)
#    ping=$(echo $ping|awk '{print $1}')

#    if [ -z $ping ]; then
#        clear
#        mpc -h rinorino@$mpd1 -f "%title% by %artist% on %album%"
#        sleep 1
#    else
#        mpd=$(mpc -h rinorino@$mpd2 -f "%title% by %artist% on %album%")
#        status=$(echo $mpd|awk '{print $2}')
#        if [ $status == "n/a" ]; then
#            clear 
#            mpc -h rinorino@$mpd1 -f "%title% by %artist% on %album%"
#        else
#            clear
#            mpc -h rinorino@$mpd2 -f "%title% by %artist% on %album%"
#        fi
#        sleep 1
#    fi
#done
