#!/usr/bin/python3
import subprocess
import re

CHANNELS = {
  1: {'freq': 2412, 'count': 0},
  2: {'freq': 2417, 'count': 0},
  3: {'freq': 2422, 'count': 0},
  4: {'freq': 2427, 'count': 0},
  5: {'freq': 2432, 'count': 0},
  6: {'freq': 2437, 'count': 0},
  7: {'freq': 2442, 'count': 0},
  8: {'freq': 2447, 'count': 0},
  9: {'freq': 2452, 'count': 0},
  10: {'freq': 2457, 'count': 0},
  11: {'freq': 2462, 'count': 0},
  12: {'freq': 2467, 'count': 0},
  13: {'freq': 2472, 'count': 0},
  14: {'freq': 2484, 'count': 0},
}

def scan():
  command = "sudo iw dev wlo1 scan|grep freq:|awk '{print $2}'|uniq -c"
  return subprocess.getoutput(command).split('\n')

def parse(channel_count):
  counts = {}
  for line in channel_count:
    count = re.search(r'\ *([0-9]+)\ ', line)
    count = int(count.group(1))
    frequency = re.search(r'\ *[0-9]+\ ([0-9]+)', line)
    frequency = int(frequency.group(1))
    counts[frequency] = count
  
  result = {}
  for channel in CHANNELS:
    freq = CHANNELS[channel]['freq']
    if freq in counts:
      result[channel] = {
        'freq': freq,
        'count': counts[freq],
      }

    else:
      result[channel] = {
        'freq': freq,
        'count': 0,
      }

  return result

data = parse(scan())
for channel in sorted(data):
  print("Channel {0}: {1} ({2})".format(
    str(channel).zfill(2),
    data[channel]['count'],
    data[channel]['freq']))

