#!/bin/bash
for i in $(ssh -Q cipher)
do
    dd if=/dev/zero bs=1000000 count=1000 2> /dev/null | ssh -c $i localhost "(/usr/bin/time -p cat) > /dev/null" 2>&1 | grep real | awk '{print "'$i':\t "1000 / $2" MB/s" }';
done
