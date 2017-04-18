# demo-pci-cat-api
This is a demo using OVH Public Cloud Infrastructure, Terraform and cloud-init stuff

## First boot a backend to test
    bash 0-boostrap-backend-only.sh

## Second, create infra with terraform
    terraform apply

## Check ping stats between frontend and backend
    fping -n -i 10 -p 10 -c 20 -g 192.168.1.11 192.168.1.13 -q
