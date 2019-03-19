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

echo "Update and install some packages"
apt-get update
apt-get -y install \
 curl \
 vim \
 netcat \
 tmux

echo "Done"
