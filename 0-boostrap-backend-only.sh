openstack server create --key-name arnaud-ovh --flavor c2-7 --image 'Debian 8' --nic net-id=Ext-Net --user-data backend.yaml --wait cat-api
