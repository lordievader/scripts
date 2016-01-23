#!/usr/bin/python3
if __name__ == '__main__':
    exit()

import os
import subprocess

def kill_pids(output):
    pids = output.split('\n')
    pids = [int(x) for x in pids]
    for pid in pids:
        os.kill(pid, 15)

def kill_ssh():
    # Kill netcats
    output = subprocess.getoutput("ps aux|grep 'ssh\ .*\ netcat'|awk '{print $2}'")
    if output:
        kill_pids(output)

    output = subprocess.getoutput("ps aux|grep 'ssh\ '| awk '{print $2}'")
    if output:
        kill_pids(output)

    output = subprocess.getoutput("ps aux|grep 'ssh:\ '|awk '{print $2}'")
    if output:
        kill_pids(output)
