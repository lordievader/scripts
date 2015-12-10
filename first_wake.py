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

import libdbus
import frames

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

def kmc(command):
    bus = libdbus.dbus_connect()
    reply = bytearray(bus.control(command))
    ack_frame = frames.ACKFrame().decode(reply)
    if ack_frame.ack != 'ack':
        print("KMC Error")

def virtual_desktop(number):
    bus = libdbus.dbus_connect(
        name='org.kde.KWin',
        path='/KWin',
        prefix='org.kde.KWin')
    bus.setCurrentDesktop(number)


def konsole():
    command = "ps aux|grep '[t]mux attach -t Chat'"
    output = subprocess.getoutput(command)
    if output:
        print("SSH to Darth-Sidious running")
        return

    bus = None
    for i in range(1, 4):
        bus = libdbus.dbus_connect(
            name='org.kde.konsole',
            path='/konsole/MainWindow_{0}'.format(i),
            prefix='org.freedesktop.DBus.Properties')
        try:
            x = bus.Get('org.qtproject.Qt.QWidget', 'x')
            if x == 4480:
                break

        except libdbus.dbus.exceptions.DBusException as e:
            bus = None
            break

    else:
        bus = None

    if bus is not None:
        app_id = i
        bus = libdbus.dbus_connect(
            name='org.kde.konsole',
            path='/konsole/MainWindow_{0}'.format(app_id),
            prefix='org.kde.KMainWindow')
        win_id = bus.winId()
        print(win_id)
        for i in range(1, 100):
            bus = libdbus.dbus_connect(
                name='org.kde.konsole',
                path='/Sessions/{0}'.format(i),
                prefix='org.kde.konsole.Session')
            try:
                x = bus.environment()
                x = {re.sub('=.*$', '', item): re.sub('^.*=', '', item)
                     for item in x}
                if int(x['WINDOWID']) == win_id:
                    break

            except libdbus.dbus.exceptions.DBusException as e:
                bus = None

        else:
            bus = None

        if bus is not None:
            bus.runCommand('sidious -t tmux attach -t Chat')

    # qdbus org.kde.konsole /konsole/MainWindow_2 org.qtproject.Qt.QWidget.x
    # qdbus org.kde.konsole /Sessions/20 org.kde.konsole.Session.environment <-- gives winid
    # qdbus org.kde.konsole /konsole/MainWindow_2 org.kde.KMainWindow.winId <-- needs to match
    # qdbus org.kde.konsole /Sessions/20 org.kde.konsole.Session.runCommand <-- runs command

def check():
    if subprocess.getoutput('nmcli c s --active bridge-br0'):
        return True

    return False


def set_up():
    if check():
        start_program('cantata')
        start_program('thunderbird')
        start_program('firefox')
        konsole()
        kmc('play')
        time.sleep(1)
        virtual_desktop(4)

    else:
        print("Not home")

def main():
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
        write_to_file(cur.day, cur.hour)
        set_up()
        exit(0)

    else:
        exit(1)

if __name__ == '__main__':
    main()
    #set_up()
