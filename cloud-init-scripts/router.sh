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


apt-get update
apt-get -y install git vim

PUB="ens3"
PRIV="ens4"

echo "Requesting IP from DHCP"
ip link set $PRIV up
dhclient $PRIV

echo "Grab configured IP"

# Get IP from interfaces
PUB_IP=$(ip addr show $PUB | grep 'inet '|awk -F" " '{print $2}'| sed -r 's/\/.*$//')
PRIV_IP=$(ip addr show $PRIV | grep 'inet '|awk -F" " '{print $2}'| sed -r 's/\/.*$//')

# Configuring router
modprobe iptable_nat
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o $PUB -j MASQUERADE
iptables -A FORWARD -i $PRIV -o $PUB -j ACCEPT
echo "Routing from "
echo "  $PRIV / $PRIV_IP"
echo "to"
echo "  $PUB / $PUB_IP"
echo ""
echo "Please check that the default route is well configured:"
ip r l | grep default

