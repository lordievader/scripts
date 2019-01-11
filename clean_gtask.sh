#!/bin/bash
# Cleans Google tasks.
TASK="python2 /opt/tasky/tasky.py"
NUM_TASK_LISTS=$($TASK -l -s|tail -n 1|head -c 1)
for ((i=0;i<=NUM_TASK_LISTS;i++)); do
    $TASK -c --tasklist $i
done
