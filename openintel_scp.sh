#!/bin/bash
for host in archer pike kirk picard shuttlepod web; do
    echo $host
    scp -r $1 $host.openintel:$2
    echo
done

echo mrdata
scp -r $1 mrdata.openintel:$2
