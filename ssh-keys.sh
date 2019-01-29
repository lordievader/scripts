#!/bin/bash
AGENT_PID=$(pgrep -u $USER ssh-agent|head -1)
if [[ -z "$AGENT_PID" ]]; then
  ssh-agent
  exit
fi

for ITEM in /tmp/*; do
  if [[ $ITEM == *ssh* ]] && [[ "$(stat -c '%U' $ITEM)" == $USER ]]; then
    AGENT_DIR=$ITEM
    AGENT_SOCKET=$(echo $ITEM/*)
    break
  fi
done

echo "SSH_AUTH_SOCK=$AGENT_SOCKET; export SSH_AUTH_SOCK;"
echo "SSH_AGENT_PID=$AGENT_PID; export SSH_AGENT_PID;"
echo "echo Agent pid $AGENT_PID;"
