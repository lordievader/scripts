#!/bin/bash
INTERFACE="$1"
ESSID="$2"
data=($(iw $INTERFACE scan|grep -B8 $ESSID|sed -e 's/[[:space:]]\+/_/g'))
for line in ${data[@]}; do
echo $line|sed -e 's/^_//g' -e 's/_/\ /g'
done;

