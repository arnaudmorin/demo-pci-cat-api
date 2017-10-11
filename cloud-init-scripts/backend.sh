#!/bin/bash
# Setup logging stdout + stderr to logfile
log_file="/var/log/postinstall.log"

function log_handler {
  while IFS='' read -r output; do
    echo $output
    echo "$(date) - $output" >> $log_file
  done
}

exec &> >(log_handler)

# Update root and debian password
echo 'root:root' |chpasswd
echo 'debian:debian' |chpasswd
rm /root/.ssh/authorized_keys

echo "Adding default route"
ip route add default via 192.168.1.1

echo "Configure DNS"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo "Update and install some packages"
apt-get update
apt-get -y install git python-pip python-dev vim python-flask python-yaml
#pip install flask

echo "Cloning cat API website"
cd /root
git clone https://github.com/arnaudmorin/puppet-demoflask.git

echo "Starting cat API website"
cd /root/puppet-demoflask
./start.py &
