#!/bin/bash
LV="$1"
sudo lvdisplay -am /dev/corellian-corvette-vg/${LV}{,_rimage_{0,1}} 2>&1|grep 'Physical volume'|awk '{print $3}'|sort|uniq
