#!/bin/bash
AGENT_PID=$(pgrep -u lordievader ssh-agent|head -1)
for AGENT_DIR in /tmp/ssh-*; do
  if [[ "$(stat -c '%U' $AGENT_DIR)" == $USER ]]; then
    AGENT_SOCKET=$(echo $AGENT_DIR/*)
    break
  fi
done

echo "export SSH_AGENT_PID=$AGENT_PID;"
echo "export SSH_AUTH_SOCK=$AGENT_SOCKET;"
