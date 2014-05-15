#!/bin/bash
CPUCOUNT=$(cat /proc/cpuinfo |grep cores|tail -n 1|tail -c 2)
if [ $1 == "c" ];then
    while [ true ]; do
    clear

    ##            Load the data
    sensors | tail -n $(echo $CPUCOUNT +1 |bc) |head -n $CPUCOUNT > Documents/files/sensors.txt
    cat /proc/cpuinfo |grep "cpu MHz" > Documents/files/cpu.txt

    old_IFS=$IFS
    IFS=$'\n'
    line=($(cat Documents/files/sensors.txt))
    IFS=$old_IFS
    length=${#line[@]}
    length=$((length-1))

    old_IFS=$IFS
    IFS=$'\n'
    line2=($(cat Documents/files/cpu.txt))
    IFS=$old_IFS

    ##            Display the data
    for i in $(eval echo {0..$length}); do
      TEMP=$(echo ${line[$i]})
      TEMP=${TEMP:0:16}
      FREQ=$(echo ${line2[$i]})
      FREQ=${FREQ:10:10}

      echo $TEMP" at "$FREQ" MHz."
    done
  #  top -b |head -n 10 |tail -n 4
    sleep 1
  done

else
  while [ true ]; do
    clear

    ##            Load the data
    sensors | tail -n $(echo $CPUCOUNT +1 |bc) |head -n $CPUCOUNT > Documents/files/sensors.txt
    cat /proc/cpuinfo |grep "cpu MHz" > Documents/files/cpu.txt

    old_IFS=$IFS
    IFS=$'\n'
    line=($(cat Documents/files/sensors.txt))
    IFS=$old_IFS
    length=${#line[@]}
    length=$((length-1))

    old_IFS=$IFS
    IFS=$'\n'
    line2=($(cat Documents/files/cpu.txt))
    IFS=$old_IFS

    ##            Display the data
    uptime
    echo ""
    sensors | head -n 7

    for i in $(eval echo {0..$length}); do
      TEMP=$(echo ${line[$i]})
      TEMP=${TEMP:0:16}
      FREQ=$(echo ${line2[$i]})
      FREQ=${FREQ:10:10}

      echo $TEMP" at "$FREQ" MHz."
    done
    echo -n "Harddisk: "
    sudo hddtemp /dev/sda |sed 's/:/\n/g' |tail -n 1|sed 's/\ //g'
  #  top -b |head -n 10 |tail -n 4
    sleep 1
  done
fi
