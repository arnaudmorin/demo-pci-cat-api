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
 git \
 vim \
 python-flask \
 python-yaml \
 curl \
 psmisc \
 keepalived

echo "Cloning cat API website"
cd /root
git clone https://github.com/arnaudmorin/demo-flask.git

echo "Starting cat API website"
cd /root/demo-flask
./start.py &

echo "Configure keepalived"
cat <<EOF >/etc/keepalived/keepalived.conf
vrrp_script chk_service {
  script "/usr/bin/killall -0 -r start.py" # check the process
  interval 1 # every 1 seconds
  weight 2 # add 2 points if OK
}

vrrp_instance vrrp_group_1 {
  state MASTER
  interface ens3
  virtual_router_id 1
  priority 50
  authentication {
    auth_type PASS
    auth_pass moutarde42
  }
  virtual_ipaddress {
    192.168.1.10/24 brd 192.168.1.255 dev ens3
  }

  track_script {
    chk_service
  }
}
EOF

echo "Start keepalived"
systemctl enable keepalived && systemctl start keepalived

echo "Done"
