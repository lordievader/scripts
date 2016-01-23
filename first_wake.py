#!/usr/bin/python3
#exit()

import os
import re
import datetime
import subprocess
import sys
import time

if '/home/lordievader/Projects/Python/kmc' not in sys.path:
    sys.path.insert(0, '/home/lordievader/Projects/Python/kmc')

import kmcc
import libdbus
import lordievader

import konsole

tmp_file = '/tmp/first_wake'

cur = datetime.datetime.today()

first_wake = False


def write_to_file(day, hour):
    with open(tmp_file, 'w') as f:
        f.write("{0}:{1}\n".format(day, hour))


def start_program(program):
    if subprocess.call("pgrep {0} > /dev/null".format(program), shell=True):
        print("Starting {0}".format(program.capitalize()))
        subprocess.Popen(["nohup", program])

    else:
        print("{0} running".format(program.capitalize()))

def virtual_desktop(number):
    bus = libdbus.dbus_connect(
        name='org.kde.KWin',
        path='/KWin',
        prefix='org.kde.KWin')
    bus.setCurrentDesktop(number)


def check():
    if subprocess.getoutput('nmcli c s --active bridge-br0'):
        return True

    return False


def set_up():
    if check() or '-f' in sys.argv:
        start_program('cantata')
        start_program('thunderbird')
        start_program('firefox')
        konsole.konsole()
        kmcc.kmc('play')
        time.sleep(1)
        virtual_desktop(4)

    else:
        print("Not home")


def main():
    logger = lordievader.logsetup.log_setup(
        'first_wake', None, 'DEBUG')
    first_wake = False
    if os.path.isfile(tmp_file):
        with open(tmp_file, 'r') as f:
            data = f.read().replace('\n', '')

        day = int(re.sub(':.*', '', data))
        hour = int(re.sub('.*:', '', data))
        if cur.hour > 6:
            if day != cur.day:
                first_wake = True

            elif hour < 6:
                first_wake = True

    else:
        write_to_file(cur.day, cur.hour)

    if first_wake is True:
        logger.info("This is the first wake")
        write_to_file(cur.day, cur.hour)
        set_up()
        exit(0)

    else:
        logger.info("This is NOT the first wake")
        if '-f' in sys.argv:
            logger.info('First wake forced')

            set_up()
        exit(0)

if __name__ == '__main__':
    os.environ['DISPLAY'] = ':0'
    main()
    #set_up()
