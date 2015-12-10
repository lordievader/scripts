#!/bin/bash
export DISPLAY=:0

# Kill ssh sessions to darth-sidious
PIDS=($(ps aux|grep "[s]sh "|awk '{print $2}'))
for PID in ${PIDS[@]}; do
  KILLED=0
  COUNT=0
  while [[ $KILLED == 0 ]]; do
    echo -n 'Killing '
    if [[ $COUNT -lt 10 ]]; then
      if ps -hp $PID; then
        kill $PID
      fi
    else
      if ps -hp $PID; then
        kill -9 $PID
      fi
      break
    fi
    if [[ -z "$(ps -hp $PID)" ]]; then
      KILLED=1
    else
      COUNT=$COUNT+1
    fi
  done
done

# Kill Cantata
if pgrep cantata; then
  echo "Killing Cantata"
  pkill cantata
fi

# Unmount filesystems
/home/lordievader/scripts/mount.sh -u
