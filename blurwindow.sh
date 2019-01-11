#!/bin/bash
konsoles=$(qdbus|grep konsole|awk '{print$1}')
for konsole in $konsoles; do
    windows=$(qdbus $konsole|grep 'MainWindow_[0-9]\+$')
    for window in $windows; do
        id=$(qdbus $konsole $window winId)
        xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $id
    done
done
