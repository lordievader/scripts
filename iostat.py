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

def enumerate_disks():
  disks = []
  for dev in os.listdir('/dev/'):
    if (dev.startswith("sd") or
        dev.startswith("dm")):
      disks.append(dev)
  return disks

def stats(line):
  line = re.sub("\ +", " ", line).split(" ")
  read = float(line[2])
  write = float(line[3])
  return (read, write)

def avg_speed(read, write, average):
  read = round((read + average['read'])/2, 3)
  write = round((write + average['write'])/2, 3)
  return read, write

def print_speed(disk, average):
  read = "{0:.3f}".format(average['read'])
  write = "{0:.3f}".format(average['write'])
  if average['read'] > 0.1 or average['write'] > 0.1:
    line = "{0:>6}: R:{1:>12} W:{2:>12}".format(disk, read, write)
    print(line)

def monitor(**disk):
  output = disk['output']
  disk = disk['disk']
  average = {'read': 0, 'write': 0}
  count = 0
  command = "iostat -d /dev/{0} 5".format(disk)
  process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, bufsize=1)
  for line in iter(process.stdout.readline, b''):
    line = str(line, 'utf-8')
    if line.startswith(disk) and count != 0:
      line = line.replace("\n", '')
      read, write = stats(line)
      read, write = avg_speed(read, write, average)
      average = {'read': read, 'write': write}
      output.put((disk, average))

    elif line.startswith(disk) and count == 0:
      count += 1

def printer(**output):
  length = output['disks']
  output = output['output']
  while True:
    
    data = []
    for i in range(length):
      data.append(output.get())
    os.system('clear')
    print(str(datetime.datetime.today()))
    for item in sorted(data):
      disk = item[0]
      average = item[1]
      print_speed(disk, average)

def main():
  disks = enumerate_disks()
  threads = {}
  output = queue.Queue()
  for disk in disks:
    threads[disk] = threading.Thread(target=monitor, kwargs={"disk": disk, 'output': output})
    threads[disk].start()
  print_output = threading.Thread(target=printer, kwargs={'output': output, 'disks': len(disks)})
  print_output.start()

if __name__ == "__main__":
  main()
