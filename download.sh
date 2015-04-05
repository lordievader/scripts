#!/bin/bash
Input="$1"
echo $Input
#Input=$(python -c "import urllib; print urllib.quote('''$Input''')")
echo $Input
Range1=$2
Range2=$3
Cookie=$4

for i in $(eval echo {$Range1..$Range2}); do
	echo $Input$i".jpg"

	if [ -z $Cookie ]; then 
		wget $Input$i".jpg"
	else
		wget --load-cookie=$Cookie $Input$i".jpg"
	fi
done
