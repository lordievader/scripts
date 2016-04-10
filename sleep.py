#!/usr/bin/python3
import os

import program_control
import ssh_control

KILL_PROGRAMS = ['cantata']


def sleep():
    program_control.run_command('systemctl --user stop wakeup.service')

    # Kill SSH
    ssh_control.kill_ssh()

    # Kill programs
    for program in KILL_PROGRAMS:
        program_control.kill_program(program)

    # Unmount shares
    program_control.run_command('/home/lordievader/scripts/mount.sh -u')

if __name__ == '__main__':
    os.environ['DISPLAY'] = ':0'
    sleep()
