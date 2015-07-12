#!/bin/bash
CURDIR=$(pwd)
for item in $CURDIR/*; do
  ext=${item: -3}
  if [[ $ext != 'srt' ]] && [[ $ext != 'sub' ]] && [[ $ext != 'idx' ]]; then
    DATA=$(ffmpeg -i "$item" 2>&1|grep "from\|Video:")
    echo $DATA |sed -e "s,.*'\(/.*\)'\:\ .*\ \([0-9]\+\)x\([0-9]\+\)[ \,].*,\1-\2-\3,g"|awk -F '-' '{
      file = $1;
      width = $2;
      height = $3;
      if ( width < 1280)
      {
        printf "%4s x %4u %-100s\n", width, height, file;
      }
    }'
  fi
done|sort -n
