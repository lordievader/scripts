#!/bin/bash
declare -a hosts=(
    "archer"
    "pike"
    "kirk"
    "picard"
    "shuttlepod"
    "mrdata"
    "web"
)

for host in "${hosts[@]}"; do
    echo $host;
    ssh -t $host.openintel $@
    echo
done
