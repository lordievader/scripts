#!/usr/bin/python3
import subprocess
import os
import time

def wifi():
    command = "nmcli -p dev wifi list |grep Infra|sort|awk '{print $1}'|uniq"
    output = subprocess.getoutput(command)
    print(output)
    if '*' not in output:
        if'eduroam' in output:
            print('Eduroam!')
            command = "nmcli c up eduroam"
            print(subprocess.getoutput(command))
            process = subprocess.Popen(command, env=dict(os.environ, DISPLAY=":0"), shell=True,
                                    stderr=subprocess.PIPE,
                                    stdout=subprocess.PIPE, bufsize=1)
            for line in iter(process.stdout.readline, b''):
                print(str(line, 'utf-8').replace('\n', ''))

        elif 'Breedstraat65' in output:
            print('Breedstraat65!')
            command = "nmcli c up Breedstraat65"
            print(subprocess.getoutput(command))
            process = subprocess.Popen(command, env=dict(os.environ, DISPLAY=":0"), shell=True,
                                    stderr=subprocess.PIPE,
                                    stdout=subprocess.PIPE, bufsize=1)
            for line in iter(process.stdout.readline, b''):
                print(str(line, 'utf-8').replace('\n', ''))

def bridge(output):
    device = output.split(' ')[0]
    if device == 'br0':
        if subprocess.call('sudo fping -c1 -t100 -q 8.8.8.8', shell=True) == 1:
            subprocess.getoutput('nmcli c down bridge-br0')
            wifi()

def nm():
    command = "nmcli d|grep '\ connected'"
    output = subprocess.getoutput(command)
    if not output:
        wifi()

    else:
        bridge(output)

    print("There should be a network connection... Don't quote me on that. Really, don't. I REALLY advice you not to do that.")

if __name__ == '__main__':
    nm()
