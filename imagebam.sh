#!/bin/bash
while [ 1 ]; do
#Input=$1
read -p "Link? " Input
echo $Input
Code=$(echo $Input|sed 's/\//\n/g'|tail -n 1|sed 's/\./\n/g'|head -n 1)
Link=$(echo "www.imagebam.com/image/"$Code)
#wget -nv $Link
Linkie=$(cat $Code |grep "<a href"|grep "imagebam.com/download"|sed 's/\ /\n/g'|grep href|sed -e 's/href=//g' -e "s/'//g")
#wget -nv  $Linkie
chromium-browser $Link
#rm $Code
done
