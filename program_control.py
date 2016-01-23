#!/usr/bin/python3
if __name__ == '__main__':
    exit()

import os
import subprocess

def spawnDaemon(func):
    # do the UNIX double-fork magic, see Stevens' "Advanced
    # Programming in the UNIX Environment" for details (ISBN 0201563177)
    try:
        pid = os.fork()
        if pid > 0:
            # parent process, return and keep running
            return
    except OSError as e:
        print("fork #1 failed: %d (%s)" % (e.errno, e.strerror))
        sys.exit(1)

    os.setsid()

    # do second fork
    try:
        pid = os.fork()
        if pid > 0:
            # exit from second parent
            sys.exit(0)
    except OSError as e:
        print("fork #2 failed: %d (%s)" % (e.errno, e.strerror))
        sys.exit(1)

    # do stuff
    FNULL = open(os.devnull, 'w')
    print(subprocess.Popen(func, shell=True, close_fds=True,
                            stdout=FNULL, stderr=subprocess.STDOUT,
                            preexec_fn=os.setpgrp))

    # all done
    os._exit(os.EX_OK)

def check_command(command):
    return not subprocess.call(command, shell=True)

def run_command(command, output=False):
    process = subprocess.Popen(
        command, shell=True, stderr=subprocess.PIPE,
        stdout=subprocess.PIPE, bufsize=1,
        preexec_fn=os.setpgrp)
    for line in iter(process.stdout.readline, b''):
        print(str(line, 'utf-8').replace('\n', ''))

def start_program(program):
    program = "{0}".format(program)
    command = program.split(' ')
    output = subprocess.getoutput('pgrep {0}'.format(command[0]))
    if not output:
        spawnDaemon(command)
        #FNULL = open(os.devnull, 'w')
        #print(subprocess.Popen(command, shell=True, close_fds=True,
                               #stdout=FNULL, stderr=subprocess.STDOUT,
                               #preexec_fn=os.setpgrp))

    else:
        print("{0} already running".format(command[0].capitalize()))


def kill_program(program):
    output = subprocess.getoutput('pgrep {0}'.format(program))
    if output:
        pids = output.split('\n')
        pids = [int(x) for x in pids]
        for pid in pids:
            os.kill(pid, 15)
