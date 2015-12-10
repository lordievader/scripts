#!/bin/bash
for item in `ls -a | grep '^\.'`; do
    if [[ $item != '.' ]] && [[ $item != '..' ]]; then
        du -ks $item
    fi
done | sort -nr | less
