#!/bin/bash
EXT_OPTIONS="$@"
COUNT=2
TIMEOUT=1

function ping_target () {
    ADDRESS="$1"
    ping -c "${COUNT}" -W "${TIMEOUT}" "${ADDRESS}" $ExT_OPTIONS >/dev/null
    if [[ "$?" != "0" ]]; then
        printf "Ping to %s failed!\n" "${ADDRESS}"
        exit 1
    else
        printf "Ping to %s suceeded!\n" "${ADDRESS}"
    fi
}

ping_target 8.8.8.8
ping_target 130.89.162.239
ping_target 10.0.1.1
ping_target 10.0.1.20
