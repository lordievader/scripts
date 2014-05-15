# Managed by Puppet

#!/bin/bash
apt-get update > /dev/null
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean -y
