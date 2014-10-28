#!/usr/bin/python3

import subprocess
import sys
import re
import time

def parse_config(config):

  ip = '0.0.0.0'
  read_enable = False
  with open('/etc/ipsec.conf','rb') as config_file:

    data = config_file.readlines()
  for line in data:

    line = str(line,'utf-8').replace('\n','')
    if line.startswith('conn'):

      if line == 'conn {0}'.format(config):

        read_enable = True
      elif "conn" in line:

        read_enable = False
    if read_enable == True:

      if 'right=' in line:

        match = re.match('.*=(.*?\..*?\..*?\..*?)$', line)
        if match:

          ip = match.group(1)
  return ip

def get_ip(interface):

  command = "ip a s {0}|grep inet|grep -v inet6|awk '{{print $2}}'".format(interface)
  ip = subprocess.getoutput(command)
  ip = re.sub('\/.*$','',ip)
  if ip == '':

    ip = None
  return ip

def get_subnet(ip):

  subnet = re.sub('([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3})','\g<1>.\g<2>.\g<3>.0/24',ip)
  return subnet

def get_default_gateway():

  command = "ip route|grep 'default'|awk '{print $5}'"
  gw = subprocess.getoutput(command)
  return gw

def get_gateway(ip):

  gateway = re.sub('([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3})','\g<1>.\g<2>.\g<3>.1',ip)
  return gateway

def get_current_state():

  gw_device = get_default_gateway()
  command = "ip link|grep ':\ '|awk '{print $2}'|sed 's/://g'"
  interfaces = subprocess.getoutput(command).split("\n")
  nics = {}
  print(interfaces)
  for nic in interfaces:

    ip = get_ip(nic)
    while nic.startswith('ppp') and ip == None:

      time.sleep(1)
      ip = get_ip(nic)
    if nic.startswith('ppp'):

      print((nic, ip))
    if ip != None:

      subnet = get_subnet(ip)
      gateway = get_gateway(ip)
      if nic.startswith('ppp') or gw_device == nic:

        nics[nic] = {'ip':           ip,
                     'subnet':       subnet,
                     'gateway':      gateway}
  print(nics)
  return nics

def add_default_route(state, ppp_device):

  print("Default route")
  command = "ip route del default"
  #print(command)
  subprocess.getoutput(command)

  command = "ip route add default via {0} dev {1}".format(state[ppp_device]['gateway'], ppp_device)
  #print(command)
  subprocess.getoutput(command)

def del_default_route():

  print("Default route")
  command = 'ip route'
  output = subprocess.getoutput(command).split("\n")
  for line in output:

    match = re.match('[0-9].*via\ (.*?)\ dev\ (.*)$',line)
    if match:

      gw = match.group(1)
      gw_device = match.group(2)
      command = "ip route del default"
      #print(command)
      subprocess.getoutput(command)

      command = "ip route add default via {0} dev {1} proto static".format(gw, gw_device)
      #print(command)
      subprocess.getoutput(command)

def add_subnet_route(state, ppp_device):

  print("Subnet route")
  command = "ip route add {0} dev {1} src {2}".format(state[ppp_device]['subnet'],ppp_device,state[ppp_device]['ip'])
  #print(command)
  subprocess.getoutput(command)

def del_subnet_route(state, ppp_device):

  print("Subnet route")
  command = "ip route del {0} dev {1} src {2}".format(state[ppp_device]['subnet'],ppp_device,state[ppp_device]['ip'])
  #print(command)
  subprocess.getoutput(command)

def add_vpn_route(config, state, ppp_device, gateway_device):

  print("VPN route")
  ipsec_gateway = parse_config(config)
  command = "ip route add {0} via {1} dev {2}".format(ipsec_gateway,state[gateway_device]['gateway'],gateway_device)
  #print(command)
  subprocess.getoutput(command)

def del_vpn_route():

  print("VPN route")
  command = 'ip route'
  output = subprocess.getoutput(command).split("\n")
  for line in output:

    match = re.match('([0-9].*?)\ via\ (.*?)\ dev\ (.*)$',line)
    if match:

      ipsec_gateway = match.group(1)
      gw = match.group(2)
      gw_device = match.group(3)
      command = "ip route del {0} via {1} dev {2}".format(ipsec_gateway, gw, gw_device)
      #print(command)
      subprocess.getoutput(command)

def start_vpn(config):

  command = "service ipsec start&&service xl2tpd start"
  print(command)
  subprocess.getoutput(command)
  command = "ipsec auto --up {0}&& echo 'c vpn-{0}'>/var/run/xl2tpd/l2tp-control".format(config)
  print(command)
  subprocess.getoutput(command)
  time.sleep(2)

  # Start vpn tunnel, ppp device becomes available
  state = get_current_state()
  for device in state:

    if device.startswith('ppp'):

      ppp_device = device
    else:

      gateway_device = device

  # Route traffic to the vpn through the gateway_device
  add_vpn_route(config, state, ppp_device, gateway_device)

  # Add subnet routing
  add_subnet_route(state, ppp_device)

  # Change the default gateway
  add_default_route(state, ppp_device)

def stop_vpn(config):

  state = get_current_state()
  for device in state:

    if device.startswith('ppp'):

      ppp_device = device
    else:

      gateway_device = device

  # Delete the default gateway
  del_default_route()

  # Delete the subnet
  del_subnet_route(state, ppp_device)

  # Delete the route to the VPN
  del_vpn_route()

  command = "echo 'd vpn-{0}'> /var/run/xltpd/l2tp-control".format(config)
  subprocess.getoutput(command)
  command = "service xl2tpd stop&&service ipsec stop"
  subprocess.getoutput(command)

def main():

  action = sys.argv[1]
  config = sys.argv[2]
  if action == 'up':

    start_vpn(config)
  else:

    stop_vpn(config)

if __name__ == '__main__':

  if len(sys.argv) > 1:

    main()