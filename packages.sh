#!/bin/bash
dpkg-query -W --showformat='${Installed-Size}\t${Package}\n' | sort -nr | less
