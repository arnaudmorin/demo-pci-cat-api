# demo-pci-cat-api
This is a demo using OVH Public Cloud Infrastructure, Terraform and cloud-init stuff

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


## First boot a backend to test
    bash bootstrap-backend-only.sh

## Second, create infra with terraform
    terraform init
    terraform apply

## Check ping stats between frontend and backend
    fping -n -i 10 -p 10 -c 20 -g 192.168.1.11 192.168.1.13 -q
