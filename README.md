# demo-pci-cat-api
This is a demo using OVH Public Cloud Infrastructure and Floating IP

## You need to source some variables in your environment
You need at least source openrc file and some OVH credentials.
At the end, you must have those variables set in your environment:

    OS_AUTH_URL=https://auth.cloud.ovh.net/v2.0/
    OS_TENANT_ID=0d899a6f76d74760a06919233ed0ec51
    OS_TENANT_NAME=6837909462521441
    OS_USERNAME=aaa
    OS_PASSWORD=bbb
    OS_REGION_NAME=SBG3
    OVH_ENDPOINT=ovh-eu
    OVH_APPLICATION_KEY=ccc
    OVH_APPLICATION_SECRET=ddd
    OVH_CONSUMER_KEY=eee
    OVH_PROJECT_ID=0d899a6f76d74760a06919233ed0ec51


## Then go

### Create network
    openstack network create private
    openstack subnet create --dns-nameserver 213.186.33.99 --gateway 192.168.1.1 --subnet-range 192.168.1.0/24 --allocation-pool start=192.168.1.50,end=192.168.1.99 --network private --dhcp 192.168.1.0/24

### Create router
    openstack router create router
    openstack router set --external-gateway Ext-Net router
    openstack router add subnet router 192.168.1.0/24

### Create 2 floatings
1 for rebond
1 for vip

    openstack floating ip create Ext-Net
    openstack floating ip create Ext-Net

### Associate first floating to virtual ip port
    openstack port create --fixed-ip subnet=192.168.1.0/24,ip-address=192.168.1.10 --network private vip
    openstack floating ip set --port vip 42.42.42.42

### Create the rebond
    openstack server create --key-name arnaud-ovh --image 'Debian 9' --flavor c2-7 --net private --user-data userdata/rebond.sh rebond

### Create the 2 backends
    openstack server create --key-name arnaud-ovh --image 'Debian 9' --flavor c2-7 --net private --user-data userdata/backend.sh arnaud1
    openstack server create --key-name arnaud-ovh --image 'Debian 9' --flavor c2-7 --net private --user-data userdata/backend.sh arnaud2

### Wait for rebond to be up and set the second floating IP
    openstack server add floating ip rebond 42.42.42.43

### Clean
    openstack server delete rebond arnaud1 arnaud2
    openstack floating ip list -f value -c ID | xargs openstack floating ip delete
    openstack port delete vip
    openstack router remove subnet arnaud-router 192.168.1.0/24
    openstack router delete arnaud-router
    openstack network delete private



