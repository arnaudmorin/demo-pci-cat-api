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
echo 'root:moutarde42' |chpasswd
echo 'debian:moutarde42' |chpasswd
rm /root/.ssh/authorized_keys

echo "Adding default route"
ip route add default via 192.168.1.1

echo "Configure DNS"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo "Update and install some packages"
apt-get update
apt-get -y install git python3-pip python3-dev vim python3-flask python3-yaml
#pip install flask

echo "Cloning cat API website"
cd /root
git clone https://github.com/arnaudmorin/demo-flask.git

echo "Starting cat API website"
cd /root/demo-flask
./start.py &
