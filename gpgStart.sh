#!/bin/bash
PID=$(ps aux|grep \[g\]pg-agent|awk '{print $2}')
if [[ -z $PID ]]; then
    eval $(gpg-agent --daemon)
    echo "export GPG_AGENT_INFO=$GPG_AGENT_INFO"
else
    SOCKET=$(/bin/ls /tmp/gpg*/S.gpg-agent)
    AGENT_INFO=$SOCKET:$PID:1
    export GPG_AGENT_INFO=$AGENT_INFO
    echo "export GPG_AGENT_INFO=$GPG_AGENT_INFO"
fi
