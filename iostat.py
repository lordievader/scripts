#!/usr/bin/python3.4
import statistics
import os
import subprocess
import sys
import re
import time
import threading
import queue
import datetime

if os.getuid() != 0:
  raise SystemExit("Needs root privileges")

class Collector(threading.Thread):
  def __init__(self, delay):
    threading.Thread.__init__(self)
    self.disks, self.names = self.enumerate_disks()
    self.delay = delay

  def add_disk(self, disks, dev):
    if len(dev) == 3:
      if not dev in disks['phy']:
        disks['phy'][dev] = {'partitions':{},
                             'tps': 0,
                             'readps': 0,
                             'writeps': 0,
                             'read': 0,
                             'write': 0,}

    else:
      phy = dev[:3]
      if phy in disks['phy']:
        disks['phy'][phy]['partitions'][dev] = {}

      else:
        disks['phy'][phy] = {'partitions': {dev: {}}}
    return disks

  def enumerate_disks(self):
    disks = {'phy': {},
             'dm': {},}
    names = []
    for dev in os.listdir('/dev/'):
      if dev.startswith("sd") or dev.startswith('md'):
        disks = self.add_disk(disks, dev)
        names.append(dev)

      elif dev.startswith('dm'):
        disks['dm'][dev] =   {'tps': 0,
                             'readps': 0,
                             'writeps': 0,
                             'read': 0,
                             'write': 0,}
        names.append(dev)
    return (disks, names)

  def get_results(self):
    return self.disks

  def run(self):
    command = ""
    for type_disk in sorted(self.disks):
      for disk in sorted(self.disks[type_disk]):
        command += "-d /dev/%s " % disk
    command = "iostat %s %d" % (command, self.delay)
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, bufsize=1)
    for line in iter(process.stdout.readline, b''):
      line = str(line, 'utf-8').split()
      if len(line) == 6:
        name, tps, readps, writeps, read, write = line
        if name in self.names:
          if re.search('[sm]d', name):
            type_disk = 'phy'

          else:
            type_disk = 'dm'

          self.disks[type_disk][name]['tps'] = float(tps)
          self.disks[type_disk][name]['readps'] = float(readps)
          self.disks[type_disk][name]['writeps'] = float(writeps)
          self.disks[type_disk][name]['read'] = int(read)
          self.disks[type_disk][name]['write'] = int(write)

class Printer():
  def __init__(self, collector):
    self.collector = collector

  def print_results(self):
    results = self.collector.get_results()
    lines = {}
    os.system('clear')
    for type_disk in results:
      if type_disk == 'phy':
        line = "Physical disks"

      else:
        line = "LVM volumes"

      print(line)
      sub = '{:=^'+str(len(line))+'}'
      print(sub.format(''))
      for disk in results[type_disk]:
        data = results[type_disk][disk]
        if 'readps' in data and (data['readps'] > 0 or data['writeps'] > 0):
          lines[data['writeps']]= data
          lines[data['writeps']]['name'] = disk

      for line in reversed(sorted(lines)):
        print("%-5s R:%8.2f W:%8.2f" % (lines[line]['name'],lines[line]['readps'], lines[line]['writeps']))
      print()

def main():
  delay = 5
  collector = Collector(delay)
  collector.daemon = True
  printer = Printer(collector)
  collector.start()
  while True:
    printer.print_results()
    time.sleep(delay)

if __name__ == "__main__":
  main()
