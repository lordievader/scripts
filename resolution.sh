#!/bin/bash
CURDIR=$(pwd)
for item in $CURDIR/*; do
  RESOLUTION=$(ffmpeg -i "$item" 2>&1|grep Video | head -n1 |sed -e 's,.* \([0-9]\+x[0-9]\+\)[ \,].*,\1,')
  echo $RESOLUTION -- $item
done
