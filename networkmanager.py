#!/usr/bin/python3
import subprocess

command = "nmcli g|grep disconnected"
if subprocess.getoutput(command):
    command = "nmcli -p dev wifi list |grep Infra|sort|awk '{print $1}'|uniq"
    output = subprocess.getoutput(command)
    if '*' not in output and 'eduroam' in output:
        command = "nmcli c up eduroam"
        print(subprocess.getoutput(command))
