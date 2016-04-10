#!/usr/bin/python3
import time
import sys
import os
import trace

import program_control
import networkmanager
import first_wake


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
    sys.argv.append('-f')
    func()

    # all done
    os._exit(os.EX_OK)

def wakeup():
    """Does what is necessary to wakeup.
    """
    output, connection = networkmanager.check()
    if connection is False:
        time.sleep(5)
        networkmanager.nm()

    program_control.run_command('/home/lordievader/scripts/gamma2.sh --load')
    if not program_control.check_command(
            '/home/lordievader/scripts/mount.sh -c'):
        program_control.run_command('/home/lordievader/scripts/mount.sh -m')

if __name__ == '__main__':
    os.environ['DISPLAY'] = ':0'
    wakeup()
    #sys.argv.append('-f')
    #first_wake.main()
