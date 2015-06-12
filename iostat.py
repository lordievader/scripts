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
import operator

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

  def dm_links(self):
    dm = {}
    for item in os.listdir('/dev/mapper'):
      path = os.path.join('/dev/mapper', item)
      if os.path.islink(path):
        real_path = os.path.realpath(path)
        dm_name = real_path.split('/')[2]
        dm[dm_name] = item
    return dm

  def enumerate_disks(self):
    dm = self.dm_links()
    disks = {'phy': {},
             'dm': {},}
    names = []
    for dev in os.listdir('/dev/'):
      if dev.startswith("sd"):
        disks = self.add_disk(disks, dev)
        names.append(dev)

      elif dev.startswith('dm'):
        disks['dm'][dev] =   {'tps': 0,
                             'readps': 0,
                             'writeps': 0,
                             'read': 0,
                             'write': 0,
                             'name': dm[dev]}
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
    os.system('clear')
    for type_disk in results:
      lines = {}
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
          if type_disk == 'phy':
            data['name'] = disk

          lines["%-80s R:%8.2f W:%8.2f" % (data['name'], data['readps'], data['writeps'])]= data['writeps']


      for line in reversed(sorted(lines.items(), key=operator.itemgetter(1))):
        print(line[0])
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
