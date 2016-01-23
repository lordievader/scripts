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
import lordievader

def virtual_desktop(number):
    bus = libdbus.dbus_connect(
        name='org.kde.KWin',
        path='/KWin',
        prefix='org.kde.KWin')
    bus.setCurrentDesktop(number)
0

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
            bus.runCommand('sidious')

    # qdbus org.kde.konsole /konsole/MainWindow_2 org.qtproject.Qt.QWidget.x
    # qdbus org.kde.konsole /Sessions/20 org.kde.konsole.Session.environment <-- gives winid
    # qdbus org.kde.konsole /konsole/MainWindow_2 org.kde.KMainWindow.winId <-- needs to match
    # qdbus org.kde.konsole /Sessions/20 org.kde.konsole.Session.runCommand <-- runs command

def main():
    if '--ssh' in sys.argv:
        konsole()

if __name__ == '__main__':
    main()
