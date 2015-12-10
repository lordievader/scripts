#!/bin/bash
HOST="$1"
INTERFACE="$2"
USER="$3"
if [[ $HOST == '' ]]; then
  echo "No remote host given..."
  exit 1
fi

if [[ $INTERFACE == '' ]]; then
  INTERFACE='eth0'
fi

if [[ $USER == '' ]]; then
  USER='root'
fi

ssh root@$HOST tcpdump -U -s0 -i $INTERFACE -w - 'not port 22' | wireshark -k -i -
