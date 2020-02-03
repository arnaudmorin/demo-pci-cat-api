openstack server create --key-name arnaud-ovh --flavor c2-7 --image 'Debian 9' --nic net-id=Ext-Net --user-data cloud-init-scripts/backend.sh --wait cat-api
