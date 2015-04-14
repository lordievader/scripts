#!/bin/bash
NUMPACKAGES=$(echo $0|sed 's,.*top\([0-9]*\).*,\1,')
qsize -am | awk '{
Package = substr($1, 1, length($1) - 1);
Size = $6;
printf "%u %s\n", Size, Package;
}'|sort -nr|head -n $NUMPACKAGES|awk '{
Package = $2;
Size = $1;
printf "%s -- %u MiB\n", Package, Size;
}'|less
