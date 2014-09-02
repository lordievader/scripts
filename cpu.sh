#!/bin/bash
num_cpu=$(grep processor /proc/cpuinfo|tail -n1|awk '{print $3}')
for i in $(seq 0 $num_cpu); do
  sudo cpufreq-set -g $1 -c $i
done
