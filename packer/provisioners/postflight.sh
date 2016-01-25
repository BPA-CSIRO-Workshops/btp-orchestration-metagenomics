#!/bin/bash

# Desktop
apt-get update
apt-get install -y ubuntu-desktop
/bin/sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# NX
cd /tmp
wget -4 --no-check-certificate https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NX/nomachine_5.0.63_1_amd64.deb
dpkg -i nomachine_5.0.63_1_amd64.deb
rm nomachine_5.0.63_1_amd64.deb

# cloud-init
echo 'datasource_list: [ Ec2 ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg
dpkg-reconfigure -f noninteractive cloud-init

# Empty log files on the VM
find /var/log -type f -execdir truncate -s0 {} \;

# Disable LTS Upgrade Notification
sed -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades

# Clean apt
apt-get -y clean all
