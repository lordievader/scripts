#!/bin/bash
AGENT_PID=$(pgrep ssh-agent)
if [ -z $AGENT_PID ]; then
  ssh-agent
  exit
fi

for ITEM in $(ls /tmp); do
  if [[ $ITEM == ssh* ]]; then
    AGENT_SOCKET="/tmp/$ITEM/$(ls /tmp/$ITEM)"
    break
  fi
done

echo "SSH_AUTH_SOCK=$AGENT_SOCKET; export SSH_AUTH_SOCK;"
echo "SSH_AGENT_PID=$AGENT_PID; export SSH_AGENT_PID;"
echo "echo Agent pid $AGENT_PID;"
