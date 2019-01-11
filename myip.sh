#!/bin/bash
curl  whatismyip.org 2>&1|grep -A1 "Your IP Address:"|tail -n 1|sed -e 's,^.*">,,' -e 's,</.*$,,'
