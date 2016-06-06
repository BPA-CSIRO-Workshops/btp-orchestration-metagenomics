#!/bin/bash

# cloud-init
apt-get update
apt-get install -y cloud-init
apt-get clean
echo 'datasource_list: [ Ec2 ]' | tee /etc/cloud/cloud.cfg.d/btp.cfg
dpkg-reconfigure -f noninteractive cloud-init