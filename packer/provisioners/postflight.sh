#!/bin/bash

# NX
cd /tmp
wget -4 --no-check-certificate https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NX/nomachine_5.1.26_1_amd64.deb -O /tmp/nomachine_5.1.26_1_amd64.deb
dpkg -i /tmp/nomachine_5.1.26_1_amd64.deb
rm /tmp/nomachine_5.1.26_1_amd64.deb

# Empty log files on the VM
find /var/log -type f -execdir truncate -s0 {} \;

# Disable LTS Upgrade Notification
sed -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades

# SSHD 
/bin/sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Clean apt
apt-get -y clean all